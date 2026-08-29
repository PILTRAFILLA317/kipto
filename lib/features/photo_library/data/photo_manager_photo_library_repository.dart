import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:kipto/features/photo_library/data/screenshot_detection_strategy.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/photo_library_repository.dart';
import 'package:photo_manager/photo_manager.dart';

final class PhotoManagerPhotoLibraryRepository
    implements PhotoLibraryRepository {
  PhotoManagerPhotoLibraryRepository({
    ScreenshotDetectionStrategy detectionStrategy =
        const ScreenshotDetectionStrategy(),
  }) : _detectionStrategy = detectionStrategy;

  static final _permissionOption = PermissionRequestOption(
    iosAccessLevel: IosAccessLevel.readWrite,
    androidPermission: const AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );

  static final _assetFilter = FilterOptionGroup(
    imageOption: const FilterOption(needTitle: true),
    orders: const [OrderOption(type: OrderOptionType.createDate, asc: false)],
  );

  final ScreenshotDetectionStrategy _detectionStrategy;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool _observing = false;

  static PhotoAccessStatus mapPermissionState(PermissionState state) =>
      switch (state) {
        PermissionState.notDetermined => PhotoAccessStatus.notDetermined,
        PermissionState.authorized => PhotoAccessStatus.authorized,
        PermissionState.limited => PhotoAccessStatus.limited,
        PermissionState.denied => PhotoAccessStatus.denied,
        PermissionState.restricted => PhotoAccessStatus.restricted,
      };

  @override
  Future<PhotoAccessStatus> getPermissionStatus() async => mapPermissionState(
    await PhotoManager.getPermissionState(requestOption: _permissionOption),
  );

  @override
  Future<PhotoAccessStatus> requestPermission() async => mapPermissionState(
    await PhotoManager.requestPermissionExtend(
      requestOption: _permissionOption,
    ),
  );

  @override
  Future<void> openSettings() => PhotoManager.openSetting();

  @override
  Future<void> manageLimitedAccess() =>
      PhotoManager.presentLimited(type: RequestType.image);

  @override
  Future<int> countScreenshots() async {
    final sources = await _sources();
    var count = 0;
    for (final source in sources) {
      if (!source.requiresAssetFilter) {
        count += await source.path.assetCountAsync;
        continue;
      }
      await for (final batch in _readSource(source, pageSize: 200)) {
        count += batch.length;
      }
    }
    return count;
  }

  @override
  Future<int> countScreenshotsSince(DateTime capturedSince) async {
    var count = 0;
    await for (final batch in getScreenshotsPaged(
      pageSize: 200,
      capturedSince: capturedSince,
    )) {
      count += batch.length;
    }
    return count;
  }

  @override
  Stream<List<LocalScreenshotAsset>> getScreenshotsPaged({
    required int pageSize,
    int? limit,
    DateTime? capturedSince,
  }) async* {
    final sources = await _sources();
    if (limit != null) {
      final candidates = <LocalScreenshotAsset>[];
      for (final source in sources) {
        await for (final batch in _readSource(
          source,
          pageSize: pageSize,
          maxAssets: limit,
          capturedSince: capturedSince,
        )) {
          candidates.addAll(batch);
        }
      }
      final unique = <String, LocalScreenshotAsset>{
        for (final asset in candidates) asset.id: asset,
      }.values.toList()..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      final selected = unique.take(limit).toList(growable: false);
      for (var offset = 0; offset < selected.length; offset += pageSize) {
        yield selected.sublist(
          offset,
          (offset + pageSize).clamp(0, selected.length),
        );
      }
      return;
    }

    final seen = <String>{};
    for (final source in sources) {
      await for (final batch in _readSource(
        source,
        pageSize: pageSize,
        capturedSince: capturedSince,
      )) {
        final unique = batch.where((asset) => seen.add(asset.id)).toList();
        if (unique.isNotEmpty) yield unique;
      }
    }
  }

  Stream<List<LocalScreenshotAsset>> _readSource(
    _ScreenshotSource source, {
    required int pageSize,
    int? maxAssets,
    DateTime? capturedSince,
  }) async* {
    var page = 0;
    var emitted = 0;
    while (maxAssets == null || emitted < maxAssets) {
      final requestSize = maxAssets == null
          ? pageSize
          : (maxAssets - emitted).clamp(1, pageSize);
      final entities = await source.path.getAssetListPaged(
        page: page,
        size: requestSize,
        type: RequestType.image,
      );
      if (entities.isEmpty) break;
      final mapped = <LocalScreenshotAsset>[];
      var reachedCutoff = false;
      for (final entity in entities) {
        final capturedAt = entity.createDateTime.toUtc();
        if (capturedSince != null && capturedAt.isBefore(capturedSince)) {
          reachedCutoff = true;
          continue;
        }
        if (source.requiresAssetFilter &&
            !_detectionStrategy.isAndroidScreenshotAsset(
              title: entity.title,
              relativePath: entity.relativePath,
            )) {
          continue;
        }
        mapped.add(
          LocalScreenshotAsset(
            id: entity.id,
            capturedAt: capturedAt,
            width: entity.orientatedWidth,
            height: entity.orientatedHeight,
            title: entity.title,
          ),
        );
      }
      emitted += mapped.length;
      if (mapped.isNotEmpty) yield mapped;
      if (entities.length < requestSize || reachedCutoff) break;
      page += 1;
    }
  }

  Future<List<_ScreenshotSource>> _sources() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final paths = await PhotoManager.getAssetPathList(
        hasAll: false,
        type: RequestType.image,
        filterOption: _assetFilter,
        pathFilterOption: const PMPathFilter(
          darwin: PMDarwinPathFilter(
            type: [PMDarwinAssetCollectionType.smartAlbum],
            subType: [PMDarwinAssetCollectionSubtype.smartAlbumScreenshots],
          ),
        ),
      );
      return paths
          .where(
            (path) =>
                path.albumTypeEx?.darwin?.subtype ==
                PMDarwinAssetCollectionSubtype.smartAlbumScreenshots,
          )
          .map((path) => _ScreenshotSource(path))
          .toList(growable: false);
    }

    if (Platform.isAndroid) {
      final paths = await PhotoManager.getAssetPathList(
        hasAll: false,
        type: RequestType.image,
        filterOption: _assetFilter,
      );
      final matches = <_ScreenshotSource>[];
      for (final path in paths) {
        final relativePath = await path.relativePathAsync;
        if (_detectionStrategy.isAndroidScreenshotLocation(
          albumName: path.name,
          relativePath: relativePath,
        )) {
          matches.add(_ScreenshotSource(path));
        }
      }
      if (matches.isNotEmpty) return matches;

      final root = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
        filterOption: _assetFilter,
      );
      return root
          .map((path) => _ScreenshotSource(path, requiresAssetFilter: true))
          .toList(growable: false);
    }

    return const [];
  }

  @override
  Future<bool> assetExists(String localAssetId) async =>
      await AssetEntity.fromId(localAssetId) != null;

  @override
  Future<LocalAssetThumbnailData?> loadThumbnail(
    String localAssetId, {
    required int width,
    required int height,
  }) async {
    final entity = await AssetEntity.fromId(localAssetId);
    if (entity == null) return null;
    final size = ThumbnailSize(width, height);
    final option = Platform.isIOS || Platform.isMacOS
        ? ThumbnailOption.ios(
            size: size,
            quality: 85,
            resizeContentMode: ResizeContentMode.fit,
          )
        : ThumbnailOption(size: size, quality: 85);
    final bytes = await entity.thumbnailDataWithOption(option);
    if (bytes == null) return null;
    return LocalAssetThumbnailData(
      bytes: bytes,
      width: entity.orientatedWidth,
      height: entity.orientatedHeight,
    );
  }

  @override
  Stream<void> get changes => _changes.stream;

  void _onLibraryChanged(MethodCall _) => _changes.add(null);

  @override
  Future<void> startObservingChanges() async {
    if (_observing) return;
    _observing = true;
    PhotoManager.addChangeCallback(_onLibraryChanged);
    await PhotoManager.startChangeNotify();
  }

  @override
  Future<void> stopObservingChanges() async {
    if (!_observing) return;
    _observing = false;
    PhotoManager.removeChangeCallback(_onLibraryChanged);
    await PhotoManager.stopChangeNotify();
  }

  Future<void> dispose() async {
    await stopObservingChanges();
    await _changes.close();
  }
}

final class _ScreenshotSource {
  const _ScreenshotSource(this.path, {this.requiresAssetFilter = false});

  final AssetPathEntity path;
  final bool requiresAssetFilter;
}
// ignore_for_file: prefer_initializing_formals
