import 'dart:async';

import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/photo_library_repository.dart';

final class FakePhotoLibraryRepository implements PhotoLibraryRepository {
  FakePhotoLibraryRepository({
    this.permission = PhotoAccessStatus.authorized,
    Iterable<LocalScreenshotAsset> assets = const [],
  }) : _assets = [...assets];

  PhotoAccessStatus permission;
  final List<LocalScreenshotAsset> _assets;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool settingsOpened = false;
  bool limitedAccessManaged = false;
  Duration pageDelay = Duration.zero;

  List<LocalScreenshotAsset> get assets => List.unmodifiable(_assets);

  void add(LocalScreenshotAsset asset) {
    _assets.removeWhere((current) => current.id == asset.id);
    _assets.add(asset);
    _changes.add(null);
  }

  void remove(String id) {
    _assets.removeWhere((asset) => asset.id == id);
    _changes.add(null);
  }

  @override
  Future<PhotoAccessStatus> getPermissionStatus() async => permission;

  @override
  Future<PhotoAccessStatus> requestPermission() async => permission;

  @override
  Future<void> openSettings() async {
    settingsOpened = true;
  }

  @override
  Future<void> manageLimitedAccess() async {
    limitedAccessManaged = true;
  }

  @override
  Future<int> countScreenshots() async => _assets.length;

  @override
  Future<int> countScreenshotsSince(DateTime capturedSince) async => _assets
      .where((asset) => !asset.capturedAt.isBefore(capturedSince))
      .length;

  @override
  Stream<List<LocalScreenshotAsset>> getScreenshotsPaged({
    required int pageSize,
    int? limit,
    DateTime? capturedSince,
  }) async* {
    final selected =
        _assets
            .where(
              (asset) =>
                  capturedSince == null ||
                  !asset.capturedAt.isBefore(capturedSince),
            )
            .toList()
          ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    final capped = limit == null
        ? selected
        : selected.take(limit).toList(growable: false);
    for (var offset = 0; offset < capped.length; offset += pageSize) {
      if (pageDelay > Duration.zero) await Future<void>.delayed(pageDelay);
      yield capped.sublist(offset, (offset + pageSize).clamp(0, capped.length));
    }
  }

  @override
  Future<bool> assetExists(String localAssetId) async =>
      _assets.any((asset) => asset.id == localAssetId);

  @override
  Future<LocalAssetThumbnailData?> loadThumbnail(
    String localAssetId, {
    required int width,
    required int height,
  }) async => null;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> startObservingChanges() async {}

  @override
  Future<void> stopObservingChanges() async {}

  Future<void> dispose() => _changes.close();
}
