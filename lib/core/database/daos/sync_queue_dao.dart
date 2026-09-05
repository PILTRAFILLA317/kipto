import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/sync_queue.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueRow>> pending() => (select(
    syncQueue,
  )..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).get();

  /// Keeps one pending write per entity. The row itself is the durable record;
  /// the entity row carries the complete latest state that will be upserted.
  Future<void> enqueue(SyncQueueCompanion entry) async {
    await (delete(syncQueue)..where(
          (row) =>
              row.entityType.equalsValue(entry.entityType.value) &
              row.entityId.equals(entry.entityId.value),
        ))
        .go();
    await into(syncQueue).insert(entry);
  }

  Future<void> remove(String id) =>
      (delete(syncQueue)..where((row) => row.id.equals(id))).go();

  Future<void> updateFields(String id, SyncQueueCompanion entry) =>
      (update(syncQueue)..where((row) => row.id.equals(id))).write(entry);
}
