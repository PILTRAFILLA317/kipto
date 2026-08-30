import 'package:kipto/features/photo_library/domain/photo_library_models.dart';

abstract interface class ScreenshotItemsRepository {
  Future<Set<String>> existingLocalAssetIds(Iterable<String> ids);
  Future<int> importAssets(List<LocalScreenshotAsset> assets);
  Future<Map<String, String>> savedItemIdsForLocalAssets(
    Iterable<String> localAssetIds,
  );
  Future<Map<String, bool>> importedAssetAvailability();
  Future<void> setOriginalAvailability(
    Iterable<String> localAssetIds,
    bool available,
  );
  Future<int> countImported();
}
