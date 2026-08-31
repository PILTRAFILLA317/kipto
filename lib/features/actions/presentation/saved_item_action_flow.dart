import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/domain/policies/date_presets.dart';
import 'package:kipto/core/providers/time_provider.dart';
import 'package:kipto/features/actions/application/saved_item_action_executor.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/actions/domain/calendar_event_draft.dart';
import 'package:kipto/features/actions/presentation/action_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

Future<ActionExecutionResult?> runSavedItemActionFlow({
  required BuildContext context,
  required WidgetRef ref,
  required SavedItem item,
  required SavedItemActionType action,
}) async {
  CalendarEventDraft? calendarDraft;
  DateTime? remindAt;
  String? copyValue;
  var allowCalendarDuplicate = false;

  if (action == SavedItemActionType.addCalendar) {
    if (item.hasCompletedAction(action)) {
      final repeat = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add another event?'),
          content: const Text(
            "You've already added this from Kipto. Kipto can't read your "
            'calendar to check whether that event still exists.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add another'),
            ),
          ],
        ),
      );
      if (repeat != true || !context.mounted) return null;
      allowCalendarDuplicate = true;
    }
    var draft = const CalendarEventDraftBuilder().fromSavedItem(item);
    if (draft == null) {
      final edit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Event date needed'),
          content: const Text(
            'Kipto needs a date before this can be added to Calendar. '
            'You can enter the event details now.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Edit event details'),
            ),
          ],
        ),
      );
      if (edit != true || !context.mounted) return null;
      final now = ref.read(currentTimeProvider).toLocal();
      final start = DateTime(now.year, now.month, now.day + 1, 9);
      draft = CalendarEventDraft(
        title: item.title,
        startAt: start,
        endAt: start.add(const Duration(hours: 1)),
        allDay: false,
        location: item.location,
        notes: item.summary,
      );
    }
    calendarDraft = await showModalBottomSheet<CalendarEventDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CalendarDraftSheet(initial: draft!),
    );
    if (calendarDraft == null || !context.mounted) return null;
  } else if (action == SavedItemActionType.createReminder) {
    remindAt = await _chooseReminderTime(context, ref, item);
    if (remindAt == null || !context.mounted) return null;
  } else if (action == SavedItemActionType.copyCode) {
    final candidates = ref
        .read(clipboardActionServiceProvider)
        .candidates(item);
    if (candidates.length > 1) {
      copyValue = await showModalBottomSheet<String>(
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
                  'Choose code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final candidate in candidates)
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: Text(candidate.label),
                  subtitle: Text(candidate.value),
                  onTap: () => Navigator.pop(context, candidate.value),
                ),
            ],
          ),
        ),
      );
      if (copyValue == null || !context.mounted) return null;
    }
  }

  final result = await ref
      .read(savedItemActionExecutorProvider)
      .execute(
        SavedItemActionRequest(
          item: item,
          action: action,
          calendarDraft: calendarDraft,
          remindAt: remindAt,
          copyValue: copyValue,
          allowCalendarDuplicate: allowCalendarDuplicate,
        ),
      );
  if (!context.mounted) return result;
  ref.invalidate(notificationPermissionStatusProvider);
  ref.invalidate(scheduledReminderCountProvider);
  _showResult(context, ref, action, result);
  return result;
}

void _showResult(
  BuildContext context,
  WidgetRef ref,
  SavedItemActionType action,
  ActionExecutionResult result,
) {
  final message = result.message;
  if (message == null ||
      (result.status == ActionExecutionStatus.cancelled && message.isEmpty)) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action:
          result.status == ActionExecutionStatus.permissionDenied &&
              action == SavedItemActionType.createReminder
          ? SnackBarAction(
              label: 'Settings',
              onPressed: () => ref
                  .read(reminderNotificationSchedulerProvider)
                  .openSettings(),
            )
          : null,
    ),
  );
}

enum _ReminderChoice {
  laterToday,
  tomorrow,
  weekend,
  nextWeek,
  beforeExpiry,
  beforeEvent,
  custom,
}

