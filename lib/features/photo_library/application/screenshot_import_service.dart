import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/dev/seed/demo_seed_service.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/photo_library_repository.dart';
import 'package:kipto/features/photo_library/domain/screenshot_import_state.dart';
import 'package:kipto/features/photo_library/domain/screenshot_items_repository.dart';

typedef ImportProgressCallback = void Function(ScreenshotImportProgress value);
typedef ImportedScreenshotsCallback = Future<void> Function(
  List<String> savedItemIds,
);

final class ScreenshotImportService {
  ScreenshotImportService({
    required PhotoLibraryRepository photoLibrary,
    required ScreenshotItemsRepository screenshotItems,
    required ScreenshotImportStateRepository importState,
    required DemoSeedService demoSeedService,
    this.onImportedScreenshots,
    Clock? clock,
    this.pageSize = 100,
  }) : _photoLibrary = photoLibrary,
       _screenshotItems = screenshotItems,
       _importState = importState,
       _demoSeedService = demoSeedService,
       _clock = clock ?? const Clock();

  final PhotoLibraryRepository _photoLibrary;
  final ScreenshotItemsRepository _screenshotItems;
  final ScreenshotImportStateRepository _importState;
  final DemoSeedService _demoSeedService;
  final Clock _clock;
  final int pageSize;
  final ImportedScreenshotsCallback? onImportedScreenshots;
  bool _busy = false;

  bool get isBusy => _busy;

  Future<ScreenshotImportPlan> prepareImport(
    ScreenshotImportScope scope,
  ) async {
    final now = _clock.now().toUtc();
    final total = switch (scope) {
      ScreenshotImportScope.recent100 =>
        (await _photoLibrary.countScreenshots()).clamp(0, 100),
      ScreenshotImportScope.last30Days =>
        await _photoLibrary.countScreenshotsSince(
          now.subtract(const Duration(days: 30)),
        ),
      ScreenshotImportScope.all => await _photoLibrary.countScreenshots(),
    };
    return ScreenshotImportPlan(scope: scope, total: total);
  }

