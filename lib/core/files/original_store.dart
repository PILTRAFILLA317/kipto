import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const maxOriginalBytes = 20 * 1024 * 1024;
const maxTextCharacters = 60000;
final captureIdPattern = RegExp(
  r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$',
);

class CaptureFailure implements Exception {
  const CaptureFailure(this.code);
  final String code;
}

class StoredOriginal {
  const StoredOriginal({
    required this.captureId,
    required this.scope,
    required this.name,
    required this.mime,
    required this.size,
    required this.hash,
    required this.relativePath,
    required this.origin,
    required this.createdAt,
    this.text,
    this.pageCount,
  });
  final String captureId, scope, name, mime, hash, relativePath, origin;
  final int size;
  final int? pageCount;
  final String? text;
  final DateTime createdAt;
  Map<String, Object?> toJson() => {
    'version': 1,
    'captureId': captureId,
    'scope': scope,
    'name': name,
    'mime': mime,
    'size': size,
    'hash': hash,
    'path': relativePath,
    'origin': origin,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'text': text,
    'pageCount': pageCount,
  };
  factory StoredOriginal.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 ||
        !captureIdPattern.hasMatch(json['captureId'] as String? ?? '')) {
      throw const CaptureFailure('invalid');
    }
    final id = json['captureId'] as String;
    if (json['path'] != '$id/original' ||
        (json['size'] as int) > maxOriginalBytes ||
        (json['size'] as int) < 1) {
      throw const CaptureFailure('invalid');
    }
    return StoredOriginal(
      captureId: id,
      scope: json['scope'] as String,
      name: json['name'] as String,
      mime: json['mime'] as String,
      size: json['size'] as int,
      hash: json['hash'] as String,
      relativePath: json['path'] as String,
      origin: json['origin'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String?,
      pageCount: json['pageCount'] as int?,
    );
  }
}

class OriginalStore {
  OriginalStore(this.root);
  final Directory root;
  final List<String> recoveryFailures = [];
  File file(String relativePath) {
    final segments = relativePath.split('/');
    if (segments.length != 2 ||
        !captureIdPattern.hasMatch(segments[0]) ||
        !{'original', 'thumbnail'}.contains(segments[1])) {
      throw const CaptureFailure('invalid');
    }
    return File('${root.path}/$relativePath');
  }

  Future<StoredOriginal> persist({
    required String captureId,
    required String scope,
    required String name,
    required String origin,
    required Stream<List<int>> bytes,
    String? text,
    String? contextText,
  }) async {
    if (!captureIdPattern.hasMatch(captureId)) {
      throw const CaptureFailure('invalid');
    }
    if ((text?.length ?? contextText?.length ?? 0) > maxTextCharacters) {
      throw const CaptureFailure('tooLarge');
    }
    final folder = Directory('${root.path}/$captureId');
    await root.create(recursive: true);
    await _safeFolder(folder);
    await folder.create(recursive: true);
    await _safeFolder(folder);
    var receipt = File('${folder.path}/ready.json');
    final committed = File('${folder.path}/committed.json');
    if (await committed.exists()) receipt = committed;
    if (await receipt.exists()) {
      if (await receipt.length() > 512 * 1024) {
        throw const CaptureFailure('invalid');
      }
      final saved = StoredOriginal.fromJson(
        jsonDecode(await receipt.readAsString()) as Map<String, dynamic>,
      );
      if (saved.captureId != captureId) throw const CaptureFailure('invalid');
      if (saved.scope != scope) throw const CaptureFailure('accountChanged');
      if (!await file(saved.relativePath).exists()) {
        throw const CaptureFailure('unavailable');
      }
      return saved;
    }
    final pending = File('${folder.path}/pending.json');
    if (await pending.exists()) {
      if (await pending.length() > 512 * 1024) {
        throw const CaptureFailure('invalid');
      }
      final previous =
          jsonDecode(await pending.readAsString()) as Map<String, dynamic>;
      if (previous['scope'] != scope) {
        throw const CaptureFailure('accountChanged');
      }
    }
    await pending.writeAsString(
      jsonEncode({
        'scope': scope,
        'name': name,
        'origin': origin,
        'text': text ?? contextText,
        'isText': text != null,
      }),
      flush: true,
    );
    final part = File('${folder.path}/original.part');
    final output = await part.open(mode: FileMode.write);
    final digest = _DigestSink();
    final hash = sha256.startChunkedConversion(digest);
    var size = 0;
    final header = <int>[];
    try {
      await for (final chunk in bytes) {
        size += chunk.length;
        if (size > maxOriginalBytes) throw const CaptureFailure('tooLarge');
        if (header.length < 32) header.addAll(chunk.take(32 - header.length));
        hash.add(chunk);
        await output.writeFrom(chunk);
      }
      await output.flush();
    } finally {
      await output.close();
      hash.close();
    }
    if (size == 0) throw const CaptureFailure('invalid');
    final mime = detectMime(header, text: text != null);
    if (mime == null) throw const CaptureFailure('unsupported');
    await part.rename('${folder.path}/original');
    final stored = StoredOriginal(
      captureId: captureId,
      scope: scope,
      name: name.trim().isEmpty
          ? captureId
          : name
                .replaceAll(RegExp(r'[/\\\x00-\x1f]'), '_')
                .substring(0, name.length.clamp(0, 512)),
      mime: mime,
      size: size,
      hash: digest.value!.toString(),
      relativePath: '$captureId/original',
      origin: origin,
      createdAt: DateTime.now().toUtc(),
      text: text ?? contextText,
    );
    await writeReceipt(stored);
    await pending.delete();
    return stored;
  }

