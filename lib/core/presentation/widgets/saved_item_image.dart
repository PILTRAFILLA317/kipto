import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/features/photo_library/presentation/widgets/local_asset_thumbnail.dart';

enum SavedItemImageVariant { compact, standard, detail }

class SavedItemImage extends StatelessWidget {
  const SavedItemImage({
    super.key,
    required this.item,
    this.variant = SavedItemImageVariant.standard,
    this.allowFullscreen = false,
  });

  final SavedItem item;
  final SavedItemImageVariant variant;
  final bool allowFullscreen;

  @override
  Widget build(BuildContext context) {
    final image = switch (variant) {
      SavedItemImageVariant.compact => _thumbnail(
        width: AppThumbnailSize.compactWidth,
        height: AppThumbnailSize.compactHeight,
        requestWidth: 180,
        requestHeight: 240,
      ),
      SavedItemImageVariant.standard => _thumbnail(
        width: AppThumbnailSize.standardWidth,
        height: AppThumbnailSize.standardHeight,
        requestWidth: 240,
        requestHeight: 320,
      ),
      SavedItemImageVariant.detail => ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 220,
          maxHeight: AppThumbnailSize.detailMaxHeight,
        ),
        child: _thumbnail(
          width: double.infinity,
          height: AppThumbnailSize.detailMaxHeight,
          requestWidth: 1200,
          requestHeight: 1800,
          fit: BoxFit.contain,
          detailedFallback: true,
        ),
      ),
    };
    if (!allowFullscreen ||
        item.localAssetId == null ||
        !item.originalAvailable) {
      return image;
    }
    return Semantics(
      button: true,
      label: 'Open screenshot fullscreen',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () => showDialog<void>(
          context: context,
          barrierColor: Colors.black,
          builder: (_) => _ScreenshotViewer(item: item),
        ),
        child: image,
      ),
    );
  }

  Widget _thumbnail({
    required double width,
    required double height,
    required int requestWidth,
    required int requestHeight,
    BoxFit fit = BoxFit.cover,
    bool detailedFallback = false,
  }) {
    final assetId = item.localAssetId;
    if (assetId == null) {
      return _ImagePlaceholder(
        width: width,
        height: height,
        icon: item.category.icon,
        message: detailedFallback
            ? 'Screenshot unavailable on this device'
            : null,
      );
    }
    return LocalAssetThumbnail(
      localAssetId: assetId,
      originalAvailable: item.originalAvailable,
      requestWidth: requestWidth,
      requestHeight: requestHeight,
      width: width,
      height: height,
      fit: fit,
      missingMessage: detailedFallback
          ? "Original screenshot isn't available on this device."
          : null,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.width,
    required this.height,
    required this.icon,
    this.message,
  });

  final double width;
  final double height;
  final IconData icon;
  final String? message;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: message == null ? 24 : 36),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(message!, textAlign: TextAlign.center),
        ],
      ],
    ),
  );
}

class _ScreenshotViewer extends StatelessWidget {
  const _ScreenshotViewer({required this.item});

  final SavedItem item;

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
    backgroundColor: Colors.black,
    child: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: LocalAssetThumbnail(
                  localAssetId: item.localAssetId!,
                  originalAvailable: item.originalAvailable,
                  requestWidth: 1800,
                  requestHeight: 2600,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.zero,
                  missingMessage: 'Screenshot unavailable on this device',
                ),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: IconButton.filled(
              tooltip: 'Close screenshot',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    ),
  );
}
