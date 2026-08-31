import 'dart:math' as math;

import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';

abstract interface class CloudPreviewGenerator {
  Future<CloudPreview?> generate(String localAssetId);
}

final class CloudPreviewDimensions {
  const CloudPreviewDimensions(this.width, this.height);
  final int width;
  final int height;
}

abstract final class CloudPreviewSizing {
  static const int maxWidth = 900;
  static const int maxHeight = 8000;
  static const int maxPixels = 8000000;

  static CloudPreviewDimensions calculate(int width, int height) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Image dimensions must be positive');
    }
    var scale = 1.0;
    if (width > maxWidth) scale = maxWidth / width;
    if (height * scale > maxHeight) scale = maxHeight / height;
    final scaledPixels = width * height * scale * scale;
    if (scaledPixels > maxPixels) {
      scale *= math.sqrt(maxPixels / scaledPixels);
    }
    return CloudPreviewDimensions(
      (width * scale).round().clamp(1, maxWidth),
      (height * scale).round().clamp(1, maxHeight),
    );
  }
}
