import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/domain/policies/date_presets.dart';
import 'package:kipto/core/presentation/saved_item_display.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/saved_item_image.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/providers/time_provider.dart';
import 'package:kipto/core/utils/date_formatters.dart';
import 'package:kipto/features/saved_item/presentation/providers/saved_item_providers.dart';
import 'package:kipto/features/analysis/presentation/providers/analysis_providers.dart';

class SavedItemDetailScreen extends ConsumerStatefulWidget {
  const SavedItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<SavedItemDetailScreen> createState() =>
      _SavedItemDetailScreenState();
}

class _SavedItemDetailScreenState extends ConsumerState<SavedItemDetailScreen> {
  Future<void> _run(
    Future<void> Function() operation, {
    String? success,
  }) async {
    try {
      await operation();
      if (!mounted || success == null) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save that change. Try again.')),
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
      data: (value) =>
          value == null ? const _MissingItemScreen() : _detail(value),
    );
  }

  Widget _detail(SavedItem item) {
    final repository = ref.read(savedItemsRepositoryProvider);
    final now = ref.watch(currentTimeProvider);
    final aiEnabled = ref.watch(aiAnalysisPreferencesProvider).enabled;
    final aiServerConfigured = ref.watch(aiServerConfiguredProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved item'),
        actions: [
          IconButton(
            tooltip: item.favorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () => _run(() => repository.toggleFavorite(item.id)),
            icon: Icon(item.favorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: ContentWidth(
        child: ListView(
          padding: AppLayout.screenPadding(bottom: AppSpacing.xxl),
          children: [
            SavedItemImage(
              item: item,
              variant: SavedItemImageVariant.detail,
              allowFullscreen: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            _EditableHeading(
              item: item,
              onEditTitle: () => _editTitle(item),
              onEditCategory: () => _editCategory(item),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Captured ${formatRelativeDateTime(item.capturedAt, now)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (item.analysisStatus != AnalysisStatus.processed)
              _AnalysisPanel(
                item: item,
                aiEnabled: aiEnabled,
                serverConfigured: aiServerConfigured,
                onAnalyze: () => _reanalyze(item),
              ),
            if (item.summary.isNotEmpty)
              _DetailSection(title: 'Summary', child: Text(item.summary)),
            if (item.analysisStatus == AnalysisStatus.processed)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed:
                      item.originalAvailable && aiEnabled && aiServerConfigured
                      ? () => _reanalyze(item)
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Re-analyze'),
                ),
              ),
            if (item.availableActions.isNotEmpty)
              _PrimaryAction(
                action: item.availableActions.first,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This action will be available soon'),
                  ),
                ),
              ),
            if (item.intent?.isNotEmpty ?? false)
              _DetailSection(
                title: 'What you meant to do',
                child: Text(item.intent!),
              ),
            _DatesSection(item: item, now: now),
            if (item.location?.isNotEmpty ?? false)
              _DetailSection(
                title: 'Location',
                child: _IconValue(
                  icon: Icons.place_outlined,
                  value: item.location!,
                ),
              ),
            _NotesSection(item: item, onEdit: () => _editNote(item)),
            if (item.detectedEntities.isNotEmpty)
              _DetectedInformation(entities: item.detectedEntities),
            _RemindersSection(itemId: item.id, run: _run),
            _StatusActions(
              item: item,
              onRestore: () => _run(
                () => repository.restore(item.id),
                success: 'Restored to Inbox',
              ),
              onDone: () => _run(
                () => repository.markDone(item.id),
                success: 'Marked as done',
              ),
              onArchive: () =>
                  _run(() => repository.archive(item.id), success: 'Archived'),
              onSnooze: () => _chooseSnooze(item),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _confirmDelete(item),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete from Kipto'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reanalyze(SavedItem item) async {
    if (!item.originalAvailable || item.localAssetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Original screenshot unavailable')),
      );
      return;
    }
    if (!ref.read(aiAnalysisPreferencesProvider).enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable AI analysis in Settings first.')),
      );
      return;
    }
    if (!ref.read(aiServerConfiguredProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI analysis is not configured')),
      );
      return;
    }
    await ref.read(analysisQueueRunnerProvider).retry(item.id);
  }

  Future<void> _editTitle(SavedItem item) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => _EditTitleDialog(initialTitle: item.title),
    );
    if (title == null || title == item.title) return;
    await _run(
      () => ref.read(savedItemsRepositoryProvider).updateTitle(item.id, title),
      success: 'Title updated',
    );
  }

  Future<void> _editCategory(SavedItem item) async {
    final category = await showModalBottomSheet<SavedItemCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Choose category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...SavedItemCategory.values.map(
              (value) => ListTile(
                leading: Icon(value.icon),
                title: Text(value.singularLabel),
                trailing: value == item.category
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => context.pop(value),
              ),
            ),
          ],
        ),
      ),
    );
    if (category == null || category == item.category) return;
    await _run(
      () => ref
          .read(savedItemsRepositoryProvider)
          .updateCategory(item.id, category),
      success: 'Category updated',
    );
  }

  Future<void> _editNote(SavedItem item) async {
    final result = await showDialog<_NoteEditResult>(
      context: context,
      builder: (context) => _EditNoteDialog(initialNote: item.userNote),
    );
    if (result == null) return;
    final note = result.note;
    if (note == item.userNote) return;
    await _run(
      () => ref.read(savedItemsRepositoryProvider).updateNote(item.id, note),
      success: note.isNotEmpty ? 'Note saved' : 'Note removed',
    );
  }

  Future<void> _chooseSnooze(SavedItem item) async {
    final preset = await _showDatePresetSheet(
      title: 'Snooze until',
      includeWeekend: true,
    );
    if (preset == null) return;
    final date = preset == DatePreset.custom
        ? await _pickDateTime()
        : DatePresetPolicy.resolve(preset, ref.read(currentTimeProvider));
    if (date == null) return;
    await _run(
      () => ref.read(savedItemsRepositoryProvider).snooze(item.id, date),
      success:
          'Snoozed until ${formatRelativeDateTime(date, ref.read(currentTimeProvider))}',
    );
  }

  Future<DatePreset?> _showDatePresetSheet({
    required String title,
    required bool includeWeekend,
  }) => showModalBottomSheet<DatePreset>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          _PresetTile(
            icon: Icons.schedule,
            label: 'Later today',
            onTap: () => context.pop(DatePreset.laterToday),
          ),
          _PresetTile(
            icon: Icons.today_outlined,
            label: 'Tomorrow',
            onTap: () => context.pop(DatePreset.tomorrow),
          ),
          if (includeWeekend)
            _PresetTile(
              icon: Icons.weekend_outlined,
              label: 'This weekend',
              onTap: () => context.pop(DatePreset.thisWeekend),
            ),
          _PresetTile(
            icon: Icons.date_range_outlined,
            label: 'Next week',
            onTap: () => context.pop(DatePreset.nextWeek),
          ),
          _PresetTile(
            icon: Icons.edit_calendar_outlined,
            label: 'Choose date and time',
            onTap: () => context.pop(DatePreset.custom),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    ),
  );

  Future<DateTime?> _pickDateTime() async {
    final now = ref.read(currentTimeProvider).toLocal();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
  }

  Future<void> _confirmDelete(SavedItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete from Kipto?'),
        content: const Text(
          'This removes the item from Kipto. The original screenshot will stay '
          'in your photo library.',
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
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete this item.')),
      );
    }
  }
}

