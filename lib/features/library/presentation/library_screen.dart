import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/saved_item_card.dart';
import 'package:kipto/features/library/presentation/providers/library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  SavedItemCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(allSavedItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(allSavedItemsProvider),
        ),
        data: (allItems) {
          final active = allItems
              .where(
                (item) =>
                    item.status != SavedItemStatus.archived &&
                    item.status != SavedItemStatus.done,
              )
              .toList(growable: false);
          final counts = <SavedItemCategory, int>{};
          for (final item in active) {
            counts.update(
              item.category,
              (count) => count + 1,
              ifAbsent: () => 1,
            );
          }
          final visible = _selectedCategory == null
              ? active
              : active
                    .where((item) => item.category == _selectedCategory)
                    .toList(growable: false);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: _LibrarySummary(total: active.length),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('All ${active.length}'),
                          selected: _selectedCategory == null,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = null),
                        ),
                      ),
                      ...counts.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(entry.key.icon, size: 18),
                            label: Text('${entry.key.label} ${entry.value}'),
                            selected: _selectedCategory == entry.key,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = entry.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                const SliverFillRemaining(child: _EmptyCategory())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) =>
                        SavedItemCard(item: visible[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.collections_bookmark_outlined, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$total active items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Browse by category or open an item for details.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text('No active items in this category.'),
    ),
  );
}
