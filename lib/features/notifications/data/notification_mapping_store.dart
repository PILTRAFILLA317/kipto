import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

final class NotificationMappingStore {
  const NotificationMappingStore(this._database);
  final AppDatabase _database;

  Future<List<NotificationMapping>> list() async =>
      (await _database
              .customSelect(
                'SELECT reminder_id, notification_id, scheduled_for, timezone FROM notification_mappings',
              )
              .get())
          .map(
            (row) => NotificationMapping(
              reminderId: row.read<String>('reminder_id'),
              notificationId: row.read<int>('notification_id'),
              scheduledFor: DateTime.parse(row.read<String>('scheduled_for'))
                  .toUtc(),
              timeZone: row.read<String>('timezone'),
            ),
          )
          .toList(growable: false);

  Future<List<ReminderScheduleCandidate>> nextCandidates({
    required DateTime after,
    required int limit,
  }) async =>
      (await _database
              .customSelect(
                '''
          SELECT r.id AS reminder_id, r.item_id, r.remind_at, i.title
          FROM reminders r
          INNER JOIN items i ON i.id = r.item_id
          WHERE r.deleted_at IS NULL
            AND r.completed_at IS NULL
            AND r.remind_at > ?
            AND i.deleted_at IS NULL
            AND i.status = ?
          ORDER BY r.remind_at ASC
          LIMIT ?
        ''',
                variables: [
                  Variable.withString(after.toUtc().toIso8601String()),
                  Variable.withString(ItemStatus.active.storageValue),
                  Variable.withInt(limit),
                ],
                readsFrom: {_database.reminders, _database.items},
              )
              .get())
          .map(
            (row) => ReminderScheduleCandidate(
              reminderId: row.read<String>('reminder_id'),
              itemId: row.read<String>('item_id'),
              remindAt: DateTime.parse(row.read<String>('remind_at')).toUtc(),
              itemTitle: row.read<String>('title'),
            ),
          )
          .toList(growable: false);

  Future<int> allocateNotificationId() async {
    final row = await _database
        .customSelect(
          'SELECT MAX(notification_id) AS max_id FROM notification_mappings',
        )
        .getSingle();
    final current = row.readNullable<int>('max_id') ?? 9999;
    if (current >= 2147483000) {
      throw StateError('No notification IDs available');
    }
    return current + 1;
  }

  Future<void> put(NotificationMapping mapping) => _database.customStatement(
    '''
          INSERT INTO notification_mappings (reminder_id, notification_id, scheduled_for, timezone)
          VALUES (?, ?, ?, ?)
          ON CONFLICT(reminder_id) DO UPDATE SET
            notification_id = excluded.notification_id,
            scheduled_for = excluded.scheduled_for,
            timezone = excluded.timezone
        ''',
    [
      mapping.reminderId,
      mapping.notificationId,
      mapping.scheduledFor.toUtc().toIso8601String(),
      mapping.timeZone,
    ],
  );

  Future<void> remove(String reminderId) => _database.customStatement(
    'DELETE FROM notification_mappings WHERE reminder_id = ?',
    [reminderId],
  );

  Future<int> count() async =>
      (await _database
              .customSelect(
                'SELECT COUNT(*) AS total FROM notification_mappings',
              )
              .getSingle())
          .read<int>('total');
}
