import 'package:drift/drift.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

@DataClassName('ItemRow')
@TableIndex(name: 'items_status_idx', columns: {#status})
@TableIndex(name: 'items_updated_at_idx', columns: {#updatedAt})
@TableIndex(name: 'items_deleted_at_idx', columns: {#deletedAt})
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get status => text().map(const ItemStatusConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get remoteServerUpdatedAt => dateTime().nullable()();
  TextColumn get sourceDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
