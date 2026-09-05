import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';

final class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(activeItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kipto')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Kipto could not open your local inbox.')),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No items yet. Kipto is ready for the next Life Admin phase.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => ListTile(
                  title: Text(items[index].title),
                  subtitle: items[index].summary.isEmpty
                      ? null
                      : Text(items[index].summary),
                ),
              ),
      ),
    );
  }
}
