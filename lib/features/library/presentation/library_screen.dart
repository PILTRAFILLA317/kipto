import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/library_query.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/saved_item_card.dart';
import 'package:kipto/core/providers/time_provider.dart';
import 'package:kipto/features/library/presentation/providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(libraryItemsProvider);
    final counts = ref.watch(libraryCountsProvider);
    final query = ref.watch(libraryQueryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          PopupMenuButton<LibrarySort>(
            tooltip: 'Sort library',
            initialValue: query.sort,
            icon: const Icon(Icons.sort),
            onSelected: (sort) =>
                ref.read(libraryQueryProvider.notifier).state = LibraryQuery(
                  filter: query.filter,
                  sort: sort,
                ),
            itemBuilder: (_) => LibrarySort.values
                .map(
                  (sort) => PopupMenuItem(value: sort, child: Text(sort.label)),
                )
                .toList(),
          ),
          IconButton(
            tooltip: query.filter.isActive ? 'Edit active filters' : 'Filter',
            onPressed: () => _showFilters(context, ref, query),
            icon: Badge(
              isLabelVisible: query.filter.isActive,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: counts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(libraryCountsProvider),
        ),
        data: (value) => ContentWidth(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Text(
                    '${value.total} ${value.total == 1 ? 'item' : 'items'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    children: [
                      _QuickFilterChip(
                        label: 'All ${value.total}',
                        selected: !query.filter.isActive,
                        onSelected: () =>
                            _setFilter(ref, query, const LibraryFilter()),
                      ),
                      _QuickFilterChip(
                        label: 'Unprocessed ${value.unprocessed}',
                        selected:
                            query.filter.analysisStatus ==
                            AnalysisStatus.unprocessed,
                        onSelected: () => _setFilter(
                          ref,
                          query,
                          query.filter.copyWith(
                            analysisStatus: AnalysisStatus.unprocessed,
                            clearCategory: true,
                            clearStatus: true,
                          ),
                        ),
                      ),
                      ...SavedItemCategory.values.map(
                        (category) => _QuickFilterChip(
                          label:
                              '${category.label} ${value.byCategory[category] ?? 0}',
                          icon: category.icon,
                          selected: query.filter.category == category,
                          onSelected: () => _setFilter(
                            ref,
                            query,
                            query.filter.copyWith(
                              category: category,
                              clearAnalysisStatus: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (query.filter.isActive)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _filterSummary(query.filter),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _setFilter(ref, query, const LibraryFilter()),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ),
              items.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: AsyncErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(libraryItemsProvider),
                  ),
                ),
                data: (visible) => visible.isEmpty
                    ? const SliverFillRemaining(child: _EmptyLibraryFilter())
                    : SliverPadding(
                        padding: AppLayout.screenPadding(),
                        sliver: SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, index) => SavedItemCard(
                            item: visible[index],
                            variant: SavedItemCardVariant.compact,
                            now: ref.watch(currentTimeProvider),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setFilter(WidgetRef ref, LibraryQuery query, LibraryFilter filter) =>
      ref.read(libraryQueryProvider.notifier).state = LibraryQuery(
        filter: filter,
        sort: query.sort,
      );

  Future<void> _showFilters(
    BuildContext context,
    WidgetRef ref,
    LibraryQuery query,
  ) async {
    final selected = await showModalBottomSheet<LibraryFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _LibraryFilterSheet(initial: query.filter),
    );
    if (selected == null) return;
    _setFilter(ref, query, selected);
  }

  String _filterSummary(LibraryFilter filter) {
    final labels = <String>[
      if (filter.category != null) filter.category!.label,
      if (filter.status != null) filter.status!.label,
      if (filter.analysisStatus != null) filter.analysisStatus!.label,
      if (filter.favoriteOnly) 'Favorites',
    ];
    return labels.join(' · ');
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: AppSpacing.xs),
    child: FilterChip(
      avatar: icon == null ? null : Icon(icon, size: 17),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    ),
  );
}

class _LibraryFilterSheet extends StatefulWidget {
  const _LibraryFilterSheet({required this.initial});

  final LibraryFilter initial;

  @override
  State<_LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<_LibraryFilterSheet> {
  late SavedItemCategory? category = widget.initial.category;
  late SavedItemStatus? status = widget.initial.status;
  late AnalysisStatus? analysisStatus = widget.initial.analysisStatus;
  late bool favoriteOnly = widget.initial.favoriteOnly;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter library', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<SavedItemCategory?>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any category')),
              ...SavedItemCategory.values.map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              ),
            ],
            onChanged: (value) => setState(() => category = value),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<SavedItemStatus?>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any status')),
              ...SavedItemStatus.values.map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              ),
            ],
            onChanged: (value) => setState(() => status = value),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<AnalysisStatus?>(
            initialValue: analysisStatus,
            decoration: const InputDecoration(labelText: 'Analysis status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any analysis')),
              ...AnalysisStatus.values.map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              ),
            ],
            onChanged: (value) => setState(() => analysisStatus = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Favorites only'),
            value: favoriteOnly,
            onChanged: (value) => setState(() => favoriteOnly = value),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, const LibraryFilter()),
                child: const Text('Clear'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  LibraryFilter(
                    category: category,
                    status: status,
                    analysisStatus: analysisStatus,
                    favoriteOnly: favoriteOnly,
                  ),
                ),
                child: const Text('Show results'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _EmptyLibraryFilter extends StatelessWidget {
  const _EmptyLibraryFilter();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_alt_off_outlined, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No items match these filters',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text('Try removing a filter to broaden the library.'),
        ],
      ),
    ),
  );
}

extension on LibrarySort {
  String get label => switch (this) {
    LibrarySort.newest => 'Newest',
    LibrarySort.oldest => 'Oldest',
    LibrarySort.expiringSoon => 'Expiring soon',
    LibrarySort.recentlyUpdated => 'Recently updated',
  };
}
