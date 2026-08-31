import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/features/photo_library/presentation/widgets/local_asset_thumbnail.dart';
import 'package:kipto/features/cloud_preview/presentation/cloud_preview_providers.dart';

enum SavedItemImageVariant { compact, standard, detail }

class SavedItemImage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final image = switch (variant) {
      SavedItemImageVariant.compact => _thumbnail(
        ref,
        width: AppThumbnailSize.compactWidth,
        height: AppThumbnailSize.compactHeight,
        requestWidth: 180,
        requestHeight: 240,
      ),
      SavedItemImageVariant.standard => _thumbnail(
        ref,
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
          ref,
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
        (!item.originalAvailable && item.cloudPreviewPath == null)) {
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

  Widget _thumbnail(
    WidgetRef ref, {
    required double width,
    required double height,
    required int requestWidth,
    required int requestHeight,
    BoxFit fit = BoxFit.cover,
    bool detailedFallback = false,
  }) {
    final fallback = _CloudPreviewImage(
      item: item,
      width: width,
      height: height,
      fit: fit,
      detailedFallback: detailedFallback,
    );
    final assetId = item.localAssetId;
    if (assetId == null || !item.originalAvailable) return fallback;
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
      fallback: fallback,
    );
  }
}

class _CloudPreviewImage extends ConsumerWidget {
  const _CloudPreviewImage({
    required this.item,
    required this.width,
    required this.height,
    required this.fit,
    required this.detailedFallback,
  });

  final SavedItem item;
  final double width;
  final double height;
  final BoxFit fit;
  final bool detailedFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudPath = item.cloudPreviewPath;
    final placeholder = _ImagePlaceholder(
      width: width,
      height: height,
      icon: Icons.broken_image_outlined,
      message: detailedFallback
          ? 'Screenshot preview unavailable on this device'
          : null,
    );
    if (cloudPath == null) return placeholder;
    final resolved = ref.watch(
      resolvedCloudPreviewProvider((
        savedItemId: item.id,
        cloudPath: cloudPath,
      )),
    );
    return resolved.when(
      loading: () => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: const SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => placeholder,
      data: (path) => path == null
          ? placeholder
          : ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Image.file(
                File(path),
                width: width,
                height: height,
                fit: fit,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => placeholder,
              ),
            ),
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

class _ScreenshotViewer extends ConsumerWidget {
  const _ScreenshotViewer({required this.item});

  final SavedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Dialog.fullscreen(
    backgroundColor: Colors.black,
    child: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: SavedItemImage(
                  item: item,
                  variant: SavedItemImageVariant.detail,
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
