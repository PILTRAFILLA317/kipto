import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/repositories/drift_screenshot_import_state_repository.dart';
import 'package:kipto/core/repositories/drift_screenshot_items_repository.dart';
import 'package:kipto/dev/seed/demo_seed_service.dart';
import 'package:kipto/features/photo_library/application/screenshot_import_service.dart';
import 'package:kipto/features/photo_library/data/photo_manager_photo_library_repository.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/photo_library_repository.dart';
import 'package:kipto/features/photo_library/domain/screenshot_import_state.dart';
import 'package:kipto/features/photo_library/domain/screenshot_items_repository.dart';

final photoLibraryRepositoryProvider = Provider<PhotoLibraryRepository>((ref) {
  final repository = PhotoManagerPhotoLibraryRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final screenshotItemsRepositoryProvider = Provider<ScreenshotItemsRepository>(
  (ref) => DriftScreenshotItemsRepository(ref.watch(appDatabaseProvider)),
);

final screenshotImportStateRepositoryProvider =
    Provider<ScreenshotImportStateRepository>(
      (ref) =>
          DriftScreenshotImportStateRepository(ref.watch(appDatabaseProvider)),
    );

final demoSeedServiceProvider = Provider<DemoSeedService>(
  (ref) => DemoSeedService(ref.watch(appDatabaseProvider)),
);

final screenshotImportServiceProvider = Provider<ScreenshotImportService>(
  (ref) => ScreenshotImportService(
    photoLibrary: ref.watch(photoLibraryRepositoryProvider),
    screenshotItems: ref.watch(screenshotItemsRepositoryProvider),
    importState: ref.watch(screenshotImportStateRepositoryProvider),
    demoSeedService: ref.watch(demoSeedServiceProvider),
  ),
);

final screenshotImportControllerProvider =
    StateNotifierProvider<ScreenshotImportController, ScreenshotImportUiState>(
      (ref) => ScreenshotImportController(
        photoLibrary: ref.watch(photoLibraryRepositoryProvider),
        screenshotItems: ref.watch(screenshotItemsRepositoryProvider),
        importState: ref.watch(screenshotImportStateRepositoryProvider),
        importService: ref.watch(screenshotImportServiceProvider),
      ),
    );

typedef ThumbnailRequest = ({String id, int width, int height});

final localAssetThumbnailProvider = FutureProvider.autoDispose
    .family<LocalAssetThumbnailData?, ThumbnailRequest>(
      (ref, request) => ref
          .watch(photoLibraryRepositoryProvider)
          .loadThumbnail(
            request.id,
            width: request.width,
            height: request.height,
          ),
    );

final class ScreenshotImportController
    extends StateNotifier<ScreenshotImportUiState> {
  ScreenshotImportController({
    required PhotoLibraryRepository photoLibrary,
    required ScreenshotItemsRepository screenshotItems,
    required ScreenshotImportStateRepository importState,
    required ScreenshotImportService importService,
  }) : _photoLibrary = photoLibrary,
       _screenshotItems = screenshotItems,
       _importState = importState,
       _importService = importService,
       super(const ScreenshotImportUiState());

  final PhotoLibraryRepository _photoLibrary;
  final ScreenshotItemsRepository _screenshotItems;
  final ScreenshotImportStateRepository _importState;
  final ScreenshotImportService _importService;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _refresh(runIncrementalScan: true);
  }

  Future<void> _refresh({required bool runIncrementalScan}) async {
    try {
      final permission = await _photoLibrary.getPermissionStatus();
      final persisted = await _importState.read();
      final imported = await _screenshotItems.countImported();
      if (!permission.hasAccess) {
        state = state.copyWith(
          phase: ScreenshotImportPhase.idle,
          permission: permission,
          importedCount: imported,
          initialImportCompleted: persisted.initialImportCompleted,
          clearError: true,
        );
        return;
      }
      final available = await _photoLibrary.countScreenshots();
      state = state.copyWith(
        phase: persisted.initialImportCompleted
            ? ScreenshotImportPhase.idle
            : ScreenshotImportPhase.ready,
        permission: permission,
        availableCount: available,
        importedCount: imported,
        initialImportCompleted: persisted.initialImportCompleted,
        clearError: true,
      );
      if (runIncrementalScan && persisted.initialImportCompleted) {
        await scanForNewScreenshots();
      }
    } on Object catch (error) {
      state = state.copyWith(
        phase: ScreenshotImportPhase.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> requestPermission() async {
    try {
      state = state.copyWith(
        phase: ScreenshotImportPhase.scanning,
        clearError: true,
      );
      await _photoLibrary.requestPermission();
      await _refresh(runIncrementalScan: false);
      if (state.permission.hasAccess) {
        await _photoLibrary.startObservingChanges();
      }
    } on Object catch (error) {
      state = state.copyWith(
        phase: ScreenshotImportPhase.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> openSettings() => _photoLibrary.openSettings();

  Future<void> manageLimitedAccess() async {
    await _photoLibrary.manageLimitedAccess();
    await _refresh(runIncrementalScan: false);
    if (state.initialImportCompleted && state.permission.hasAccess) {
      await scanForNewScreenshots(forceFullScan: true, forceReconcile: true);
    }
  }

  void selectScope(ScreenshotImportScope scope) {
    if (state.phase == ScreenshotImportPhase.importing) return;
    state = state.copyWith(scope: scope);
  }

  void showImportOptions() {
    state = state.copyWith(
      phase: ScreenshotImportPhase.ready,
      clearError: true,
    );
  }

  Future<void> importSelected() async {
    try {
      final plan = await _importService.prepareImport(state.scope);
      state = state.copyWith(
        phase: ScreenshotImportPhase.importing,
        progress: ScreenshotImportProgress(total: plan.total),
        clearError: true,
      );
      final result = await _importService.import(
        state.scope,
        onProgress: (progress) {
          if (mounted) state = state.copyWith(progress: progress);
        },
      );
      final imported = await _screenshotItems.countImported();
      final available = await _photoLibrary.countScreenshots();
      state = state.copyWith(
        phase: ScreenshotImportPhase.completed,
        progress: result,
        importedCount: imported,
        availableCount: available,
        initialImportCompleted: true,
      );
    } on Object catch (error) {
      state = state.copyWith(
        phase: ScreenshotImportPhase.error,
        errorMessage: error.toString(),
      );
    }
  }

  void finishImport() {
    state = state.copyWith(phase: ScreenshotImportPhase.idle, clearError: true);
  }

  Future<void> scanForNewScreenshots({
    bool forceFullScan = false,
    bool forceReconcile = false,
  }) async {
    if (!state.permission.hasAccess ||
        !state.initialImportCompleted ||
        _importService.isBusy) {
      return;
    }
    try {
      state = state.copyWith(
        phase: ScreenshotImportPhase.scanning,
        clearError: true,
      );
      await _importService.scanIncremental(
        forceFullScan: forceFullScan,
        forceReconcile: forceReconcile,
      );
      final imported = await _screenshotItems.countImported();
      final available = await _photoLibrary.countScreenshots();
      final permission = await _photoLibrary.getPermissionStatus();
      state = state.copyWith(
        phase: ScreenshotImportPhase.idle,
        permission: permission,
        importedCount: imported,
        availableCount: available,
      );
    } on Object catch (error) {
      state = state.copyWith(
        phase: ScreenshotImportPhase.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> onResumed() => _refresh(runIncrementalScan: true);
}
// ignore_for_file: prefer_initializing_formals
