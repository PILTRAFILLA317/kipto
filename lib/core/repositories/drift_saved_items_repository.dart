// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/saved_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';

final class DriftSavedItemsRepository implements SavedItemsRepository {
  DriftSavedItemsRepository(
    this._database, {
    Clock? clock,
    LocalSyncCoordinator? syncCoordinator,
  }) : _clock = clock ?? const Clock(),
       _syncCoordinator = syncCoordinator;

  final AppDatabase _database;
  final Clock _clock;
  final LocalSyncCoordinator? _syncCoordinator;

  DateTime get _now => _clock.now().toUtc();

  @override
  Stream<List<SavedItem>> watchInbox() => _database.savedItemsDao
      .watchInbox()
      .map((rows) => rows.map(_fromRow).toList()..sort(_compareInbox));

  @override
  Stream<List<SavedItem>> watchAll() => _database.savedItemsDao
      .watchActive()
      .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Stream<List<SavedItem>> watchByCategory(SavedItemCategory category) =>
      _database.savedItemsDao
          .watchByCategory(category)
          .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Stream<SavedItem?> watchById(String id) => _database.savedItemsDao
      .watchById(id)
      .map((row) => row == null ? null : _fromRow(row));

  @override
  Future<List<SavedItem>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    final rows = await _database.savedItemsDao.getActive();
    return rows.map(_fromRow).where((item) {
      final haystack = [
        item.title,
        item.summary,
        item.subtype ?? '',
        item.intent ?? '',
        item.category.name,
        jsonEncode(item.entities),
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList()..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
  }

  @override
  Future<void> create(SavedItem item) async {
    final coordinator = _syncCoordinator;
    final ownerId = item.ownerId ?? coordinator?.activeOwnerId;
    final shouldSync =
        coordinator != null &&
        coordinator.canSyncOwner(ownerId) &&
        !coordinator.isDemoId(item.id);
    await _database.transaction(() async {
      await _database.savedItemsDao.insertItem(
        _toCompanion(
          item,
          ownerId: ownerId,
          syncStatus: shouldSync ? SyncStatus.pendingCreate : item.syncStatus,
        ),
      );
      if (shouldSync) {
        await coordinator.enqueue(
          entityType: SyncEntityType.savedItem,
          entityId: item.id,
          operation: SyncOperation.create,
        );
      }
    });
    if (shouldSync) coordinator.notifyAfterCommit();
  }

  @override
  Future<void> update(SavedItem item) async {
    final existing = await _require(item.id, includeDeleted: true);
    await _writeSynchronized(
      existing,
      _toCompanion(item, updatedAt: _now),
      SyncOperation.update,
      replace: true,
    );
  }

  @override
  Future<void> changeStatus(String id, SavedItemStatus status) =>
      _writeSynchronizedFields(
        id,
        SavedItemsCompanion(status: Value(status), updatedAt: Value(_now)),
      );

  @override
  Future<void> archive(String id) => changeStatus(id, SavedItemStatus.archived);

  @override
  Future<void> markDone(String id) => changeStatus(id, SavedItemStatus.done);

  @override
  Future<void> toggleFavorite(String id) async {
    final current = await _require(id);
    await _writeSynchronized(
      current,
      SavedItemsCompanion(
        favorite: Value(!current.favorite),
        updatedAt: Value(_now),
      ),
      SyncOperation.update,
    );
  }

  @override
  Future<void> snooze(String id, DateTime until) => _writeSynchronizedFields(
    id,
    SavedItemsCompanion(
      status: const Value(SavedItemStatus.snoozed),
      snoozedUntil: Value(until.toUtc()),
      updatedAt: Value(_now),
    ),
  );

  @override
  Future<void> restore(String id) => _writeSynchronizedFields(
    id,
    SavedItemsCompanion(
      status: const Value(SavedItemStatus.newItem),
      snoozedUntil: const Value(null),
      deletedAt: const Value(null),
      updatedAt: Value(_now),
    ),
    includeDeleted: true,
  );

  @override
  Future<void> softDelete(String id) => _writeSynchronizedFields(
    id,
    SavedItemsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    operation: SyncOperation.delete,
  );

  Future<void> _writeSynchronizedFields(
    String id,
    SavedItemsCompanion fields, {
    bool includeDeleted = false,
    SyncOperation operation = SyncOperation.update,
  }) async {
    final existing = await _require(id, includeDeleted: includeDeleted);
    await _writeSynchronized(existing, fields, operation);
  }

  Future<void> _writeSynchronized(
    SavedItemRow existing,
    SavedItemsCompanion fields,
    SyncOperation operation, {
    bool replace = false,
  }) async {
    final coordinator = _syncCoordinator;
    final shouldSync =
        coordinator != null &&
        coordinator.canSyncOwner(existing.ownerId) &&
        !coordinator.isDemoId(existing.id);
    final pendingStatus = operation == SyncOperation.delete
        ? SyncStatus.pendingDelete
        : existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    final synchronizedFields = shouldSync
        ? fields.copyWith(syncStatus: Value(pendingStatus))
        : fields;
    await _database.transaction(() async {
      if (replace) {
        await _database.savedItemsDao.upsertItem(synchronizedFields);
      } else {
        await _database.savedItemsDao.updateFields(
          existing.id,
          synchronizedFields,
        );
      }
      if (shouldSync) {
        await coordinator.enqueue(
          entityType: SyncEntityType.savedItem,
          entityId: existing.id,
          operation: operation,
        );
      }
    });
    if (shouldSync) coordinator.notifyAfterCommit();
  }

  Future<SavedItemRow> _require(
    String id, {
    bool includeDeleted = false,
  }) async {
    final item = await _database.savedItemsDao.findById(
      id,
      includeDeleted: includeDeleted,
    );
    if (item == null) throw StateError('SavedItem $id does not exist');
    return item;
  }

  int _compareInbox(SavedItem a, SavedItem b) {
    int rank(SavedItem item) {
      if (item.status == SavedItemStatus.needsAction) return 0;
      if (item.expiresAt != null) return 1;
      if (item.status == SavedItemStatus.snoozed) return 2;
      return 3;
    }

    final byStatus = rank(a).compareTo(rank(b));
    if (byStatus != 0) return byStatus;
    if (a.expiresAt != null || b.expiresAt != null) {
      if (a.expiresAt == null) return 1;
      if (b.expiresAt == null) return -1;
      final byExpiry = a.expiresAt!.compareTo(b.expiresAt!);
      if (byExpiry != 0) return byExpiry;
    }
    return b.capturedAt.compareTo(a.capturedAt);
  }

  SavedItem _fromRow(SavedItemRow row) => SavedItem(
    id: row.id,
    ownerId: row.ownerId,
    title: row.title,
    summary: row.summary,
    category: row.category,
    subtype: row.subtype,
    intent: row.intent,
    status: row.status,
    favorite: row.favorite,
    capturedAt: row.capturedAt,
    eventAt: row.eventAt,
    expiresAt: row.expiresAt,
    snoozedUntil: row.snoozedUntil,
    location: row.location,
    entities: row.entities,
    availableActions: row.availableActions,
    cloudPreviewPath: row.cloudPreviewPath,
    imageHash: row.imageHash,
    analysisStatus: row.analysisStatus,
    analysisVersion: row.analysisVersion,
    confidence: row.confidence,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    localAssetId: row.localAssetId,
    originalAvailable: row.originalAvailable,
    previewCachePath: row.previewCachePath,
    syncStatus: row.syncStatus,
    lastSyncedAt: row.lastSyncedAt,
    remoteServerUpdatedAt: row.remoteServerUpdatedAt,
  );

  SavedItemsCompanion _toCompanion(
    SavedItem item, {
    DateTime? updatedAt,
    String? ownerId,
    SyncStatus? syncStatus,
  }) => SavedItemsCompanion.insert(
    id: item.id,
    ownerId: Value(ownerId ?? item.ownerId),
    title: item.title,
    summary: Value(item.summary),
    category: item.category,
    subtype: Value(item.subtype),
    intent: Value(item.intent),
    status: item.status,
    favorite: Value(item.favorite),
    capturedAt: item.capturedAt.toUtc(),
    eventAt: Value(item.eventAt?.toUtc()),
    expiresAt: Value(item.expiresAt?.toUtc()),
    snoozedUntil: Value(item.snoozedUntil?.toUtc()),
    location: Value(item.location),
    entities: Value(item.entities),
    availableActions: Value(item.availableActions),
    cloudPreviewPath: Value(item.cloudPreviewPath),
    imageHash: Value(item.imageHash),
    analysisStatus: item.analysisStatus,
    analysisVersion: Value(item.analysisVersion),
    confidence: Value(item.confidence),
    createdAt: item.createdAt.toUtc(),
    updatedAt: (updatedAt ?? item.updatedAt).toUtc(),
    deletedAt: Value(item.deletedAt?.toUtc()),
    localAssetId: Value(item.localAssetId),
    originalAvailable: Value(item.originalAvailable),
    previewCachePath: Value(item.previewCachePath),
    syncStatus: syncStatus ?? item.syncStatus,
    lastSyncedAt: Value(item.lastSyncedAt?.toUtc()),
    remoteServerUpdatedAt: Value(item.remoteServerUpdatedAt?.toUtc()),
  );
}
