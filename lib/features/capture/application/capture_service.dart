import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:pdfrx/pdfrx.dart';
import 'package:crypto/crypto.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';

class CaptureService {
  CaptureService({
    required this.files,
    required this.sources,
    required this.scope,
  });
  final OriginalStore files;
  final DriftSourcesRepository sources;
  final Future<String> Function() scope;
  Future<void> _tail = Future.value();
  Future<T> _serial<T>(Future<T> Function() work) {
    final task = _tail.then((_) => work());
    _tail = task.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return task;
  }

  Future<String> importFile({
    required String captureId,
    required File file,
    required String name,
    String origin = 'systemPicker',
    String? contextText,
    String? title,
    String? expectedScope,
  }) => _serial(() async {
    final before = await scope();
    if (expectedScope != null && expectedScope != before) {
      throw const CaptureFailure('accountChanged');
    }
    final existing = await sources.find(captureId);
    if (existing != null) {
      if (existing.ownerId != sources.coordinator.activeOwnerId) {
        throw const CaptureFailure('accountChanged');
      }
      if (existing.deletedAt != null) throw const CaptureFailure('unavailable');
      return existing.itemId;
    }
    if (await file.length() > maxOriginalBytes) {
      throw const CaptureFailure('tooLarge');
    }
    final original = await files.persist(
      captureId: captureId,
      scope: before,
      name: name,
      origin: origin,
      bytes: file.openRead(),
      contextText: contextText,
    );
    return _commit(original, before, title: title);
  });
  Future<String> importText({
    required String captureId,
    required String text,
    required String title,
    String origin = 'manual',
    String? expectedScope,
  }) => _serial(() async {
    if (text.trim().isEmpty || title.trim().isEmpty) {
      throw const CaptureFailure('invalid');
    }
    final before = await scope();
    if (expectedScope != null && expectedScope != before) {
      throw const CaptureFailure('accountChanged');
    }
    final original = await files.persist(
      captureId: captureId,
      scope: before,
      name: title,
      origin: origin,
      bytes: Stream.value(utf8.encode(text)),
      text: text,
    );
    return _commit(original, before, title: title);
  });
  Future<String> _commit(
    StoredOriginal original,
    String before, {
    String? title,
  }) async {
    int? pages;
    final file = files.file(original.relativePath);
    try {
      final root = await files.root.resolveSymbolicLinks();
      if (!(await file.resolveSymbolicLinks()).startsWith(
            '$root${Platform.pathSeparator}',
          ) ||
          await file.length() != original.size ||
          (await sha256.bind(file.openRead()).first).toString() !=
              original.hash) {
        throw const CaptureFailure('invalid');
      }
      if (original.mime == 'application/pdf') {
        final pdf = await PdfDocument.openFile(
          file.path,
          passwordProvider: () async => null,
        );
        try {
          if (pdf.isEncrypted || pdf.pages.isEmpty) {
            throw const CaptureFailure('unreadable');
          }
          pages = pdf.pages.length;
        } finally {
          await pdf.dispose();
        }
      } else if (original.mime.startsWith('image/')) {
        final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
        try {
          final descriptor = await ui.ImageDescriptor.encoded(buffer);
          try {
            if (descriptor.width * descriptor.height > 40000000) {
              throw const CaptureFailure('tooLarge');
            }
            final codec = await descriptor.instantiateCodec(targetWidth: 512);
            try {
              final frame = await codec.getNextFrame();
              frame.image.dispose();
            } finally {
              codec.dispose();
            }
          } finally {
            descriptor.dispose();
          }
        } finally {
          buffer.dispose();
        }
      }
    } on CaptureFailure {
      rethrow;
    } on Object {
      throw const CaptureFailure('unreadable');
    }
    final itemId = await sources.import(
      original,
      expectedScope: before,
      currentScope: await scope(),
      title: title,
      pageCount: pages,
    );
    await files.acknowledge(original);
    return itemId;
  }

  Future<int> recover() => _serial(() async {
    final current = await scope();
    var failures = 0;
    for (final original in await files.recover(current)) {
      if (await sources.find(original.captureId) != null) {
        await files.acknowledge(original);
        continue;
      }
      try {
        await _commit(original, current);
      } on Object {
        failures++;
      }
    }
    return failures + files.recoveryFailures.length;
  });
}
