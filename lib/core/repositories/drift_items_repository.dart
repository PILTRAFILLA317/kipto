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
  }) : _syncCoordinator = syncCoordinator,
       _clock = clock ?? const Clock(),
       _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final LocalSyncCoordinator _syncCoordinator;
  final Clock _clock;
  final Uuid _uuid;

  DateTime get _now => _clock.now().toUtc();

  @override
  Stream<List<Item>> watchActive() => _database.itemsDao.watchActive().map(
    (rows) => rows.map(_fromRow).toList(),
  );

  @override
  Future<Item?> findById(String id, {bool includeDeleted = false}) async {
    final row = await _database.itemsDao.findById(
      id,
      includeDeleted: includeDeleted,
    );
    return row == null ? null : _fromRow(row);
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
  Future<void> setStatus(String id, ItemStatus status) => _mutate(
    id,
    ItemsCompanion(
      status: Value(status),
      resolvedAt: Value(status == ItemStatus.resolved ? _now : null),
    ),
  );

  @override
  Future<void> delete(String id) =>
      _mutate(id, ItemsCompanion(deletedAt: Value(_now)));

  Future<void> _mutate(String id, ItemsCompanion changes) async {
    final existing = await _database.itemsDao.findById(
      id,
      includeDeleted: true,
    );
    if (existing == null) return;
    final ownerId = existing.ownerId;
    final syncable = _syncCoordinator.canSyncOwner(ownerId);
    await _database.transaction(() async {
      await _database.itemsDao.updateFields(
        id,
        changes.copyWith(
          updatedAt: Value(_now),
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
    });
    _syncCoordinator.notifyAfterCommit();
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
