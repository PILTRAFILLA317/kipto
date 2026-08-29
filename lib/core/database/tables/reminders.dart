import 'package:drift/drift.dart';
import 'package:kipto/core/database/tables/saved_items.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

@DataClassName('ReminderRow')
@TableIndex(name: 'reminders_saved_item_idx', columns: {#savedItemId})
@TableIndex(name: 'reminders_remind_at_idx', columns: {#remindAt})
@TableIndex(name: 'reminders_deleted_at_idx', columns: {#deletedAt})
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get savedItemId => text().references(SavedItems, #id)();
  DateTimeColumn get remindAt => dateTime()();
  TextColumn get kind => text().map(const ReminderKindConverter())();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
