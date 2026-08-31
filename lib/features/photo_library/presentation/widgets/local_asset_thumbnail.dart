import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';

class LocalAssetThumbnail extends ConsumerWidget {
  const LocalAssetThumbnail({
    super.key,
    required this.localAssetId,
    required this.originalAvailable,
    required this.requestWidth,
    required this.requestHeight,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.missingMessage,
    this.fallback,
  });

  final String localAssetId;
  final bool originalAvailable;
  final int requestWidth;
  final int requestHeight;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final String? missingMessage;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!originalAvailable) {
      if (fallback != null) return fallback!;
      return _ThumbnailFallback(
        width: width,
        height: height,
        borderRadius: borderRadius,
        message:
            missingMessage ??
            'Original screenshot is no longer available on this device',
      );
    }
    final thumbnail = ref.watch(
      localAssetThumbnailProvider((
        id: localAssetId,
        width: requestWidth,
        height: requestHeight,
      )),
    );
    return thumbnail.when(
      loading: () => _ThumbnailLoading(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
      error: (_, _) =>
          fallback ??
          _ThumbnailFallback(
            width: width,
            height: height,
            borderRadius: borderRadius,
            message: missingMessage,
          ),
      data: (data) => data == null
          ? fallback ??
                _ThumbnailFallback(
                  width: width,
                  height: height,
                  borderRadius: borderRadius,
                  message: missingMessage,
                )
          : ClipRRect(
              borderRadius: borderRadius,
              child: Image.memory(
                data.bytes,
                width: width,
                height: height,
                fit: fit,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) =>
                    fallback ??
                    _ThumbnailFallback(
                      width: width,
                      height: height,
                      borderRadius: borderRadius,
                      message: missingMessage,
                    ),
              ),
            ),
    );
  }
}

class _ThumbnailLoading extends StatelessWidget {
  const _ThumbnailLoading({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: borderRadius,
    ),
    alignment: Alignment.center,
    child: const SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.message,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final String? message;

  @override
  Widget build(BuildContext context) => Semantics(
    label: message ?? 'Screenshot thumbnail unavailable',
    child: Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showMessage =
              message != null &&
              constraints.maxWidth >= 180 &&
              constraints.maxHeight >= 120;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined),
              if (showMessage) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    ),
  );
}
