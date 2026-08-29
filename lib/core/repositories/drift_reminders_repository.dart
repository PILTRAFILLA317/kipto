// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';

typedef IdGenerator = String Function();

final class DriftRemindersRepository implements RemindersRepository {
  DriftRemindersRepository(
    this._database, {
    Clock? clock,
    IdGenerator? idGenerator,
    LocalSyncCoordinator? syncCoordinator,
  }) : _clock = clock ?? const Clock(),
       _idGenerator = idGenerator ?? const Uuid().v4,
       _syncCoordinator = syncCoordinator;

  final AppDatabase _database;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final LocalSyncCoordinator? _syncCoordinator;

  DateTime get _now => _clock.now().toUtc();

  @override
  Stream<List<Reminder>> watchForSavedItem(String savedItemId) => _database
      .remindersDao
      .watchForSavedItem(savedItemId)
      .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Future<Reminder> create({
    required String savedItemId,
    required DateTime remindAt,
    ReminderKind kind = ReminderKind.custom,
  }) async {
    final now = _now;
    final reminder = Reminder(
      id: _idGenerator(),
      savedItemId: savedItemId,
      remindAt: remindAt.toUtc(),
      kind: kind,
      createdAt: now,
      updatedAt: now,
      ownerId: _syncCoordinator?.activeOwnerId,
      syncStatus: _syncCoordinator?.activeOwnerId == null
          ? SyncStatus.localOnly
          : SyncStatus.pendingCreate,
    );
    final shouldSync =
        _syncCoordinator?.canSyncOwner(reminder.ownerId) ?? false;
    await _database.transaction(() async {
      await _database.remindersDao.insertReminder(_toCompanion(reminder));
      if (shouldSync) {
        await _syncCoordinator!.enqueue(
          entityType: SyncEntityType.reminder,
          entityId: reminder.id,
          operation: SyncOperation.create,
        );
      }
    });
    if (shouldSync) _syncCoordinator!.notifyAfterCommit();
    return reminder;
  }

  @override
  Future<void> complete(String id) async {
    await _require(id);
    final now = _now;
    await _writeSynchronized(
      await _require(id),
      RemindersCompanion(completedAt: Value(now), updatedAt: Value(now)),
      SyncOperation.update,
    );
  }

  @override
  Future<void> delete(String id) async {
    await _require(id);
    final now = _now;
    await _writeSynchronized(
      await _require(id),
      RemindersCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      SyncOperation.delete,
    );
  }

  @override
  Future<List<Reminder>> futurePending({DateTime? from}) async {
    final rows = await _database.remindersDao.futurePending(
      (from ?? _now).toUtc(),
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<ReminderRow> _require(String id) async {
    final reminder = await _database.remindersDao.findById(id);
    if (reminder == null) throw StateError('Reminder $id does not exist');
    return reminder;
  }

  Future<void> _writeSynchronized(
    ReminderRow existing,
    RemindersCompanion fields,
    SyncOperation operation,
  ) async {
    final coordinator = _syncCoordinator;
    final shouldSync = coordinator?.canSyncOwner(existing.ownerId) ?? false;
    final pending = operation == SyncOperation.delete
        ? SyncStatus.pendingDelete
        : existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await _database.transaction(() async {
      await _database.remindersDao.updateFields(
        existing.id,
        shouldSync ? fields.copyWith(syncStatus: Value(pending)) : fields,
      );
      if (shouldSync) {
        await coordinator!.enqueue(
          entityType: SyncEntityType.reminder,
          entityId: existing.id,
          operation: operation,
        );
      }
    });
    if (shouldSync) coordinator!.notifyAfterCommit();
  }

  Reminder _fromRow(ReminderRow row) => Reminder(
    id: row.id,
    ownerId: row.ownerId,
    savedItemId: row.savedItemId,
    remindAt: row.remindAt,
    kind: row.kind,
    completedAt: row.completedAt,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    syncStatus: row.syncStatus,
    lastSyncedAt: row.lastSyncedAt,
    remoteServerUpdatedAt: row.remoteServerUpdatedAt,
  );

  RemindersCompanion _toCompanion(Reminder reminder) =>
      RemindersCompanion.insert(
        id: reminder.id,
        ownerId: Value(reminder.ownerId),
        savedItemId: reminder.savedItemId,
        remindAt: reminder.remindAt.toUtc(),
        kind: reminder.kind,
        completedAt: Value(reminder.completedAt?.toUtc()),
        createdAt: reminder.createdAt.toUtc(),
        updatedAt: reminder.updatedAt.toUtc(),
        deletedAt: Value(reminder.deletedAt?.toUtc()),
        syncStatus: reminder.syncStatus,
        lastSyncedAt: Value(reminder.lastSyncedAt?.toUtc()),
        remoteServerUpdatedAt: Value(reminder.remoteServerUpdatedAt?.toUtc()),
      );
}
