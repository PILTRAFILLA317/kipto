import 'package:drift/drift.dart';
import 'package:kipto/core/database/tables/items.dart';
import 'package:kipto/core/database/tables/life_admin.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

@DataClassName('ReminderRow')
@TableIndex(name: 'reminders_item_idx', columns: {#itemId})
@TableIndex(name: 'reminders_remind_at_idx', columns: {#remindAt})
@TableIndex(name: 'reminders_deleted_at_idx', columns: {#deletedAt})
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get actionId => text().nullable().references(ItemActions, #id)();
  TextColumn get title => text().nullable()();
  TextColumn get timeZone => text().nullable()();
  DateTimeColumn get remindAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get remoteServerUpdatedAt => dateTime().nullable()();
  TextColumn get sourceDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