class _EditTitleDialog extends StatefulWidget {
  const _EditTitleDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_EditTitleDialog> createState() => _EditTitleDialogState();
}

class _EditTitleDialogState extends State<_EditTitleDialog> {
  late final TextEditingController controller = TextEditingController(
    text: widget.initialTitle,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = controller.text.trim();
    if (value.isNotEmpty) context.pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit title'),
    content: TextField(
      controller: controller,
      autofocus: true,
      maxLength: 160,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(labelText: 'Title'),
      onSubmitted: (_) => _save(),
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );
}

class _EditNoteDialog extends StatefulWidget {
  const _EditNoteDialog({this.initialNote});

  final String? initialNote;

  @override
  State<_EditNoteDialog> createState() => _EditNoteDialogState();
}

final class _NoteEditResult {
  const _NoteEditResult(this.note);

  final String note;
}

class _EditNoteDialogState extends State<_EditNoteDialog> {
  late final TextEditingController controller = TextEditingController(
    text: widget.initialNote,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.initialNote == null ? 'Add note' : 'Edit note'),
    content: TextField(
      controller: controller,
      autofocus: true,
      minLines: 3,
      maxLines: 7,
      maxLength: 2000,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(hintText: 'Why did you save this?'),
    ),
    actions: [
      if (widget.initialNote != null)
        TextButton(
          onPressed: () => context.pop(const _NoteEditResult('')),
          child: const Text('Remove note'),
        ),
      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
      FilledButton(
        onPressed: () => context.pop(_NoteEditResult(controller.text.trim())),
        child: const Text('Save'),
      ),
    ],
  );
}

