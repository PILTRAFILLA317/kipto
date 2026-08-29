import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/reminders.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.attachedDatabase);

  Stream<List<ReminderRow>> watchForSavedItem(String savedItemId) =>
      (select(reminders)
            ..where(
              (reminder) =>
                  reminder.savedItemId.equals(savedItemId) &
                  reminder.deletedAt.isNull(),
            )
            ..orderBy([(reminder) => OrderingTerm.asc(reminder.remindAt)]))
          .watch();

  Future<List<ReminderRow>> futurePending(DateTime from) =>
      (select(reminders)
            ..where(
              (reminder) =>
                  reminder.deletedAt.isNull() &
                  reminder.completedAt.isNull() &
                  reminder.remindAt.isBiggerOrEqualValue(from),
            )
            ..orderBy([(reminder) => OrderingTerm.asc(reminder.remindAt)]))
          .get();

  Future<void> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<void> upsertReminder(RemindersCompanion reminder) =>
      into(reminders).insertOnConflictUpdate(reminder);

  Future<ReminderRow?> findById(String id) => (select(
    reminders,
  )..where((reminder) => reminder.id.equals(id))).getSingleOrNull();

  Future<int> updateFields(String id, RemindersCompanion fields) => (update(
    reminders,
  )..where((reminder) => reminder.id.equals(id))).write(fields);
}
