import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/sync_queue_entry.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

final class DriftSyncQueueRepository implements SyncQueueRepository {
  DriftSyncQueueRepository(
    this._database, {
    Clock? clock,
    IdGenerator? idGenerator,
  }) : _clock = clock ?? const Clock(),
       _idGenerator = idGenerator ?? const Uuid().v4;

  final AppDatabase _database;
  final Clock _clock;
  final IdGenerator _idGenerator;

  DateTime get _now => _clock.now().toUtc();

  @override
  Future<SyncQueueEntry> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
  }) async {
    final entry = SyncQueueEntry(
      id: _idGenerator(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      createdAt: _now,
      attempts: 0,
    );
    await _database.syncQueueDao.enqueue(
      SyncQueueCompanion.insert(
        id: entry.id,
        entityType: entry.entityType,
        entityId: entry.entityId,
        operation: entry.operation,
        createdAt: entry.createdAt,
      ),
    );
    return entry;
  }

  @override
  Stream<List<SyncQueueEntry>> watchPending() => _database.syncQueueDao
      .watchPending()
      .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Future<List<SyncQueueEntry>> pending() async =>
      (await _database.syncQueueDao.pending())
          .map(_fromRow)
          .toList(growable: false);

  @override
  Future<void> markCompleted(String id) async {
    await _require(id);
    await _database.syncQueueDao.remove(id);
  }

  @override
  Future<void> registerError(String id, String error) async {
    final current = await _require(id);
    await _database.syncQueueDao.updateFields(
      id,
      SyncQueueCompanion(
        attempts: Value(current.attempts + 1),
        lastAttemptAt: Value(_now),
        lastError: Value(error),
      ),
    );
  }

  Future<SyncQueueRow> _require(String id) async {
    final entry = await _database.syncQueueDao.findById(id);
    if (entry == null) throw StateError('Sync queue entry $id does not exist');
    return entry;
  }

  SyncQueueEntry _fromRow(SyncQueueRow row) => SyncQueueEntry(
    id: row.id,
    entityType: row.entityType,
    entityId: row.entityId,
    operation: row.operation,
    createdAt: row.createdAt,
    attempts: row.attempts,
    lastAttemptAt: row.lastAttemptAt,
    lastError: row.lastError,
  );
}
