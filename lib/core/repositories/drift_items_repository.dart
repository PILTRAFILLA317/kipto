// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/repositories/items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:uuid/uuid.dart';

final class DriftItemsRepository implements ItemsRepository {
  DriftItemsRepository(
    this._database, {
    required LocalSyncCoordinator syncCoordinator,
    Clock? clock,
    Uuid? uuid,
    this.onChanged,
  }) : _syncCoordinator = syncCoordinator,
       _clock = clock ?? const Clock(),
       _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final LocalSyncCoordinator _syncCoordinator;
  final Clock _clock;
  final Uuid _uuid;
  final Future<void> Function()? onChanged;

  DateTime get _now => _clock.now().toUtc();

  @override
  Stream<List<Item>> watchActive() => _database.itemsDao.watchActive().map(
    (rows) => rows
        .where((row) => row.ownerId == _syncCoordinator.activeOwnerId)
        .map(_fromRow)
        .toList(),
  );

  @override
  Stream<List<Item>> watchAll() => _database.itemsDao.watchAll().map(
    (rows) => rows
        .where((row) => row.ownerId == _syncCoordinator.activeOwnerId)
        .map(_fromRow)
        .toList(),
  );

  @override
  Future<Item?> findById(String id, {bool includeDeleted = false}) async {
    final row = await _database.itemsDao.findById(
      id,
      includeDeleted: includeDeleted,
    );
    return row == null || row.ownerId != _syncCoordinator.activeOwnerId
        ? null
        : _fromRow(row);
  }

  @override
  Future<Item> create({required String title, String summary = ''}) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) throw ArgumentError.value(title, 'title');
    final now = _now;
    final id = _uuid.v4();
    final ownerId = _syncCoordinator.activeOwnerId;
    final syncStatus = ownerId == null
        ? SyncStatus.localOnly
        : SyncStatus.pendingCreate;
    await _database.transaction(() async {
      await _database.itemsDao.insertItem(
        ItemsCompanion.insert(
          id: id,
          ownerId: Value(ownerId),
          title: normalizedTitle,
          summary: Value(summary.trim()),
          status: ItemStatus.active,
          createdAt: now,
          updatedAt: now,
          syncStatus: syncStatus,
        ),
      );
      if (ownerId != null) {
        await _syncCoordinator.enqueue(
          entityType: SyncEntityType.item,
          entityId: id,
          operation: SyncOperation.create,
        );
      }
    });
    _syncCoordinator.notifyAfterCommit();
    return (await findById(id))!;
  }

  @override
  Future<void> setStatus(
    String id,
    ItemStatus status, {
    bool cancelReminders = false,
  }) => _mutate(
    id,
    ItemsCompanion(
      status: Value(status),
      resolvedAt: Value(status == ItemStatus.resolved ? _now : null),
    ),
    cancelReminders: cancelReminders,
  );

  @override
  Future<void> updateText(
    String id, {
    required String title,
    required String summary,
  }) {
    if (title.trim().isEmpty ||
        title.trim().length > 100 ||
        summary.trim().length > 300) {
      throw ArgumentError('Invalid matter text');
    }
    return _mutate(
      id,
      ItemsCompanion(
        title: Value(title.trim()),
        summary: Value(summary.trim()),
      ),
    );
  }

  @override
  Future<void> delete(String id) =>
      _mutate(id, ItemsCompanion(deletedAt: Value(_now)));

  Future<void> _mutate(
    String id,
    ItemsCompanion changes, {
    bool cancelReminders = false,
  }) async {
    await _database.transaction(() async {
      final existing = await _database.itemsDao.findById(
        id,
        includeDeleted: true,
      );
      if (existing == null) return;
      if (existing.ownerId != _syncCoordinator.activeOwnerId ||
          existing.deletedAt != null) {
        throw StateError('Matter unavailable in this account');
      }
      final observed = _now;
      final mutationTime = observed.isAfter(existing.updatedAt)
          ? observed
          : existing.updatedAt.add(const Duration(microseconds: 1));
      final ownerId = existing.ownerId;
      final syncable = _syncCoordinator.canSyncOwner(ownerId);
      if (changes.status.present &&
          changes.status.value == ItemStatus.archived) {
        final pending =
            await (_database.select(_database.reminders)..where(
                  (r) =>
                      r.itemId.equals(id) &
                      r.deletedAt.isNull() &
                      r.completedAt.isNull() &
                      r.remindAt.isBiggerThanValue(_now),
                ))
                .get();
        if (pending.isNotEmpty && !cancelReminders) {
          throw StateError('Confirm reminder cancellation before archiving');
        }
        for (final reminder in pending) {
          await _database.remindersDao.updateFields(
            reminder.id,
            RemindersCompanion(
              completedAt: Value(_now),
              updatedAt: Value(
                mutationTime.isAfter(reminder.updatedAt)
                    ? mutationTime
                    : reminder.updatedAt.add(const Duration(microseconds: 1)),
              ),
              syncStatus: Value(
                syncable ? SyncStatus.pendingUpdate : reminder.syncStatus,
              ),
            ),
          );
          if (syncable) {
            await _syncCoordinator.enqueue(
              entityType: SyncEntityType.reminder,
              entityId: reminder.id,
              operation: SyncOperation.update,
            );
          }
        }
      }
      await _database.itemsDao.updateFields(
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
          entityType: SyncEntityType.item,
          entityId: id,
          operation: changes.deletedAt.present
              ? SyncOperation.delete
              : SyncOperation.update,
        );
      }
      if (existing.ownerId != _syncCoordinator.activeOwnerId) {
        throw StateError('Account changed');
      }
    });
    _syncCoordinator.notifyAfterCommit();
    await onChanged?.call();
  }

  Item _fromRow(ItemRow row) => Item(
    id: row.id,
    ownerId: row.ownerId,
    title: row.title,
    summary: row.summary,
    status: row.status,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    resolvedAt: row.resolvedAt?.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
    syncStatus: row.syncStatus,
    lastSyncedAt: row.lastSyncedAt?.toUtc(),
    remoteServerUpdatedAt: row.remoteServerUpdatedAt?.toUtc(),
    sourceDeviceId: row.sourceDeviceId,
  );
}
