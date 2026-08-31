// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:kipto/core/repositories/saved_items_repository.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

final class ReminderActionService {
  ReminderActionService({
    required RemindersRepository reminders,
    required SavedItemsRepository savedItems,
    required ReminderNotificationScheduler notifications,
    Clock? clock,
  }) : _reminders = reminders,
       _savedItems = savedItems,
       _notifications = notifications,
       _clock = clock ?? const Clock();

  final RemindersRepository _reminders;
  final SavedItemsRepository _savedItems;
  final ReminderNotificationScheduler _notifications;
  final Clock _clock;

  Future<ActionExecutionResult> create({
    required SavedItem item,
    required DateTime remindAt,
    ReminderKind kind = ReminderKind.custom,
  }) async {
    if (!remindAt.toUtc().isAfter(_clock.now().toUtc())) {
      return const ActionExecutionResult.invalidData(
        'Choose a reminder time in the future.',
      );
    }
    try {
      await _reminders.create(
        savedItemId: item.id,
        remindAt: remindAt,
        kind: kind,
      );
      await _savedItems.markActionCompleted(
        item.id,
        SavedItemActionType.createReminder,
      );
    } on Object {
      return const ActionExecutionResult.failed(
        message: "Couldn't save this reminder",
        errorCode: 'reminder_save_failed',
      );
    }

    try {
      var permission = await _notifications.permissionStatus();
      if (permission == NotificationPermissionStatus.notDetermined) {
        permission = await _notifications.requestPermission();
      } else {
        await _notifications.reconcile();
      }
      if (permission != NotificationPermissionStatus.granted) {
        return const ActionExecutionResult.permissionDenied(
          'Reminder saved, but notifications are disabled.',
        );
      }
      return const ActionExecutionResult.success('Reminder created');
    } on Object {
      return const ActionExecutionResult.success(
        'Reminder saved, but its notification could not be scheduled yet.',
      );
    }
  }

  Future<ActionExecutionResult> edit(Reminder reminder, DateTime remindAt) =>
      _change(
        operation: () => _reminders.edit(reminder.id, remindAt),
        success: 'Reminder updated',
      );

  Future<ActionExecutionResult> complete(Reminder reminder) => _change(
    operation: () => _reminders.complete(reminder.id),
    success: 'Reminder completed',
  );

  Future<ActionExecutionResult> delete(Reminder reminder) => _change(
    operation: () => _reminders.delete(reminder.id),
    success: 'Reminder deleted',
  );

  Future<ActionExecutionResult> _change({
    required Future<void> Function() operation,
    required String success,
  }) async {
    try {
      await operation();
      await _notifications.reconcile();
      return ActionExecutionResult.success(success);
    } on Object {
      return const ActionExecutionResult.failed(
        message: "Couldn't update this reminder",
        errorCode: 'reminder_update_failed',
      );
    }
  }
}
