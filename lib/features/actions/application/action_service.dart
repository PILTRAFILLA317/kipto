import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/features/calendar/application/calendar_action_service.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

enum ActionOutcome {
  scheduled,
  savedNotScheduled,
  kept,
  calendarSaved,
  calendarOpened,
  cancelled,
  permissionDenied,
  unavailable,
  failed,
  busy,
}

class ActionService {
  ActionService({
    required this.repository,
    required this.scheduler,
    required this.mappings,
    required this.calendar,
  });
  final DriftLifeAdminRepository repository;
  final ReminderNotificationScheduler scheduler;
  final NotificationMappingStore mappings;
  final CalendarActionService calendar;
  final Set<String> _running = {};

  Future<ActionOutcome> confirm(
    String id,
    ActionPayload payload, {
    bool reopenCalendar = false,
  }) async {
    if (!_running.add(id)) return ActionOutcome.busy;
    try {
      final before = await repository.findAction(id);
      if (before == null) return ActionOutcome.failed;
      if (before.state == ActionState.accepted &&
          payload is EventPayload &&
          !reopenCalendar) {
        return before.executionState == ActionExecutionState.applied
            ? ActionOutcome.calendarSaved
            : ActionOutcome.calendarOpened;
      }
      await repository.accept(id, payload);
      final accepted = (await repository.findAction(id))!;
      if (accepted.ownerId != repository.coordinator.activeOwnerId) {
        return ActionOutcome.failed;
      }
      final confirmed = accepted.payload;
      if (confirmed is KeepPayload) return ActionOutcome.kept;
      if (confirmed is RemindPayload) {
        try {
          final permission = await scheduler.requestPermission();
          final scheduled =
              permission == NotificationPermissionStatus.granted &&
              (await scheduler.scheduledIds()).contains(id);
          await repository.recordExecution(
            id,
            scheduled
                ? ActionExecutionState.applied
                : ActionExecutionState.pending,
          );
          return scheduled
              ? ActionOutcome.scheduled
              : ActionOutcome.savedNotScheduled;
        } on Object {
          return ActionOutcome.savedNotScheduled;
        }
      }
      final event = confirmed as EventPayload;
      DateTime calendarInstant(CalendarDate date) =>
          DateTime.utc(date.year, date.month, date.day);
      final result = await calendar.present(
        CalendarEventDraft(
          title: accepted.title,
          startAt: event.allDay
              ? calendarInstant(event.startDate!)
              : event.start!,
          endAt: event.allDay
              ? calendarInstant(event.endDateExclusive!)
              : event.end!,
          allDay: event.allDay,
          location: event.location,
          timeZone: event.allDay ? 'UTC' : event.zone,
        ),
      );
      final execution = switch (result) {
        CalendarActionResult.saved => ActionExecutionState.applied,
        CalendarActionResult.launched =>
          ActionExecutionState.launchedUnconfirmed,
        _ => ActionExecutionState.failed,
      };
      if (result == CalendarActionResult.cancelled &&
          before.state == ActionState.accepted) {
        return ActionOutcome.cancelled;
      }
      await repository.recordExecution(
        id,
        execution,
        cancelled: result == CalendarActionResult.cancelled,
      );
      return switch (result) {
        CalendarActionResult.saved => ActionOutcome.calendarSaved,
        CalendarActionResult.launched => ActionOutcome.calendarOpened,
        CalendarActionResult.cancelled => ActionOutcome.cancelled,
        CalendarActionResult.permissionDenied => ActionOutcome.permissionDenied,
        CalendarActionResult.unavailable => ActionOutcome.unavailable,
        CalendarActionResult.failed => ActionOutcome.failed,
      };
    } on Object {
      return ActionOutcome.failed;
    } finally {
      _running.remove(id);
    }
  }
}
