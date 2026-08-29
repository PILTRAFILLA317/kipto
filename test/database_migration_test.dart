import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';

import 'test_helpers.dart';

void main() {
  test('v1 to v2 preserves SavedItems and creates import state', () async {
    final directory = await Directory.systemTemp.createTemp(
      'kipto-migration-test-',
    );
    final file = File('${directory.path}/kipto.sqlite');
    addTearDown(() => directory.delete(recursive: true));
    final now = DateTime.utc(2026, 8, 29, 12);

    final setup = AppDatabase(NativeDatabase(file));
    await DriftSavedItemsRepository(setup)
        .create(testSavedItem(id: 'phase-one-item', now: now));
    await setup.customStatement('DROP TABLE screenshot_import_states');
    await setup.customStatement(
      'DROP INDEX saved_items_local_asset_id_unique_idx',
    );
    await setup.customStatement('PRAGMA user_version = 1');
    await setup.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final item = await migrated.savedItemsDao.findById('phase-one-item');
    final state = await migrated.screenshotImportStateDao.readLocal();
    final indexes = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'saved_items_local_asset_id_unique_idx'",
        )
        .get();

    expect(item?.id, 'phase-one-item');
    expect(state, isNull);
    expect(indexes, hasLength(1));
    expect(migrated.schemaVersion, 2);
  });
}
