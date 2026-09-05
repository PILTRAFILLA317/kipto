import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/sync_queue_entry.dart';
import 'package:kipto/core/repositories/sync_queue_repository.dart';

final class DriftSyncQueueRepository implements SyncQueueRepository {
  const DriftSyncQueueRepository(this._database);
  final AppDatabase _database;

  @override
  Future<List<SyncQueueEntry>> pending() async =>
      (await _database.syncQueueDao.pending())
          .map(
            (row) => SyncQueueEntry(
              id: row.id,
              entityType: row.entityType,
              entityId: row.entityId,
              operation: row.operation,
              createdAt: row.createdAt,
              attempts: row.attempts,
              lastAttemptAt: row.lastAttemptAt,
              lastError: row.lastError,
            ),
          )
          .toList(growable: false);
}
