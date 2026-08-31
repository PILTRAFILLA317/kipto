import 'dart:io';
import 'dart:typed_data';

import 'package:kipto/features/cloud_preview/domain/cloud_preview_cache.dart';
import 'package:path_provider/path_provider.dart';

final class FileCloudPreviewCache implements CloudPreviewCache {
  FileCloudPreviewCache({
    Future<Directory> Function()? rootDirectory,
    this.maxBytes = 200 * 1024 * 1024,
    this.maxFileBytes = 15 * 1024 * 1024,
  }) : _rootDirectory = rootDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _rootDirectory;
  final int maxBytes;
  final int maxFileBytes;

  Future<Directory> _directory() async {
    final root = await _rootDirectory();
    final directory = Directory('${root.path}/kipto_preview_cache');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  File _file(Directory directory, String savedItemId, String cloudPath) {
    final safeId = savedItemId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
    return File('${directory.path}/$safeId-${_fnv1a(cloudPath)}.jpg');
  }

  @override
  Future<String?> lookup({
    required String savedItemId,
    required String cloudPath,
  }) async {
    final file = _file(await _directory(), savedItemId, cloudPath);
    if (!await file.exists()) return null;
    try {
      final bytes = await file.readAsBytes();
      _validate(bytes);
      await file.setLastModified(DateTime.now().toUtc());
      return file.path;
    } on Object {
      if (await file.exists()) await file.delete();
      return null;
    }
  }

  @override
  Future<String> store({
    required String savedItemId,
    required String cloudPath,
    required Uint8List bytes,
  }) async {
    _validate(bytes);
    final directory = await _directory();
    final file = _file(directory, savedItemId, cloudPath);
    await file.writeAsBytes(bytes, flush: true);
    await _evict(directory, excluding: file.path);
    return file.path;
  }

  void _validate(Uint8List bytes) {
    if (bytes.isEmpty) throw const InvalidCloudPreviewException('empty');
    if (bytes.lengthInBytes > maxFileBytes) {
      throw const InvalidCloudPreviewException('too_large');
    }
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff;
    final webp =
        bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
    if (!jpeg && !webp) {
      throw const InvalidCloudPreviewException('invalid_image');
    }
  }

  Future<void> _evict(Directory directory, {required String excluding}) async {
    final files = <({File file, FileStat stat})>[];
    var total = 0;
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      total += stat.size;
      files.add((file: entity, stat: stat));
    }
    if (total <= maxBytes) return;
    files.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
    for (final entry in files) {
      if (total <= maxBytes) break;
      if (entry.file.path == excluding) continue;
      await entry.file.delete();
      total -= entry.stat.size;
    }
  }

  @override
  Future<void> clear() async {
    final directory = await _directory();
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  String _fnv1a(String value) {
    var hash = 2166136261;
    for (final byte in value.codeUnits) {
      hash ^= byte;
      hash = (hash * 16777619) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
