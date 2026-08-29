import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/screenshot_import_state.dart';

part 'screenshot_import_state_dao.g.dart';

@DriftAccessor(tables: [ScreenshotImportStates])
class ScreenshotImportStateDao extends DatabaseAccessor<AppDatabase>
    with _$ScreenshotImportStateDaoMixin {
  ScreenshotImportStateDao(super.attachedDatabase);

  Future<ScreenshotImportStateRow?> readLocal() =>
      (select(screenshotImportStates)
            ..where((row) => row.id.equals('local'))
            ..limit(1))
          .getSingleOrNull();

  Future<void> writeLocal(ScreenshotImportStatesCompanion state) =>
      into(screenshotImportStates).insertOnConflictUpdate(state);
}
