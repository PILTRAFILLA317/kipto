import 'dart:typed_data';

abstract interface class CloudPreviewCache {
  Future<String?> lookup({
    required String savedItemId,
    required String cloudPath,
  });
  Future<String> store({
    required String savedItemId,
    required String cloudPath,
    required Uint8List bytes,
  });
  Future<void> clear();
}

final class InvalidCloudPreviewException implements Exception {
  const InvalidCloudPreviewException(this.code);
  final String code;
}
