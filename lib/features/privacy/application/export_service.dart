import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:uuid/uuid.dart';

class ExportCancelled implements Exception {
  const ExportCancelled();
}

class ExportResult {
  const ExportResult(this.file, this.missing);
  final File file;
  final List<String> missing;
}

class ExportService {
  ExportService(this.database, this.originals, this.owner);
  final AppDatabase database;
  final OriginalStore originals;
  final String? Function() owner;
  static Future<void> purgeExpired(Directory destination) async {
    if (!await destination.exists()) return;
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    await for (final entity in destination.list(followLinks: false)) {
      if (entity is Directory &&
          (await entity.stat()).modified.isBefore(cutoff)) {
        try {
          await entity.delete(recursive: true);
        } on FileSystemException {
          /* Retry next launch. */
        }
      }
    }
  }

  Future<ExportResult> export({
    required List<String> itemIds,
    required Directory destination,
    required bool Function() cancelled,
  }) async {
    final user = owner();
    void guard() {
      if (cancelled() || owner() != user) throw const ExportCancelled();
    }

    guard();
    if (itemIds.isEmpty) throw ArgumentError('Select a matter');
    final ids = itemIds.toSet().toList();
    // Explicit portable columns: no jobs, tokens, device paths or signed URLs.
    final columns = {
      'items': 'id,title,summary,status,created_at,updated_at,resolved_at',
      'sources': 'id,item_id,kind,origin,original_name,mime_type,byte_size,content_hash,revision,text_content,page_count,created_at,updated_at',
      'facts': 'id,item_id,source_id,source_revision,key,value_type,value,user_value,provenance,evidence,created_at,updated_at',
      'item_actions': 'id,item_id,source_id,analysis_revision,kind,title,payload_version,payload,origin,evidence_fact_ids,state,execution_state,accepted_at,created_at,updated_at',
      'reminders': 'id,item_id,action_id,title,time_zone,remind_at,completed_at,created_at,updated_at',
    };
    final data = <String, Object?>{
      'exportVersion': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    await database.transaction(() async {
      for (final entry in columns.entries) {
        final rows = await database
            .customSelect(
              'SELECT ${entry.value} FROM ${entry.key} WHERE ${entry.key == 'items' ? 'id' : 'item_id'} IN (${List.filled(ids.length, '?').join(',')}) AND owner_id IS ? AND deleted_at IS NULL',
              variables: [...ids.map(Variable.new), Variable<String>(user)],
            )
            .get();
        data[entry.key] = rows.map((r) {
          final row = Map<String, dynamic>.from(r.data);
          for (final key in [
            'value',
            'user_value',
            'evidence',
            'payload',
            'evidence_fact_ids',
          ]) {
            if (row[key] is String) row[key] = jsonDecode(row[key] as String);
          }
          return row;
        }).toList();
      }
      guard();
    });
    if ((data['items'] as List).length != ids.length) {
      throw StateError('Matter unavailable');
    }
    await destination.create(recursive: true);
    final directory = await Directory(
      '${destination.path}/${const Uuid().v4()}',
    ).create();
    final zip = ZipFileEncoder();
    var opened = false;
    final missing = <String>[];
    final originalEntries = <Map<String, Object?>>[];
    try {
      zip.create('${directory.path}/export.part');
      opened = true;
      for (final raw in data['sources'] as List) {
        guard();
        final source = raw as Map<String, dynamic>;
        final id = source['id'] as String;
        final pathRow = await (database.select(
          database.sourceFiles,
        )..where((f) => f.sourceId.equals(id))).getSingleOrNull();
        final relative = pathRow?.originalRelativePath;
        File? file;
        if (relative != null) {
          final candidate = originals.file(relative);
          if (await candidate.exists() &&
              (await candidate.resolveSymbolicLinks()).startsWith(
                '${await originals.root.resolveSymbolicLinks()}${Platform.pathSeparator}',
              ) &&
              await candidate.length() == source['byte_size'] &&
              (await sha256.bind(candidate.openRead()).first).toString() ==
                  source['content_hash']) {
            file = candidate;
          }
        }
        if (file == null) {
          missing.add(id);
          originalEntries.add({'sourceId': id, 'available': false});
          continue;
        }
        final entry = 'originals/$id';
        await zip.addFile(file, entry);
        guard();
        originalEntries.add({'sourceId': id, 'available': true, 'path': entry});
      }
      data['originals'] = originalEntries;
      data['complete'] = missing.isEmpty;
      final manifest = await File('${directory.path}/manifest.json')
          .writeAsString(
            const JsonEncoder.withIndent('  ').convert(data),
            flush: true,
          );
      await zip.addFile(manifest, 'manifest.json');
      await zip.close();
      opened = false;
      guard();
      await manifest.delete();
      final result = await File('${directory.path}/export.part')
          .rename('${directory.path}/kipto-export.zip');
      return ExportResult(result, missing);
    } on Object {
      if (opened) await zip.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      rethrow;
    }
  }
}
