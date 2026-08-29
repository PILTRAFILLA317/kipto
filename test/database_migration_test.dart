import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';

import 'test_helpers.dart';

void main() {
  test('v1 through v3 preserves SavedItems and creates new state', () async {
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
    expect(migrated.schemaVersion, 3);
    expect(
      await migrated
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'cloud_sync_states'",
          )
          .get(),
      hasLength(1),
    );
  });

  test('v2 to v3 preserves screenshot fields and reminders', () async {
    final directory = await Directory.systemTemp.createTemp(
      'kipto-v3-migration-test-',
    );
    final file = File('${directory.path}/kipto.sqlite');
    addTearDown(() => directory.delete(recursive: true));
    final now = DateTime.utc(2026, 8, 29, 12);

    final setup = AppDatabase(NativeDatabase(file));
    final item = testSavedItem(id: 'phase-two-item', now: now);
    await DriftSavedItemsRepository(setup).create(item);
    await DriftRemindersRepository(
      setup,
      idGenerator: () => 'phase-two-reminder',
    ).create(savedItemId: item.id, remindAt: now.add(const Duration(days: 1)));
    await setup.customStatement(
      "UPDATE saved_items SET local_asset_id = 'photo-asset', "
      'original_available = 1 WHERE id = ?',
      ['phase-two-item'],
    );
    await setup.customStatement(
      'ALTER TABLE saved_items DROP COLUMN remote_server_updated_at',
    );
    await setup.customStatement(
      'ALTER TABLE reminders DROP COLUMN last_synced_at',
    );
    await setup.customStatement(
      'ALTER TABLE reminders DROP COLUMN remote_server_updated_at',
    );
    await setup.customStatement('DROP TABLE cloud_sync_states');
    await setup.customStatement('PRAGMA user_version = 2');
    await setup.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final preserved = await migrated.savedItemsDao.findById('phase-two-item');
    expect(preserved?.localAssetId, 'photo-asset');
    expect(preserved?.originalAvailable, isTrue);
    expect(preserved?.remoteServerUpdatedAt, isNull);
    expect(
      (await migrated.remindersDao.findById('phase-two-reminder'))?.savedItemId,
      'phase-two-item',
    );
    expect(migrated.schemaVersion, 3);
  });
}
