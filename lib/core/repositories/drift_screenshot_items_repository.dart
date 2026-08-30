// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/screenshot_items_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';

final class DriftScreenshotItemsRepository
    implements ScreenshotItemsRepository {
  DriftScreenshotItemsRepository(
    this._database, {
    Clock? clock,
    Uuid? uuid,
    LocalSyncCoordinator? syncCoordinator,
  }) : _clock = clock ?? const Clock(),
       _uuid = uuid ?? const Uuid(),
       _syncCoordinator = syncCoordinator;

  final AppDatabase _database;
  final Clock _clock;
  final Uuid _uuid;
  final LocalSyncCoordinator? _syncCoordinator;

  @override
  Future<Set<String>> existingLocalAssetIds(Iterable<String> ids) async =>
      (await _database.savedItemsDao.getExistingLocalAssetIds(ids)).toSet();

  @override
  Future<Map<String, String>> savedItemIdsForLocalAssets(
    Iterable<String> localAssetIds,
  ) => _database.savedItemsDao.getSavedItemIdsByLocalAssetIds(localAssetIds);

  @override
  Future<int> importAssets(List<LocalScreenshotAsset> assets) async {
    if (assets.isEmpty) return 0;
    final existing = await existingLocalAssetIds(
      assets.map((asset) => asset.id),
    );
    final now = _clock.now().toUtc();
    final ownerId = _syncCoordinator?.activeOwnerId;
    final pending = assets
        .where((asset) => !existing.contains(asset.id))
        .map(
          (asset) => SavedItemsCompanion.insert(
            id: _uuid.v4(),
            ownerId: Value(ownerId),
            title: 'Screenshot',
            summary: const Value(''),
            category: SavedItemCategory.other,
            status: SavedItemStatus.newItem,
            capturedAt: asset.capturedAt.toUtc(),
            entities: Value({
              'pixelWidth': asset.width,
              'pixelHeight': asset.height,
            }),
            availableActions: const Value([]),
            analysisStatus: AnalysisStatus.unprocessed,
            analysisVersion: const Value(0),
            createdAt: now,
            updatedAt: now,
            localAssetId: Value(asset.id),
            originalAvailable: const Value(true),
            syncStatus: ownerId == null
                ? SyncStatus.localOnly
                : SyncStatus.pendingCreate,
          ),
        )
        .toList(growable: false);
    if (pending.isEmpty) return 0;
    await _database.transaction(() async {
      await _database.savedItemsDao.insertItemsIgnoringDuplicates(pending);
      if (ownerId != null) {
        for (final item in pending) {
          if (await _database.savedItemsDao.findById(item.id.value) == null) {
            continue;
          }
          await _syncCoordinator!.enqueue(
            entityType: SyncEntityType.savedItem,
            entityId: item.id.value,
            operation: SyncOperation.create,
          );
        }
      }
    });
    final after = await existingLocalAssetIds(assets.map((asset) => asset.id));
    final inserted = after.difference(existing).length;
    if (inserted > 0 && ownerId != null) {
      _syncCoordinator!.notifyAfterCommit();
    }
    return inserted;
  }

  @override
  Future<Map<String, bool>> importedAssetAvailability() async {
    final rows = await _database.savedItemsDao.getWithLocalAssets();
    return {
      for (final row in rows)
        if (row.localAssetId != null) row.localAssetId!: row.originalAvailable,
    };
  }

  @override
  Future<void> setOriginalAvailability(
    Iterable<String> localAssetIds,
    bool available,
  ) async {
    await _database.savedItemsDao.updateOriginalAvailability(
      localAssetIds,
      available,
    );
  }

  @override
  Future<int> countImported() async =>
      (await _database.savedItemsDao.getWithLocalAssets()).length;
}