  Future<ScreenshotImportProgress> import(
    ScreenshotImportScope scope, {
    ImportProgressCallback? onProgress,
  }) async {
    if (_busy) throw StateError('A photo library operation is already running');
    _busy = true;
    final stopwatch = Stopwatch()..start();
    final startedAt = _clock.now().toUtc();
    _log('photo.import.started', {'scope': scope.name});
    try {
      final permission = await _photoLibrary.getPermissionStatus();
      if (!permission.hasAccess) {
        throw StateError('Photo library access is not available');
      }
      final plan = await prepareImport(scope);
      final previousState = await _importState.read();
      if (!previousState.initialImportCompleted) {
        await _demoSeedService.clearSeedData();
      }
      final progress = await _importStream(
        _streamForScope(scope, startedAt),
        total: plan.total,
        onProgress: onProgress,
      );
      final availableCount = await _photoLibrary.countScreenshots();
      final completedAt = _clock.now().toUtc();
      await _importState.write(
        previousState.copyWith(
          initialImportCompleted: true,
          lastScanAt: startedAt,
          lastSuccessfulScanAt: completedAt,
          lastKnownScreenshotCount: availableCount,
          importScope: scope,
          lastReconciledAt: completedAt,
        ),
      );
      _log('photo.import.completed', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'processed': progress.processed,
        'imported': progress.imported,
        'skipped': progress.skipped,
        'failed': progress.failed,
      });
      return progress;
    } finally {
      _busy = false;
    }
  }

  Stream<List<LocalScreenshotAsset>> _streamForScope(
    ScreenshotImportScope scope,
    DateTime now,
  ) => switch (scope) {
    ScreenshotImportScope.recent100 => _photoLibrary.getScreenshotsPaged(
      pageSize: pageSize,
      limit: 100,
    ),
    ScreenshotImportScope.last30Days => _photoLibrary.getScreenshotsPaged(
      pageSize: pageSize,
      capturedSince: now.subtract(const Duration(days: 30)),
    ),
    ScreenshotImportScope.all => _photoLibrary.getScreenshotsPaged(
      pageSize: pageSize,
    ),
  };

  Future<ScreenshotImportProgress> _importStream(
    Stream<List<LocalScreenshotAsset>> stream, {
    required int total,
    ImportProgressCallback? onProgress,
  }) async {
    var progress = ScreenshotImportProgress(total: total);
    onProgress?.call(progress);
    await for (final batch in stream) {
      try {
        final existing = await _screenshotItems.existingLocalAssetIds(
          batch.map((asset) => asset.id),
        );
        final inserted = await _screenshotItems.importAssets(batch);
        final skipped = batch.length - inserted;
        if (inserted > 0 && onImportedScreenshots != null) {
          final newAssetIds = batch
              .map((asset) => asset.id)
              .where((id) => !existing.contains(id));
          final savedItems = await _screenshotItems.savedItemIdsForLocalAssets(
            newAssetIds,
          );
          await onImportedScreenshots!(savedItems.values.toList());
        }
        progress = progress.copyWith(
          processed: progress.processed + batch.length,
          imported: progress.imported + inserted,
          skipped: progress.skipped + skipped,
        );
      } on Object catch (error) {
        progress = progress.copyWith(
          processed: progress.processed + batch.length,
          failed: progress.failed + batch.length,
        );
        _log('photo.import.batch_failed', {
          'count': batch.length,
          'error': error.runtimeType.toString(),
        });
      }
      onProgress?.call(progress);
    }
    return progress;
  }

  Future<ScreenshotImportProgress> scanIncremental({
    bool forceFullScan = false,
    bool forceReconcile = false,
  }) async {
    if (_busy) return const ScreenshotImportProgress(total: 0);
    _busy = true;
    final stopwatch = Stopwatch()..start();
    final startedAt = _clock.now().toUtc();
    _log('photo.scan.started', {'mode': 'incremental'});
    try {
      final permission = await _photoLibrary.getPermissionStatus();
      if (!permission.hasAccess) {
        return const ScreenshotImportProgress(total: 0);
      }
      final previous = await _importState.read();
      final currentCount = await _photoLibrary.countScreenshots();
      if (!previous.initialImportCompleted) {
        await _importState.write(
          previous.copyWith(lastKnownScreenshotCount: currentCount),
        );
        return ScreenshotImportProgress(total: currentCount);
      }

      final recentLimit = currentCount.clamp(0, 200);
      var progress = await _importStream(
        _photoLibrary.getScreenshotsPaged(
          pageSize: pageSize,
          limit: recentLimit,
        ),
        total: recentLimit,
      );

      final expectedGrowth = currentCount - previous.lastKnownScreenshotCount;
      final needsFallback =
          forceFullScan || (expectedGrowth > progress.imported);
      if (needsFallback) {
        final fallback = await _importStream(
          _photoLibrary.getScreenshotsPaged(pageSize: pageSize),
          total: currentCount,
        );
        progress = ScreenshotImportProgress(
          total: recentLimit + currentCount,
          processed: progress.processed + fallback.processed,
          imported: progress.imported + fallback.imported,
          skipped: progress.skipped + fallback.skipped,
          failed: progress.failed + fallback.failed,
        );
      }

      final reconcileIsStale =
          previous.lastReconciledAt == null ||
          startedAt.difference(previous.lastReconciledAt!) >=
              const Duration(days: 1);
      var reconciledAt = previous.lastReconciledAt;
      if (forceReconcile ||
          currentCount < previous.lastKnownScreenshotCount ||
          reconcileIsStale) {
        await _reconcileWithoutGuard();
        reconciledAt = _clock.now().toUtc();
      }

      final completedAt = _clock.now().toUtc();
      await _importState.write(
        previous.copyWith(
          lastScanAt: startedAt,
          lastSuccessfulScanAt: completedAt,
          lastKnownScreenshotCount: currentCount,
          lastReconciledAt: reconciledAt,
        ),
      );
      _log('photo.scan.completed', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'examined': progress.processed,
        'imported': progress.imported,
        'duplicates': progress.skipped,
      });
      return progress;
    } finally {
      _busy = false;
    }
  }

  Future<void> reconcile() async {
    if (_busy) return;
    _busy = true;
    try {
      await _reconcileWithoutGuard();
      final state = await _importState.read();
      await _importState.write(
        state.copyWith(lastReconciledAt: _clock.now().toUtc()),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _reconcileWithoutGuard() async {
    final imported = await _screenshotItems.importedAssetAvailability();
    final entries = imported.entries.toList(growable: false);
    const concurrency = 20;
    for (var offset = 0; offset < entries.length; offset += concurrency) {
      final chunk = entries.sublist(
        offset,
        (offset + concurrency).clamp(0, entries.length),
      );
      final results = await Future.wait(
        chunk.map(
          (entry) async =>
              MapEntry(entry.key, await _photoLibrary.assetExists(entry.key)),
        ),
      );
      final missing = <String>[];
      final restored = <String>[];
      for (final result in results) {
        final wasAvailable = imported[result.key] ?? false;
        if (!result.value && wasAvailable) missing.add(result.key);
        if (result.value && !wasAvailable) restored.add(result.key);
      }
      await _screenshotItems.setOriginalAvailability(missing, false);
      await _screenshotItems.setOriginalAvailability(restored, true);
      if (missing.isNotEmpty) {
        _log('photo.asset.missing', {'count': missing.length});
      }
    }
  }

  void _log(String event, Map<String, Object?> fields) {
    if (!kDebugMode) return;
    debugPrint('$event $fields');
  }
}
// ignore_for_file: prefer_initializing_formals
