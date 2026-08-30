import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/saved_item_card.dart';
import 'package:kipto/core/providers/time_provider.dart';
import 'package:kipto/features/search/presentation/providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim();
    final results = ref.watch(searchResultsProvider(normalized));
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ContentWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: SearchBar(
                controller: _controller,
                hintText: 'Search your screenshots',
                leading: const Icon(Icons.search),
                trailing: [
                  if (normalized.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => _setQuery(''),
                      icon: const Icon(Icons.close),
                    ),
                ],
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: normalized.isEmpty
                  ? _SearchPrompt(onCategory: _setQuery)
                  : results.when(
                      loading: () => const Center(
                        child: SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (error, _) => AsyncErrorView(
                        error: error,
                        onRetry: () =>
                            ref.invalidate(searchResultsProvider(normalized)),
                      ),
                      data: (items) => items.isEmpty
                          ? _NoResults(query: normalized)
                          : ListView.separated(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: AppLayout.screenPadding(),
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (_, index) => SavedItemCard(
                                item: items[index],
                                variant: SavedItemCardVariant.compact,
                                now: ref.watch(currentTimeProvider),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.onCategory});

  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.manage_search, size: 48),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Search your screenshots',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Titles, summaries, categories, intent, and detected details are '
          'searched locally—even offline.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          alignment: WrapAlignment.center,
          children:
              const [
                    SavedItemCategory.event,
                    SavedItemCategory.place,
                    SavedItemCategory.product,
                    SavedItemCategory.order,
                  ]
                  .map(
                    (category) => ActionChip(
                      avatar: Icon(category.icon, size: 17),
                      label: Text(category.label),
                      onPressed: () => onCategory(category.name),
                    ),
                  )
                  .toList(),
        ),
      ],
    ),
  );
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_outlined, size: 42),
          const SizedBox(height: AppSpacing.sm),
          Text('Nothing found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No saved item matches “$query”. Try a shorter phrase or category.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
