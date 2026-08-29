import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/screenshot_import_state.dart';

final class DriftScreenshotImportStateRepository
    implements ScreenshotImportStateRepository {
  DriftScreenshotImportStateRepository(this._database);

  final AppDatabase _database;

  @override
  Future<ScreenshotImportState> read() async {
    final row = await _database.screenshotImportStateDao.readLocal();
    if (row == null) return const ScreenshotImportState();
    return ScreenshotImportState(
      initialImportCompleted: row.initialImportCompleted,
      lastScanAt: row.lastScanAt,
      lastKnownScreenshotCount: row.lastKnownScreenshotCount,
      lastSuccessfulScanAt: row.lastSuccessfulScanAt,
      importScope: ScreenshotImportScope.values
          .where((scope) => scope.name == row.importScope)
          .firstOrNull,
      scanVersion: row.scanVersion,
      lastReconciledAt: row.lastReconciledAt,
    );
  }

  @override
  Future<void> write(ScreenshotImportState state) =>
      _database.screenshotImportStateDao.writeLocal(
        ScreenshotImportStatesCompanion.insert(
          initialImportCompleted: Value(state.initialImportCompleted),
          lastScanAt: Value(state.lastScanAt?.toUtc()),
          lastKnownScreenshotCount: Value(state.lastKnownScreenshotCount),
          lastSuccessfulScanAt: Value(state.lastSuccessfulScanAt?.toUtc()),
          importScope: Value(state.importScope?.name),
          scanVersion: Value(state.scanVersion),
          lastReconciledAt: Value(state.lastReconciledAt?.toUtc()),
        ),
      );
}
