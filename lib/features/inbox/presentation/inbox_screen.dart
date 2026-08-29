import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/saved_item_card.dart';
import 'package:kipto/features/inbox/domain/inbox_sections.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kipto'),
            Text(
              'Your screenshot inbox',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: items.when(
        loading: () => const _InboxLoading(),
        error: (error, _) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(inboxItemsProvider),
        ),
        data: (data) {
          if (data.isEmpty) return const _EmptyInbox();
          final sections = buildInboxSections(data, DateTime.now());
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: sections.length,
            itemBuilder: (context, index) =>
                _InboxSectionView(section: sections[index]),
          );
        },
      ),
    );
  }
}

class _InboxSectionView extends StatelessWidget {
  const _InboxSectionView({required this.section});

  final InboxSection section;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...section.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SavedItemCard(item: item),
          ),
        ),
      ],
    ),
  );
}

class _InboxLoading extends StatelessWidget {
  const _InboxLoading();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) => Container(
      height: 118,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 44),
          const SizedBox(height: 14),
          Text(
            'Your inbox is clear',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'New screenshot items that need attention will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
