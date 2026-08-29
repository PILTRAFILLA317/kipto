import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/utils/date_formatters.dart';

class SavedItemCard extends StatelessWidget {
  const SavedItemCard({super.key, required this.item});

  final SavedItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateLabel = item.expiresAt != null
        ? 'Expires ${formatLocalDate(item.expiresAt!)}'
        : item.eventAt != null
        ? formatLocalDate(item.eventAt!)
        : null;
    return Card(
      key: ValueKey('saved-item-${item.id}'),
      child: InkWell(
        onTap: () => context.push('/item/${item.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.category.icon,
                  color: colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
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
                    const SizedBox(height: 5),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetadataLabel(label: item.category.singularLabel),
                        if (dateLabel != null)
                          _MetadataLabel(
                            label: dateLabel,
                            emphasized: item.expiresAt != null,
                          ),
                        if (item.availableActions.isNotEmpty)
                          _MetadataLabel(
                            label: item.availableActions.first.label,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
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
