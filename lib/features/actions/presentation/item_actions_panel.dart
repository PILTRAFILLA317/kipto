import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/features/actions/presentation/action_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/features/actions/presentation/action_providers.dart';
import 'package:kipto/features/actions/presentation/action_review_sheet.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

final itemRemindersProvider = StreamProvider.family<List<Reminder>, String>(
  (ref, id) => ref.watch(remindersRepositoryProvider).watchForItem(id),
);
final scheduledReminderIdsProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(scheduledReminderCountProvider);
  return ref.watch(reminderNotificationSchedulerProvider).scheduledIds();
});

class ItemActionsPanel extends ConsumerStatefulWidget {
  const ItemActionsPanel({super.key, required this.item});
  final Item item;
  @override
  ConsumerState<ItemActionsPanel> createState() => _ItemActionsPanelState();
}

class _ItemActionsPanelState extends ConsumerState<ItemActionsPanel> {
  bool _busy = false;
  String? _message;
  ActionOutcome? _outcome;
  bool _beginAction() {
    if (_busy) return false;
    setState(() {
      _busy = true;
      _message = null;
      _outcome = null;
    });
    return true;
  }

  Future<void> _review(ItemAction action) async {
    if (!_beginAction()) return;
    try {
      final facts = await ref.read(itemFactsProvider(widget.item.id).future);
      if (!mounted) return;
      final outcome = await showModalBottomSheet<ActionOutcome>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => ActionReviewSheet(action: action, facts: facts),
      );
      if (mounted && outcome != null) {
        setState(() => _outcome = outcome);
      }
    } on Object {
      if (mounted) {
        setState(() => _message = AppLocalizations.of(context).lifecycleFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _manual(ActionKind kind) async {
    if (!_beginAction()) return;
    ItemAction? action;
    try {
      final now = DateTime.now().toUtc();
      final title = widget.item.title;
      action = ItemAction(
        id: const Uuid().v4(),
        itemId: widget.item.id,
        ownerId: widget.item.ownerId,
        title: title.length > 100 ? title.substring(0, 100) : title,
        payload: switch (kind) {
          ActionKind.remind => RemindPayload(),
          ActionKind.event => EventPayload(allDay: false),
          ActionKind.keep => const KeepPayload(),
        },
        origin: ActionOrigin.user,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(lifeAdminRepositoryProvider).propose(action);
    } on Object {
      if (mounted) {
        setState(() => _message = AppLocalizations.of(context).lifecycleFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted && action != null) await _review(action);
  }

  Future<void> _dismiss(String id) async {
    if (!_beginAction()) return;
    try {
      await ref.read(lifeAdminRepositoryProvider).dismiss(id);
    } on Object {
      if (mounted) {
        setState(() => _message = AppLocalizations.of(context).lifecycleFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(String id) async {
    if (!_beginAction()) return;
    final l = AppLocalizations.of(context);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.cancelReminder),
          content: Text(l.cancelReminderBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.cancelReminder),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      await ref.read(remindersRepositoryProvider).complete(id);
      if (mounted) ref.invalidate(scheduledReminderCountProvider);
    } on Object {
      if (mounted) setState(() => _message = l.lifecycleFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reopenCalendar(ItemAction action) async {
    if (!_beginAction()) return;
    final l = AppLocalizations.of(context);
    try {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.reopenCalendar),
          content: Text(l.reopenCalendarBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.reopenCalendar),
            ),
          ],
        ),
      );
      if (accepted != true || !mounted) return;
      final outcome = await ref
          .read(actionServiceProvider)
          .confirm(action.id, action.payload, reopenCalendar: true);
      if (mounted) setState(() => _outcome = outcome);
    } on Object {
      if (mounted) setState(() => _message = l.lifecycleFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final active = widget.item.status == ItemStatus.active;
    final actions = ref.watch(itemActionsProvider(widget.item.id));
    final reminders = ref.watch(itemRemindersProvider(widget.item.id));
    final scheduled = ref.watch(scheduledReminderIdsProvider).valueOrNull ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (active)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final pair in [
                (ActionKind.remind, l.remindAction),
                (ActionKind.event, l.eventAction),
                (ActionKind.keep, l.keepAction),
              ])
                OutlinedButton(
                  onPressed: _busy ? null : () => _manual(pair.$1),
                  child: Text(pair.$2),
                ),
            ],
          ),
        ...actions.when(
          loading: () => <Widget>[],
          error: (_, _) => [Text(l.localError)],
          data: (rows) => [
            for (final action in rows.where(
              (a) => a.state != ActionState.dismissed,
            ))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      action.state == ActionState.proposed
                          ? l.proposedAction
                          : action.payload.kind == ActionKind.event
                          ? action.executionState ==
                                    ActionExecutionState.applied
                                ? l.calendarSaved
                                : action.executionState ==
                                      ActionExecutionState.launchedUnconfirmed
                                ? l.calendarOpened
                                : l.calendarUnavailable
                          : l.acceptedAction,
                    ),
                    if (action.state == ActionState.proposed && active)
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: _busy ? null : () => _review(action),
                            child: Text(l.reviewAction),
                          ),
                          TextButton(
                            onPressed: _busy ? null : () => _dismiss(action.id),
                            child: Text(l.dismissProposal),
                          ),
                        ],
                      ),
                    if (action.state == ActionState.accepted &&
                        action.payload.kind == ActionKind.event)
                      TextButton(
                        onPressed: _busy ? null : () => _reopenCalendar(action),
                        child: Text(l.reopenCalendar),
                      ),
                  ],
                ),
              ),
          ],
        ),
        ...reminders.when(
          loading: () => <Widget>[],
          error: (_, _) => [Text(l.localError)],
          data: (rows) => [
            for (final reminder in rows)
              Builder(
                builder: (context) {
                  final date = tz.TZDateTime.from(
                    reminder.remindAt,
                    timeZoneLocation(reminder.timeZone ?? 'UTC'),
                  );
                  final future = reminder.remindAt.isAfter(
                    DateTime.now().toUtc(),
                  );
                  final pending = reminder.completedAt == null && active;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${DateFormat.yMMMMd(l.localeName).add_Hm().format(date)} · ${reminder.timeZone ?? 'UTC'}',
                    ),
                    subtitle: Text(
                      !pending
                          ? l.completedReminder
                          : scheduled.contains(reminder.id) && future
                          ? l.reminderScheduled
                          : l.reminderNotScheduled,
                    ),
                    trailing: pending
                        ? IconButton(
                            tooltip: l.cancelReminder,
                            onPressed: _busy
                                ? null
                                : () => _cancel(reminder.id),
                            icon: const Icon(Icons.notifications_off_outlined),
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Semantics(liveRegion: true, child: Text(_message!)),
          ),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppDurations.normal,
          layoutBuilder: (current, previous) =>
              current ?? const SizedBox.shrink(),
          child: _message != null || _outcome == null
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey(_outcome),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ActionFeedback(outcome: _outcome!),
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