Future<DateTime?> _chooseReminderTime(
  BuildContext context,
  WidgetRef ref,
  SavedItem item,
) async {
  final now = ref.read(currentTimeProvider);
  final beforeExpiry = item.expiresAt?.subtract(const Duration(days: 1));
  final beforeEvent = item.eventAt?.subtract(const Duration(days: 1));
  final choice = await showModalBottomSheet<_ReminderChoice>(
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
              'Remind me',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _ChoiceTile(
            icon: Icons.schedule,
            label: 'Later today',
            value: _ReminderChoice.laterToday,
          ),
          _ChoiceTile(
            icon: Icons.today_outlined,
            label: 'Tomorrow',
            value: _ReminderChoice.tomorrow,
          ),
          _ChoiceTile(
            icon: Icons.weekend_outlined,
            label: 'This weekend',
            value: _ReminderChoice.weekend,
          ),
          _ChoiceTile(
            icon: Icons.date_range_outlined,
            label: 'Next week',
            value: _ReminderChoice.nextWeek,
          ),
          if (beforeExpiry?.isAfter(now) == true)
            _ChoiceTile(
              icon: Icons.timer_outlined,
              label: 'Before it expires',
              value: _ReminderChoice.beforeExpiry,
            ),
          if (beforeEvent?.isAfter(now) == true)
            _ChoiceTile(
              icon: Icons.event_outlined,
              label: 'Before the event',
              value: _ReminderChoice.beforeEvent,
            ),
          _ChoiceTile(
            icon: Icons.edit_calendar_outlined,
            label: 'Custom…',
            value: _ReminderChoice.custom,
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return null;
  return switch (choice) {
    _ReminderChoice.laterToday => DatePresetPolicy.resolve(
      DatePreset.laterToday,
      now,
    ),
    _ReminderChoice.tomorrow => DatePresetPolicy.resolve(
      DatePreset.tomorrow,
      now,
    ),
    _ReminderChoice.weekend => DatePresetPolicy.resolve(
      DatePreset.thisWeekend,
      now,
    ),
    _ReminderChoice.nextWeek => DatePresetPolicy.resolve(
      DatePreset.nextWeek,
      now,
    ),
    _ReminderChoice.beforeExpiry => beforeExpiry,
    _ReminderChoice.beforeEvent => beforeEvent,
    _ReminderChoice.custom => _pickDateTime(context, now),
  };
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime now) async {
  final local = now.toLocal();
  final date = await showDatePicker(
    context: context,
    firstDate: DateTime(local.year, local.month, local.day),
    lastDate: DateTime(local.year + 5),
    initialDate: local.add(const Duration(days: 1)),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final _ReminderChoice value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    onTap: () => Navigator.pop(context, value),
  );
}

class _CalendarDraftSheet extends StatefulWidget {
  const _CalendarDraftSheet({required this.initial});

  final CalendarEventDraft initial;

  @override
  State<_CalendarDraftSheet> createState() => _CalendarDraftSheetState();
}

class _CalendarDraftSheetState extends State<_CalendarDraftSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initial.title,
  );
  late final TextEditingController _location = TextEditingController(
    text: widget.initial.location,
  );
  late DateTime _start = widget.initial.startAt.toLocal();
  late int _durationMinutes = widget.initial.endAt
      .difference(widget.initial.startAt)
      .inMinutes
      .clamp(30, 1440);
  late bool _allDay = widget.initial.allDay;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _start,
    );
    if (date == null) return;
    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        _start.hour,
        _start.minute,
      );
    });
  }

  Future<void> _chooseTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (value == null) return;
    setState(() {
      _start = DateTime(
        _start.year,
        _start.month,
        _start.day,
        value.hour,
        value.minute,
      );
    });
  }

  void _continue() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final start = _allDay
        ? DateTime(_start.year, _start.month, _start.day)
        : _start;
    final end = _allDay
        ? start.add(const Duration(days: 1))
        : start.add(Duration(minutes: _durationMinutes));
    Navigator.pop(
      context,
      CalendarEventDraft(
        title: title,
        startAt: start,
        endAt: end,
        allDay: _allDay,
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        notes: widget.initial.notes,
        url: widget.initial.url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final end = _start.add(Duration(minutes: _durationMinutes));
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to Calendar',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              subtitle: Text(localizations.formatMediumDate(_start)),
              onTap: _chooseDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All day'),
              value: _allDay,
              onChanged: (value) => setState(() => _allDay = value),
            ),
            if (!_allDay) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: const Text('Starts'),
                subtitle: Text(
                  localizations.formatTimeOfDay(TimeOfDay.fromDateTime(_start)),
                ),
                onTap: _chooseTime,
              ),
              DropdownButtonFormField<int>(
                initialValue: _durationMinutes,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  DropdownMenuItem(value: 60, child: Text('1 hour')),
                  DropdownMenuItem(value: 120, child: Text('2 hours')),
                  DropdownMenuItem(value: 180, child: Text('3 hours')),
                  DropdownMenuItem(value: 1440, child: Text('24 hours')),
                ],
                onChanged: (value) => setState(
                  () => _durationMinutes = value ?? _durationMinutes,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ends ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(end))}',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Continue to Calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