class _EditableHeading extends StatelessWidget {
  const _EditableHeading({
    required this.item,
    required this.onEditTitle,
    required this.onEditCategory,
  });

  final SavedItem item;
  final VoidCallback onEditTitle;
  final VoidCallback onEditCategory;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          IconButton(
            tooltip: 'Edit title',
            onPressed: onEditTitle,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          ActionChip(
            avatar: Icon(item.category.icon, size: 17),
            label: Text(item.category.singularLabel),
            onPressed: onEditCategory,
          ),
          Chip(label: Text(item.status.label)),
          if (item.subtype?.isNotEmpty ?? false)
            Chip(label: Text(item.subtype!)),
          if (item.relevance == AnalysisRelevance.expired ||
              item.relevance == AnalysisRelevance.obsolete)
            Chip(
              avatar: const Icon(Icons.history_toggle_off, size: 17),
              label: Text(
                item.relevance == AnalysisRelevance.expired
                    ? 'Expired'
                    : 'Possibly outdated',
              ),
            ),
        ],
      ),
    ],
  );
}

class _AnalysisPanel extends StatelessWidget {
  const _AnalysisPanel({
    required this.item,
    required this.aiEnabled,
    required this.serverConfigured,
    required this.onAnalyze,
  });

  final SavedItem item;
  final bool aiEnabled;
  final bool serverConfigured;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = item.analysisStatus;
    final message = !item.originalAvailable
        ? 'Original screenshot unavailable'
        : !serverConfigured
        ? 'AI analysis is not configured.'
        : switch (status) {
            AnalysisStatus.unprocessed =>
              "Kipto hasn't analyzed this screenshot yet.",
            AnalysisStatus.processing => 'Kipto is analyzing this screenshot.',
            AnalysisStatus.needsReview => "Kipto isn't sure about this screenshot. Review the title and category.",
            AnalysisStatus.failed =>
              'Analysis failed. You can safely try again.',
            AnalysisStatus.processed => '',
          };
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status == AnalysisStatus.failed
            ? colors.errorContainer
            : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(message),
                if (status != AnalysisStatus.processing &&
                    item.originalAvailable) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: aiEnabled && serverConfigured ? onAnalyze : null,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      status == AnalysisStatus.unprocessed
                          ? 'Analyze'
                          : 'Try again',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.action, required this.onPressed});

  final SavedItemActionType action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(action.icon),
      label: Text(action.label),
    ),
  );
}

class _DatesSection extends StatelessWidget {
  const _DatesSection({required this.item, required this.now});

  final SavedItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) => _DetailSection(
    title: 'Dates',
    child: Column(
      children: [
        _DetailRow(
          label: 'Captured',
          value: formatRelativeDateTime(item.capturedAt, now),
        ),
        if (item.eventAt != null)
          _DetailRow(
            label: 'Event',
            value: formatRelativeDateTime(item.eventAt!, now),
          ),
        if (item.expiresAt != null)
          _DetailRow(
            label: 'Expires',
            value: formatExpiry(item.expiresAt!, now),
          ),
        if (item.snoozedUntil != null)
          _DetailRow(
            label: 'Snoozed until',
            value: formatRelativeDateTime(item.snoozedUntil!, now),
          ),
      ],
    ),
  );
}

class _DetectedInformation extends StatelessWidget {
  const _DetectedInformation({required this.entities});

  final Map<String, Object?> entities;

  @override
  Widget build(BuildContext context) => _DetailSection(
    title: 'Detected information',
    child: Column(
      children: entities.entries
          .where(
            (entry) => entry.value != null && entry.value.toString().isNotEmpty,
          )
          .map(
            (entry) => _DetailRow(
              label: _humanize(entry.key),
              value: entry.value.toString(),
            ),
          )
          .toList(),
    ),
  );

