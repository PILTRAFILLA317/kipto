import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/presentation/widgets/saved_item_image.dart';
import 'package:kipto/core/utils/date_formatters.dart';

enum SavedItemCardVariant { standard, compact }

class SavedItemCard extends StatelessWidget {
  const SavedItemCard({
    super.key,
    required this.item,
    required this.now,
    this.variant = SavedItemCardVariant.standard,
    this.onPrimaryAction,
  });

  final SavedItem item;
  final SavedItemCardVariant variant;
  final DateTime now;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final compact = variant == SavedItemCardVariant.compact;
    final colors = Theme.of(context).colorScheme;
    final effectiveNow = now;
    final unprocessed = item.analysisStatus == AnalysisStatus.unprocessed;
    final subtitle = unprocessed
        ? formatRelativeDateTime(item.capturedAt, effectiveNow)
        : item.summary.isEmpty
        ? 'Captured ${formatRelativeDateTime(item.capturedAt, effectiveNow)}'
        : item.summary;
    return Card(
      key: ValueKey('saved-item-${item.id}'),
      child: InkWell(
        onTap: () => context.push('/item/${item.id}'),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SavedItemImage(
                item: item,
                variant: compact
                    ? SavedItemImageVariant.compact
                    : SavedItemImageVariant.standard,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (item.favorite)
                          Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: colors.primary,
                            semanticLabel: 'Favorite',
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusLabel(status: item.analysisStatus),
                        if (!unprocessed)
                          _MetadataLabel(label: item.category.singularLabel),
                        if (item.expiresAt != null)
                          _MetadataLabel(
                            label: formatExpiry(item.expiresAt!, effectiveNow),
                            emphasized: true,
                          )
                        else if (item.eventAt != null)
                          _MetadataLabel(
                            label: formatRelativeDate(
                              item.eventAt!,
                              effectiveNow,
                            ),
                          ),
                      ],
                    ),
                    if (!compact && item.availableActions.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TextButton.icon(
                        onPressed: onPrimaryAction,
                        icon: Icon(item.availableActions.first.icon, size: 18),
                        label: Text(item.availableActions.first.label),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final AnalysisStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      AnalysisStatus.unprocessed => colors.primary,
      AnalysisStatus.processing => colors.tertiary,
      AnalysisStatus.processed => colors.onSurfaceVariant,
      AnalysisStatus.needsReview => colors.tertiary,
      AnalysisStatus.failed => colors.error,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, size: 15, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          status.label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MetadataLabel extends StatelessWidget {
  const _MetadataLabel({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: emphasized ? colors.primary : colors.onSurfaceVariant,
        fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
