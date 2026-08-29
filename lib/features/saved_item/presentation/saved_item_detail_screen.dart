import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/utils/date_formatters.dart';
import 'package:kipto/features/saved_item/presentation/providers/saved_item_providers.dart';

class SavedItemDetailScreen extends ConsumerStatefulWidget {
  const SavedItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<SavedItemDetailScreen> createState() =>
      _SavedItemDetailScreenState();
}

class _SavedItemDetailScreenState extends ConsumerState<SavedItemDetailScreen> {
  Future<void> _run(Future<void> Function() operation, String success) async {
    try {
      await operation();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not complete the action: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(savedItemProvider(widget.itemId));
    return item.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(savedItemProvider(widget.itemId)),
        ),
      ),
      data: (value) => value == null
          ? const _MissingItemScreen()
          : _buildDetail(context, value),
    );
  }

  Widget _buildDetail(BuildContext context, SavedItem item) {
    final savedItems = ref.read(savedItemsRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved item'),
        actions: [
          IconButton(
            tooltip: item.favorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () => _run(
              () => savedItems.toggleFavorite(item.id),
              item.favorite ? 'Removed from favorites' : 'Added to favorites',
            ),
            icon: Icon(item.favorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const _ScreenshotPlaceholder(),
          const SizedBox(height: 24),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            item.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(item.category.icon, size: 18),
                label: Text(item.category.singularLabel),
              ),
              Chip(label: Text(item.status.label)),
              if (item.subtype != null) Chip(label: Text(item.subtype!)),
            ],
          ),
          const SizedBox(height: 24),
          _DetailSection(
            title: 'What you meant to do',
            child: Text(item.intent ?? 'No intent captured yet.'),
          ),
          _DetailSection(
            title: 'Relevant dates',
            child: Column(
              children: [
                _DetailRow(
                  label: 'Captured',
                  value: formatLocalDateTime(item.capturedAt),
                ),
                if (item.eventAt != null)
                  _DetailRow(
                    label: 'Event',
                    value: formatLocalDateTime(item.eventAt!),
                  ),
                if (item.expiresAt != null)
                  _DetailRow(
                    label: 'Expires',
                    value: formatLocalDateTime(item.expiresAt!),
                  ),
                if (item.snoozedUntil != null)
                  _DetailRow(
                    label: 'Snoozed until',
                    value: formatLocalDateTime(item.snoozedUntil!),
                  ),
              ],
            ),
          ),
          _DetailSection(
            title: 'Available actions',
            child: item.availableActions.isEmpty
                ? const Text('No actions suggested.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.availableActions
                            .map(
                              (action) => ActionChip(
                                avatar: const Icon(Icons.lock_clock, size: 16),
                                label: Text(action.label),
                                tooltip:
                                    'External integration is not enabled yet',
                                onPressed: null,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'External integrations are intentionally disabled in local mode.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
          _DetailSection(
            title: 'Local actions',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: item.status == SavedItemStatus.done
                      ? null
                      : () => _run(
                          () => savedItems.markDone(item.id),
                          'Marked as done',
                        ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark done'),
                ),
                FilledButton.tonalIcon(
                  onPressed: item.status == SavedItemStatus.archived
                      ? null
                      : () =>
                            _run(() => savedItems.archive(item.id), 'Archived'),
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archive'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _run(
                    () => savedItems.snooze(
                      item.id,
                      DateTime.now().toUtc().add(const Duration(days: 1)),
                    ),
                    'Snoozed until tomorrow',
                  ),
                  icon: const Icon(Icons.snooze),
                  label: const Text('Snooze 1 day'),
                ),
              ],
            ),
          ),
          _RemindersSection(itemId: item.id, run: _run),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmDelete(item),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete item'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(SavedItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this saved item?'),
        content: const Text(
          'It will disappear from Kipto. The record is kept as a soft delete '
          'so a future sync layer can propagate the change.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(savedItemsRepositoryProvider).softDelete(item.id);
      if (mounted) context.pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete the item: $error')),
      );
    }
  }
}

class _ScreenshotPlaceholder extends StatelessWidget {
  const _ScreenshotPlaceholder();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Screenshot preview unavailable in this phase',
    child: Container(
      height: 210,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 40),
          SizedBox(height: 10),
          Text('Screenshot preview will appear here'),
        ],
      ),
    ),
  );
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection({required this.itemId, required this.run});

  final String itemId;
  final Future<void> Function(Future<void> Function() operation, String success)
  run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(itemRemindersProvider(itemId));
    final repository = ref.read(remindersRepositoryProvider);
    return _DetailSection(
      title: 'Reminders',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reminders.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Could not load reminders: $error'),
            data: (items) => items.isEmpty
                ? const Text('No local reminders yet.')
                : Column(
                    children: items
                        .map(
                          (reminder) => _ReminderTile(
                            reminder: reminder,
                            onComplete: reminder.completedAt == null
                                ? () => run(
                                    () => repository.complete(reminder.id),
                                    'Reminder completed',
                                  )
                                : null,
                            onDelete: () => run(
                              () => repository.delete(reminder.id),
                              'Reminder deleted',
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: () => run(() async {
              await repository.create(
                savedItemId: itemId,
                remindAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
              );
            }, 'Reminder created for two hours from now'),
            icon: const Icon(Icons.add_alert_outlined),
            label: const Text('Remind me in 2 hours'),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.onComplete,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      reminder.completedAt == null
          ? Icons.notifications_active_outlined
          : Icons.check_circle_outline,
    ),
    title: Text(formatLocalDateTime(reminder.remindAt)),
    subtitle: Text(reminder.completedAt == null ? 'Pending' : 'Completed'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onComplete != null)
          IconButton(
            tooltip: 'Complete reminder',
            onPressed: onComplete,
            icon: const Icon(Icons.check),
          ),
        IconButton(
          tooltip: 'Delete reminder',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
  );
}

class _MissingItemScreen extends StatelessWidget {
  const _MissingItemScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 42),
            const SizedBox(height: 12),
            Text(
              'Saved item not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'It may have been deleted or this link is no longer valid.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
