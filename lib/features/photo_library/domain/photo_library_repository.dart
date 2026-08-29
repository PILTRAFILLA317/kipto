import 'package:kipto/features/photo_library/domain/photo_library_models.dart';

abstract interface class PhotoLibraryRepository {
  Future<PhotoAccessStatus> getPermissionStatus();
  Future<PhotoAccessStatus> requestPermission();
  Future<void> openSettings();
  Future<void> manageLimitedAccess();
  Future<int> countScreenshots();
  Future<int> countScreenshotsSince(DateTime capturedSince);
  Stream<List<LocalScreenshotAsset>> getScreenshotsPaged({
    required int pageSize,
    int? limit,
    DateTime? capturedSince,
  });
  Future<bool> assetExists(String localAssetId);
  Future<LocalAssetThumbnailData?> loadThumbnail(
    String localAssetId, {
    required int width,
    required int height,
  });
  Stream<void> get changes;
  Future<void> startObservingChanges();
  Future<void> stopObservingChanges();
}
