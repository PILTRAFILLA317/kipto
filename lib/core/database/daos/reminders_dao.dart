import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/reminders.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Stream<List<ReminderRow>> watchForItem(String itemId) =>
      (select(reminders)
            ..where((row) => row.itemId.equals(itemId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.remindAt)]))
          .watch();

  Future<ReminderRow?> findById(String id, {bool includeDeleted = true}) {
    final query = select(reminders)..where((row) => row.id.equals(id));
    if (!includeDeleted) query.where((row) => row.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  Future<List<ReminderRow>> findByIds(Iterable<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(reminders)..where((row) => row.id.isIn(ids))).get();
  }

  Future<void> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insertOnConflictUpdate(reminder);

  Future<void> updateFields(String id, RemindersCompanion reminder) =>
      (update(reminders)..where((row) => row.id.equals(id))).write(reminder);
}