  String _humanize(String value) => value
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .replaceAll('_', ' ')
      .trim();
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.item, required this.onEdit});

  final SavedItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => _DetailSection(
    title: 'Notes',
    child: item.userNote == null
        ? OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Add note'),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(item.userNote!)),
              IconButton(
                tooltip: 'Edit note',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note_outlined),
              ),
            ],
          ),
  );
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({
    required this.item,
    required this.onRestore,
    required this.onDone,
    required this.onArchive,
    required this.onSnooze,
  });

  final SavedItem item;
  final VoidCallback onRestore;
  final VoidCallback onDone;
  final VoidCallback onArchive;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) => _DetailSection(
    title: 'Status',
    child: Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (item.status == SavedItemStatus.archived)
          FilledButton.tonalIcon(
            onPressed: onRestore,
            icon: const Icon(Icons.unarchive_outlined),
            label: const Text('Restore to Inbox'),
          )
        else if (item.status == SavedItemStatus.done)
          FilledButton.tonalIcon(
            onPressed: onRestore,
            icon: const Icon(Icons.undo),
            label: const Text('Mark as not done'),
          )
        else ...[
          FilledButton.tonalIcon(
            onPressed: onDone,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark as done'),
          ),
          OutlinedButton.icon(
            onPressed: onSnooze,
            icon: const Icon(Icons.snooze),
            label: const Text('Snooze'),
          ),
          OutlinedButton.icon(
            onPressed: onArchive,
            icon: const Icon(Icons.archive_outlined),
            label: const Text('Archive'),
          ),
        ],
      ],
    ),
  );
}

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection({required this.itemId, required this.run});

  final String itemId;
  final Future<void> Function(
    Future<void> Function() operation, {
    String? success,
  })
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
            error: (_, _) => const Text('Could not load reminders.'),
            data: (items) => items.isEmpty
                ? const Text('No reminders yet.')
                : Column(
                    children: items
                        .map(
                          (reminder) => _ReminderTile(
                            reminder: reminder,
                            now: ref.watch(currentTimeProvider),
                            onComplete: reminder.completedAt == null
                                ? () => run(
                                    () => repository.complete(reminder.id),
                                    success: 'Reminder completed',
                                  )
                                : null,
                            onDelete: () => run(
                              () => repository.delete(reminder.id),
                              success: 'Reminder deleted',
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonalIcon(
            onPressed: () => _addReminder(context, ref),
            icon: const Icon(Icons.add_alert_outlined),
            label: const Text('Add reminder'),
          ),
        ],
      ),
    );
  }

  Future<void> _addReminder(BuildContext context, WidgetRef ref) async {
    final preset = await showModalBottomSheet<DatePreset>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Add reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _PresetTile(
              icon: Icons.schedule,
              label: 'Later today',
              onTap: () => context.pop(DatePreset.laterToday),
            ),
            _PresetTile(
              icon: Icons.today_outlined,
              label: 'Tomorrow',
              onTap: () => context.pop(DatePreset.tomorrow),
            ),
            _PresetTile(
              icon: Icons.date_range_outlined,
              label: 'Next week',
              onTap: () => context.pop(DatePreset.nextWeek),
            ),
            _PresetTile(
              icon: Icons.edit_calendar_outlined,
              label: 'Choose date and time',
              onTap: () => context.pop(DatePreset.custom),
            ),
          ],
        ),
      ),
    );
    if (preset == null || !context.mounted) return;
    DateTime? date;
    if (preset == DatePreset.custom) {
      final now = ref.read(currentTimeProvider).toLocal();
      final chosen = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(now.year + 5),
        initialDate: now.add(const Duration(days: 1)),
      );
      if (chosen == null || !context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (time == null) return;
      date = DateTime(
        chosen.year,
        chosen.month,
        chosen.day,
        time.hour,
        time.minute,
      ).toUtc();
    } else {
      date = DatePresetPolicy.resolve(preset, ref.read(currentTimeProvider));
    }
    await run(() async {
      await ref
          .read(remindersRepositoryProvider)
          .create(savedItemId: itemId, remindAt: date!);
    }, success: 'Reminder added');
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.now,
    required this.onComplete,
    required this.onDelete,
  });

  final Reminder reminder;
  final DateTime now;
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
    title: Text(formatRelativeDateTime(reminder.remindAt, now)),
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

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
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
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
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

class _IconValue extends StatelessWidget {
  const _IconValue({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20),
      const SizedBox(width: AppSpacing.xs),
      Expanded(child: Text(value)),
    ],
  );
}

class _MissingItemScreen extends StatelessWidget {
  const _MissingItemScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_remove_outlined, size: 42),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Saved item not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('It may have been removed from Kipto.'),
          ],
        ),
      ),
    ),
  );
}
