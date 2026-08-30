import 'dart:io';
import 'dart:math' as math;

import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:kipto/features/analysis/domain/analysis_image_preparation_service.dart';
import 'package:photo_manager/photo_manager.dart';

final class PhotoManagerAnalysisImagePreparationService
    implements AnalysisImagePreparationService {
  const PhotoManagerAnalysisImagePreparationService({
    this.maxPreparedBytes = 4 * 1000 * 1000,
  });

  final int maxPreparedBytes;

  @override
  Future<PreparedAnalysisImage> prepare(String localAssetId) async {
    try {
      final entity = await AssetEntity.fromId(localAssetId);
      if (entity == null) {
        throw const AnalysisFailure(
          code: AnalysisErrorCode.noLocalAsset,
          retryable: false,
        );
      }
      final aspectRatio =
          entity.orientatedHeight <= 0 || entity.orientatedWidth <= 0
          ? 2.0
          : entity.orientatedHeight / entity.orientatedWidth;
      final attempts = <({int width, int maxHeight, int quality})>[
        (width: 1280, maxHeight: 4096, quality: 82),
        (width: 1080, maxHeight: 3584, quality: 72),
        (width: 900, maxHeight: 3072, quality: 62),
      ];
      for (final attempt in attempts) {
        final targetHeight = math.min(
          attempt.maxHeight,
          math.max(1, (attempt.width * aspectRatio).round()),
        );
        final size = ThumbnailSize(attempt.width, targetHeight);
        final option = Platform.isIOS || Platform.isMacOS
            ? ThumbnailOption.ios(
                size: size,
                format: ThumbnailFormat.jpeg,
                quality: attempt.quality,
                resizeMode: ResizeMode.exact,
                resizeContentMode: ResizeContentMode.fit,
              )
            : ThumbnailOption(
                size: size,
                format: ThumbnailFormat.jpeg,
                quality: attempt.quality,
              );
        final bytes = await entity.thumbnailDataWithOption(option);
        if (bytes == null || bytes.isEmpty) continue;
        if (bytes.length <= maxPreparedBytes) {
          return PreparedAnalysisImage(
            bytes: bytes,
            mimeType: 'image/jpeg',
            width: attempt.width,
            height: targetHeight,
          );
        }
      }
      throw const AnalysisFailure(
        code: AnalysisErrorCode.payloadTooLarge,
        retryable: false,
      );
    } on AnalysisFailure {
      rethrow;
    } on Object {
      throw const AnalysisFailure(
        code: AnalysisErrorCode.imagePreparationFailed,
        retryable: true,
      );
    }
  }
}
