import 'dart:typed_data';

import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_repository.dart';

final class FakeCloudPreviewRepository implements CloudPreviewRepository {
  final Map<String, Uint8List> objects = {};
  int uploadCalls = 0;
  int downloadCalls = 0;
  int deleteCalls = 0;
  bool failUploads = false;
  bool failDownloads = false;
  Duration downloadDelay = Duration.zero;

  @override
  Future<void> upload({
    required String path,
    required CloudPreview preview,
  }) async {
    uploadCalls++;
    if (failUploads) throw const FakePreviewNetworkError();
    objects[path] = preview.bytes;
  }

  @override
  Future<Uint8List> download(String path) async {
    downloadCalls++;
    if (downloadDelay != Duration.zero) {
      await Future<void>.delayed(downloadDelay);
    }
    if (failDownloads) throw const FakePreviewNetworkError();
    final bytes = objects[path];
    if (bytes == null) throw StateError('Missing fake object');
    return bytes;
  }

  @override
  Future<void> delete(Iterable<String> paths) async {
    deleteCalls++;
    for (final path in paths) {
      objects.remove(path);
    }
  }

  @override
  Future<bool> exists(String path) async => objects.containsKey(path);
}

final class FakePreviewNetworkError implements Exception {
  const FakePreviewNetworkError();
}
