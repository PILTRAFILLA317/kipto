import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/screenshot_items_repository.dart';
import 'package:uuid/uuid.dart';

final class DriftScreenshotItemsRepository
    implements ScreenshotItemsRepository {
  DriftScreenshotItemsRepository(this._database, {Clock? clock, Uuid? uuid})
    : _clock = clock ?? const Clock(),
      _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final Clock _clock;
  final Uuid _uuid;

  @override
  Future<Set<String>> existingLocalAssetIds(Iterable<String> ids) async =>
      (await _database.savedItemsDao.getExistingLocalAssetIds(ids)).toSet();

  @override
  Future<int> importAssets(List<LocalScreenshotAsset> assets) async {
    if (assets.isEmpty) return 0;
    final existing = await existingLocalAssetIds(
      assets.map((asset) => asset.id),
    );
    final now = _clock.now().toUtc();
    final pending = assets
        .where((asset) => !existing.contains(asset.id))
        .map(
          (asset) => SavedItemsCompanion.insert(
            id: _uuid.v4(),
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
            syncStatus: SyncStatus.localOnly,
          ),
        )
        .toList(growable: false);
    if (pending.isEmpty) return 0;
    await _database.savedItemsDao.insertItemsIgnoringDuplicates(pending);
    final after = await existingLocalAssetIds(assets.map((asset) => asset.id));
    return after.difference(existing).length;
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
      _clock.now().toUtc(),
    );
  }

  @override
  Future<int> countImported() async =>
      (await _database.savedItemsDao.getWithLocalAssets()).length;
}
