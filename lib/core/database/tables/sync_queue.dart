import 'package:drift/drift.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

@DataClassName('SyncQueueRow')
@TableIndex(name: 'sync_queue_created_at_idx', columns: {#createdAt})
@TableIndex(name: 'sync_queue_entity_idx', columns: {#entityType, #entityId})
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text().map(const SyncEntityTypeConverter())();
  TextColumn get entityId => text()();
  TextColumn get operation => text().map(const SyncOperationConverter())();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