  Future<void> acknowledge(StoredOriginal original) async {
    final ready = File('${root.path}/${original.captureId}/ready.json');
    if (await ready.exists()) {
      await ready.rename('${root.path}/${original.captureId}/committed.json');
    }
  }

  Future<void> writeReceipt(StoredOriginal original) async {
    final temp = File('${root.path}/${original.captureId}/ready.part');
    await temp.writeAsString(jsonEncode(original.toJson()), flush: true);
    await temp.rename('${root.path}/${original.captureId}/ready.json');
  }

  Future<List<StoredOriginal>> recover(String scope) async {
    recoveryFailures.clear();
    if (!await root.exists()) return [];
    final recovered = <StoredOriginal>[];
    await for (final entry in root.list(followLinks: false)) {
      if (entry is! Directory) continue;
      final id = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (!captureIdPattern.hasMatch(id)) continue;
      try {
        await _safeFolder(entry);
        final ready = File('${entry.path}/ready.json');
        final pending = File('${entry.path}/pending.json');
        if (!await ready.exists() &&
            await pending.exists() &&
            await File('${entry.path}/original').exists()) {
          if (await pending.length() > 512 * 1024) {
            throw const CaptureFailure('invalid');
          }
          final metadata =
              jsonDecode(await pending.readAsString()) as Map<String, dynamic>;
          if (metadata['scope'] != scope) continue;
          final original = File('${entry.path}/original');
          final size = await original.length();
          if (size < 1 || size > maxOriginalBytes) continue;
          final input = await original.open();
          final header = await input.read(32);
          await input.close();
          final mime = detectMime(
            header,
            text: metadata['isText'] as bool? ?? metadata['text'] != null,
          );
          if (mime == null) continue;
          final hash = await sha256.bind(original.openRead()).first;
          await writeReceipt(
            StoredOriginal(
              captureId: id,
              scope: scope,
              name: metadata['name'] as String,
              mime: mime,
              size: size,
              hash: hash.toString(),
              relativePath: '$id/original',
              origin: metadata['origin'] as String,
              createdAt: (await original.stat()).modified.toUtc(),
              text: metadata['text'] as String?,
            ),
          );
        }
        if (await ready.exists()) {
          if (await ready.length() > 512 * 1024) {
            throw const CaptureFailure('invalid');
          }
          final data = StoredOriginal.fromJson(
            jsonDecode(await ready.readAsString()) as Map<String, dynamic>,
          );
          if (data.captureId != id) throw const CaptureFailure('invalid');
          if (data.scope == scope && await file(data.relativePath).exists()) {
            final original = file(data.relativePath);
            if (await original.length() != data.size ||
                (await sha256.bind(original.openRead()).first).toString() !=
                    data.hash) {
              throw const CaptureFailure('invalid');
            }
            recovered.add(data);
          }
        }
      } on Object {
        recoveryFailures.add(id);
      }
    }
    return recovered;
  }

  Future<void> _safeFolder(Directory folder) async {
    if (await FileSystemEntity.type(folder.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const CaptureFailure('invalid');
    }
    if (await folder.exists()) {
      final base = await root.resolveSymbolicLinks();
      if (!(await folder.resolveSymbolicLinks()).startsWith(
        '$base${Platform.pathSeparator}',
      )) {
        throw const CaptureFailure('invalid');
      }
      for (final name in [
        'ready.json',
        'committed.json',
        'pending.json',
        'ready.part',
        'original',
        'original.part',
        'thumbnail',
      ]) {
        final path = '${folder.path}/$name';
        if (await FileSystemEntity.type(path, followLinks: false) ==
            FileSystemEntityType.link) {
          throw const CaptureFailure('invalid');
        }
      }
    }
  }

  static String? detectMime(List<int> header, {bool text = false}) {
    if (text) return 'text/plain';
    bool starts(List<int> magic) =>
        header.length >= magic.length &&
        List.generate(
          magic.length,
          (i) => header[i] == magic[i],
        ).every((v) => v);
    if (starts([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) {
      return 'image/png';
    }
    if (starts([0xff, 0xd8, 0xff])) return 'image/jpeg';
    if (starts(utf8.encode('%PDF-'))) return 'application/pdf';
    if (header.length >= 12 &&
        ascii.decode(header.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(header.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      return 'image/webp';
    }
    if (header.length >= 12 &&
        ascii.decode(header.sublist(4, 8), allowInvalid: true) == 'ftyp' &&
        {
          'heic',
          'heix',
          'hevc',
          'hevx',
          'mif1',
        }.contains(ascii.decode(header.sublist(8, 12), allowInvalid: true))) {
      return 'image/heic';
    }
    return null;
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? value;
  @override
  void add(Digest data) => value = data;
  @override
  void close() {}
}
