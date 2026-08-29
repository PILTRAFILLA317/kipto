import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/sync_queue.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.attachedDatabase);

  Future<void> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Stream<List<SyncQueueRow>> watchPending() => (select(
    syncQueue,
  )..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)])).watch();

  Future<List<SyncQueueRow>> pending() => (select(
    syncQueue,
  )..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)])).get();

  Future<SyncQueueRow?> findById(String id) => (select(
    syncQueue,
  )..where((entry) => entry.id.equals(id))).getSingleOrNull();

  Future<int> updateFields(String id, SyncQueueCompanion fields) =>
      (update(syncQueue)..where((entry) => entry.id.equals(id))).write(fields);

  Future<int> remove(String id) =>
      (delete(syncQueue)..where((entry) => entry.id.equals(id))).go();
}
