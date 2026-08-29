// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screenshot_import_state_dao.dart';

// ignore_for_file: type=lint
mixin _$ScreenshotImportStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScreenshotImportStatesTable get screenshotImportStates =>
      attachedDatabase.screenshotImportStates;
  ScreenshotImportStateDaoManager get managers =>
      ScreenshotImportStateDaoManager(this);
}

class ScreenshotImportStateDaoManager {
  final _$ScreenshotImportStateDaoMixin _db;
  ScreenshotImportStateDaoManager(this._db);
  $$ScreenshotImportStatesTableTableManager get screenshotImportStates =>
      $$ScreenshotImportStatesTableTableManager(
        _db.attachedDatabase,
        _db.screenshotImportStates,
      );
}
