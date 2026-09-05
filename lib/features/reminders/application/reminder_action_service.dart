// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';

final class ReminderActionService {
  ReminderActionService({
    required RemindersRepository reminders,
    required ReminderNotificationScheduler notifications,
    Clock? clock,
  }) : _reminders = reminders,
       _notifications = notifications,
       _clock = clock ?? const Clock();

  final RemindersRepository _reminders;
  final ReminderNotificationScheduler _notifications;
  final Clock _clock;

  Future<Reminder> create({
    required String itemId,
    required DateTime remindAt,
  }) async {
    if (!remindAt.toUtc().isAfter(_clock.now().toUtc())) {
      throw ArgumentError.value(remindAt, 'remindAt', 'must be in the future');
    }
    final reminder = await _reminders.create(
      itemId: itemId,
      remindAt: remindAt,
    );
    await _notifications.reconcile();
    return reminder;
  }

  Future<void> edit(Reminder reminder, DateTime remindAt) async {
    await _reminders.edit(reminder.id, remindAt);
    await _notifications.reconcile();
  }

  Future<void> complete(Reminder reminder) async {
    await _reminders.complete(reminder.id);
    await _notifications.reconcile();
  }

  Future<void> delete(Reminder reminder) async {
    await _reminders.delete(reminder.id);
    await _notifications.reconcile();
  }
}
