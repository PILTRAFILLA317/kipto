// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:uuid/uuid.dart';

final class DriftRemindersRepository implements RemindersRepository {
  DriftRemindersRepository(
    this._database, {
    required LocalSyncCoordinator syncCoordinator,
    required Future<void> Function() onChanged,
    Clock? clock,
    Uuid? uuid,
  }) : _syncCoordinator = syncCoordinator,
       _onChanged = onChanged,
       _clock = clock ?? const Clock(),
       _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final LocalSyncCoordinator _syncCoordinator;
  final Future<void> Function() _onChanged;
  final Clock _clock;
  final Uuid _uuid;
  DateTime get _now => _clock.now().toUtc();

  @override
  Stream<List<Reminder>> watchForItem(String itemId) => _database.remindersDao
      .watchForItem(itemId)
      .map(
        (rows) => rows
            .where((row) => row.ownerId == _syncCoordinator.activeOwnerId)
            .map(_fromRow)
            .toList(),
      );

  @override
  Future<Reminder?> findById(String id, {bool includeDeleted = false}) async {
    final row = await _database.remindersDao.findById(
      id,
      includeDeleted: includeDeleted,
    );
    return row == null || row.ownerId != _syncCoordinator.activeOwnerId
        ? null
        : _fromRow(row);
  }

  @override
  Future<Reminder> create({
    required String itemId,
    required DateTime remindAt,
  }) async {
    final now = _now;
    final id = _uuid.v4();
    final item = await _database.itemsDao.findById(itemId);
    if (item == null || item.ownerId != _syncCoordinator.activeOwnerId) {
      throw StateError('Cannot remind for an unavailable item');
    }
    final ownerId = _syncCoordinator.activeOwnerId;
    final syncStatus = ownerId == null
        ? SyncStatus.localOnly
        : SyncStatus.pendingCreate;
    await _database.transaction(() async {
      await _database.remindersDao.insertReminder(
        RemindersCompanion.insert(
          id: id,
          ownerId: Value(ownerId),
          itemId: itemId,
          remindAt: remindAt.toUtc(),
          createdAt: now,
          updatedAt: now,
          syncStatus: syncStatus,
        ),
      );
      if (ownerId != null) {
        await _syncCoordinator.enqueue(
          entityType: SyncEntityType.reminder,
          entityId: id,
          operation: SyncOperation.create,
        );
      }
    });
    _syncCoordinator.notifyAfterCommit();
    await _onChanged();
    return (await findById(id))!;
  }

  @override
  Future<void> edit(String id, DateTime remindAt) =>
      _mutate(id, RemindersCompanion(remindAt: Value(remindAt.toUtc())));

  @override
  Future<void> complete(String id) =>
      _mutate(id, RemindersCompanion(completedAt: Value(_now)));

  @override
  Future<void> delete(String id) =>
      _mutate(id, RemindersCompanion(deletedAt: Value(_now)));

  Future<void> _mutate(String id, RemindersCompanion changes) async {
    final existing = await _database.remindersDao.findById(id);
    if (existing == null) return;
    if (existing.ownerId != _syncCoordinator.activeOwnerId) {
      throw StateError("Reminder belongs to another account");
    }
    final observed = _now;
    final mutationTime = observed.isAfter(existing.updatedAt)
        ? observed
        : existing.updatedAt.add(const Duration(microseconds: 1));
    final syncable = _syncCoordinator.canSyncOwner(existing.ownerId);
    await _database.transaction(() async {
      if (existing.ownerId != _syncCoordinator.activeOwnerId) {
        throw StateError("Account changed");
      }
      await _database.remindersDao.updateFields(
        id,
        changes.copyWith(
          updatedAt: Value(mutationTime),
          syncStatus: Value(
            syncable ? SyncStatus.pendingUpdate : existing.syncStatus,
          ),
        ),
      );
      if (syncable) {
        await _syncCoordinator.enqueue(
          entityType: SyncEntityType.reminder,
          entityId: id,
          operation: changes.deletedAt.present
              ? SyncOperation.delete
              : SyncOperation.update,
        );
      }
    });
    _syncCoordinator.notifyAfterCommit();
    await _onChanged();
  }

  Reminder _fromRow(ReminderRow row) => Reminder(
    id: row.id,
    ownerId: row.ownerId,
    itemId: row.itemId,
    actionId: row.actionId,
    title: row.title,
    timeZone: row.timeZone,
    remindAt: row.remindAt.toUtc(),
    completedAt: row.completedAt?.toUtc(),
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
    syncStatus: row.syncStatus,
    lastSyncedAt: row.lastSyncedAt?.toUtc(),
    remoteServerUpdatedAt: row.remoteServerUpdatedAt?.toUtc(),
    sourceDeviceId: row.sourceDeviceId,
  );
}
