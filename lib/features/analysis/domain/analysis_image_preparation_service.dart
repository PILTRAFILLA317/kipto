import 'dart:typed_data';

final class PreparedAnalysisImage {
  const PreparedAnalysisImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;
}

abstract interface class AnalysisImagePreparationService {
  Future<PreparedAnalysisImage> prepare(String localAssetId);
}
