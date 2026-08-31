import 'dart:io';

import 'package:kipto/features/cloud_preview/domain/cloud_preview_generator.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:photo_manager/photo_manager.dart';

final class PhotoManagerCloudPreviewGenerator implements CloudPreviewGenerator {
  const PhotoManagerCloudPreviewGenerator();

  @override
  Future<CloudPreview?> generate(String localAssetId) async {
    final asset = await AssetEntity.fromId(localAssetId);
    if (asset == null) return null;
    final dimensions = CloudPreviewSizing.calculate(
      asset.orientatedWidth,
      asset.orientatedHeight,
    );
    var bytes = await asset.thumbnailDataWithOption(
      _options(dimensions, quality: 80),
    );
    if (bytes == null || bytes.isEmpty) return null;
    if (bytes.lengthInBytes > 1500000) {
      bytes = await asset.thumbnailDataWithOption(
        _options(dimensions, quality: 68),
      );
    }
    if (bytes == null || bytes.isEmpty) return null;
    return CloudPreview(
      bytes: bytes,
      mimeType: 'image/jpeg',
      width: dimensions.width,
      height: dimensions.height,
    );
  }

  ThumbnailOption _options(
    CloudPreviewDimensions dimensions, {
    required int quality,
  }) {
    final size = ThumbnailSize(dimensions.width, dimensions.height);
    if (Platform.isIOS || Platform.isMacOS) {
      return ThumbnailOption.ios(
        size: size,
        format: ThumbnailFormat.jpeg,
        quality: quality,
        resizeMode: ResizeMode.exact,
        resizeContentMode: ResizeContentMode.fit,
      );
    }
    return ThumbnailOption(
      size: size,
      format: ThumbnailFormat.jpeg,
      quality: quality,
    );
  }
}
