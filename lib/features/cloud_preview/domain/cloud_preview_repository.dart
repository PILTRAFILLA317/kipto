import 'dart:typed_data';

import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';

abstract interface class CloudPreviewRepository {
  Future<void> upload({required String path, required CloudPreview preview});
  Future<Uint8List> download(String path);
  Future<void> delete(Iterable<String> paths);
  Future<bool> exists(String path);
}
