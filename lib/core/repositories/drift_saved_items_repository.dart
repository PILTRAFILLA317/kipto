import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/saved_items_repository.dart';

final class DriftSavedItemsRepository implements SavedItemsRepository {
  DriftSavedItemsRepository(this._database, {Clock? clock})
    : _clock = clock ?? const Clock();

  final AppDatabase _database;
  final Clock _clock;

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
  Future<void> create(SavedItem item) =>
      _database.savedItemsDao.insertItem(_toCompanion(item));

  @override
  Future<void> update(SavedItem item) =>
      _database.savedItemsDao.upsertItem(_toCompanion(item, updatedAt: _now));

  @override
  Future<void> changeStatus(String id, SavedItemStatus status) =>
      _writeExisting(
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
    await _database.savedItemsDao.updateFields(
      id,
      SavedItemsCompanion(
        favorite: Value(!current.favorite),
        updatedAt: Value(_now),
      ),
    );
  }

  @override
  Future<void> snooze(String id, DateTime until) => _writeExisting(
    id,
    SavedItemsCompanion(
      status: const Value(SavedItemStatus.snoozed),
      snoozedUntil: Value(until.toUtc()),
      updatedAt: Value(_now),
    ),
  );

  @override
  Future<void> restore(String id) => _writeExisting(
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
  Future<void> softDelete(String id) => _writeExisting(
    id,
    SavedItemsCompanion(
      deletedAt: Value(_now),
      syncStatus: const Value(SyncStatus.localOnly),
      updatedAt: Value(_now),
    ),
  );

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

  Future<void> _writeExisting(
    String id,
    SavedItemsCompanion fields, {
    bool includeDeleted = false,
  }) async {
    await _require(id, includeDeleted: includeDeleted);
    await _database.savedItemsDao.updateFields(id, fields);
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
  );

  SavedItemsCompanion _toCompanion(SavedItem item, {DateTime? updatedAt}) =>
      SavedItemsCompanion.insert(
        id: item.id,
        ownerId: Value(item.ownerId),
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
        syncStatus: item.syncStatus,
        lastSyncedAt: Value(item.lastSyncedAt?.toUtc()),
      );
}
