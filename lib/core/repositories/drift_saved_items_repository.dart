// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/domain/models/inbox_overview.dart';
import 'package:kipto/core/domain/models/library_query.dart';
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
  Stream<InboxOverview> watchInboxOverview(DateTime now) =>
      _database.savedItemsDao.watchInboxCandidates(now).asyncMap((rows) async {
        final organized = InboxPolicy.organize(
          rows.map(_fromRow).toList(growable: false),
          now,
        );
        return InboxOverview(
          sections: organized.sections,
          attentionCount: await _database.savedItemsDao.countInboxAttention(
            now,
          ),
        );
      });

  @override
  Stream<List<SavedItem>> watchAll() => _database.savedItemsDao
      .watchActive()
      .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Stream<List<SavedItem>> watchLibrary(LibraryQuery query) => _database
      .savedItemsDao
      .watchLibrary(query)
      .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Stream<LibraryCounts> watchLibraryCounts() =>
      _database.savedItemsDao.watchCounts().map((rows) {
        final counts = <SavedItemCategory, int>{};
        var unprocessed = 0;
        for (final row in rows) {
          counts[row.category] = row.count;
          unprocessed += row.unprocessed;
        }
        return LibraryCounts(
          total: counts.values.fold(0, (total, count) => total + count),
          byCategory: Map.unmodifiable(counts),
          unprocessed: unprocessed,
        );
      });

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
    final rows = await _database.savedItemsDao.searchActive(normalized);
    final categoryMatches = SavedItemCategory.values
        .where(
          (category) =>
              category.name.toLowerCase().contains(normalized) ||
              normalized.contains(category.name.toLowerCase()),
        )
        .toSet();
    if (categoryMatches.isEmpty) {
      return rows.map(_fromRow).toList(growable: false);
    }
    final categoryRows = await _database.savedItemsDao.getByCategories(
      categoryMatches,
    );
    final combined = <String, SavedItem>{
      for (final row in rows) row.id: _fromRow(row),
      for (final row in categoryRows)
        if (categoryMatches.contains(row.category)) row.id: _fromRow(row),
    }.values.toList()..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return combined;
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
  Future<void> updateTitle(String id, String title) async {
    final normalized = title.trim();
    if (normalized.isEmpty) throw ArgumentError.value(title, 'title');
    final existing = await _require(id);
    await _writeSynchronized(
      existing,
      SavedItemsCompanion(
        title: Value(normalized),
        entities: Value(_withUserSource(existing.entities, title: true)),
        updatedAt: Value(_now),
      ),
      SyncOperation.update,
    );
  }

  @override
  Future<void> updateCategory(String id, SavedItemCategory category) async {
    final existing = await _require(id);
    await _writeSynchronized(
      existing,
      SavedItemsCompanion(
        category: Value(category),
        entities: Value(_withUserSource(existing.entities, category: true)),
        updatedAt: Value(_now),
      ),
      SyncOperation.update,
    );
  }

  @override
  Future<void> updateNote(String id, String? note) async {
    final existing = await _require(id);
    final entities = Map<String, Object?>.from(existing.entities);
    final normalized = note?.trim();
    if (normalized == null || normalized.isEmpty) {
      entities.remove(SavedItem.userNoteEntityKey);
    } else {
      entities[SavedItem.userNoteEntityKey] = normalized;
    }
    await _writeSynchronized(
      existing,
      SavedItemsCompanion(entities: Value(entities), updatedAt: Value(_now)),
      SyncOperation.update,
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

  Map<String, Object?> _withUserSource(
    Map<String, Object?> entities, {
    bool title = false,
    bool category = false,
  }) {
    final updated = Map<String, Object?>.from(entities);
    final current = updated[SavedItem.analysisMetadataEntityKey];
    final metadata = current is Map
        ? Map<String, Object?>.from(current)
        : <String, Object?>{};
    if (title) {
      metadata['titleSource'] = SavedItemMetadataSource.user.storageValue;
    }
    if (category) {
      metadata['categorySource'] = SavedItemMetadataSource.user.storageValue;
    }
    updated[SavedItem.analysisMetadataEntityKey] = metadata;
    return updated;
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
