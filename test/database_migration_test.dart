import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';

void main() {
  for (final version in [9, 10]) {
    test('T03 v$version to v11 preserves sources and pending sync', () async {
      final root = await Directory.systemTemp.createTemp('kipto-migration-');
      addTearDown(() => root.delete(recursive: true));
      final file = File('${root.path}/library.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      await db.customStatement(
        "INSERT INTO items(id,title,status,created_at,updated_at,sync_status) VALUES ('matter','Synthetic','active','2026-09-05','2026-09-05','localOnly')",
      );
      await db.customStatement(
        "INSERT INTO sources(id,item_id,kind,origin,original_name,mime_type,byte_size,content_hash,created_at,updated_at,sync_status) VALUES ('source','matter','text','manual','Synthetic','text/plain',3,'hash','2026-09-05','2026-09-05','localOnly')",
      );
      await db.customStatement(
        "INSERT INTO source_files(source_id,original_relative_path,availability) VALUES ('source','source/original','local')",
      );
      await db.customStatement(
        "INSERT INTO sync_queue(id,entity_type,entity_id,operation,created_at) VALUES ('queue','source','source','create','2026-09-05')",
      );
      final before = <String, List<Map<String, dynamic>>>{};
      for (final table in ['items', 'sources', 'source_files', 'sync_queue']) {
        before[table] = (await db.customSelect('SELECT * FROM $table').get())
            .map((r) => r.data)
            .toList();
      }
      await db.customStatement('DROP TABLE file_jobs');
      if (version == 9) await db.customStatement('DROP TABLE analysis_jobs');
      await db.customStatement('PRAGMA user_version = $version');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      addTearDown(() => db.close());
      for (final table in before.keys) {
        expect(
          (await db.customSelect('SELECT * FROM $table').get())
              .map((r) => r.data)
              .toList(),
          before[table],
        );
      }
      expect(await db.select(db.fileJobs).get(), isEmpty);
      expect(await db.select(db.analysisJobs).get(), isEmpty);
    });
  }
  test('v6 Screenshot Inbox databases reset deterministically to Life Admin', () async {
    final directory = await Directory.systemTemp.createTemp('kipto-v7-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/kipto.sqlite');
    final setup = AppDatabase(NativeDatabase(file));
    await setup.customStatement('DROP TABLE file_jobs');
    await setup.customStatement('DROP TABLE analysis_jobs');
    await setup.customStatement('DROP TABLE item_actions');
    await setup.customStatement('DROP TABLE facts');
    await setup.customStatement('DROP TABLE source_files');
    await setup.customStatement('DROP TABLE sources');
    await setup.customStatement('DROP TABLE notification_mappings');
    await setup.customStatement('DROP TABLE reminders');
    await setup.customStatement('DROP TABLE items');
    await setup.customStatement('DROP TABLE sync_queue');
    await setup.customStatement('DROP TABLE cloud_sync_states');
    await setup.customStatement(
      'CREATE TABLE saved_items (id TEXT PRIMARY KEY, title TEXT NOT NULL)',
    );
    await setup.customStatement(
      'CREATE TABLE reminders (id TEXT PRIMARY KEY, saved_item_id TEXT NOT NULL)',
    );
    await setup.customStatement(
      'CREATE TABLE screenshot_import_states (id TEXT PRIMARY KEY)',
    );
    await setup.customStatement(
      'CREATE TABLE analysis_queue (id TEXT PRIMARY KEY)',
    );
    await setup.customStatement(
      'CREATE TABLE preview_transfer_jobs (id TEXT PRIMARY KEY)',
    );
    await setup.customStatement(
      'CREATE TABLE sync_queue (id TEXT PRIMARY KEY)',
    );
    await setup.customStatement(
      'CREATE TABLE cloud_sync_states (id TEXT PRIMARY KEY)',
    );
    await setup.customStatement(
      "INSERT INTO saved_items (id, title) VALUES ('legacy', 'Old screenshot')",
    );
    await setup.customStatement('PRAGMA user_version = 6');
    await setup.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final tables =
        (await migrated
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'table'",
                )
                .get())
            .map((row) => row.read<String>('name'))
            .toSet();

    expect(migrated.schemaVersion, 11);
    expect(
      tables,
      containsAll({
        'items',
        'reminders',
        'sync_queue',
        'cloud_sync_states',
        'notification_mappings',
      }),
    );
    expect(
      tables,
      isNot(
        containsAll({
          'saved_items',
          'screenshot_import_states',
          'analysis_queue',
          'preview_transfer_jobs',
        }),
      ),
    );
    await migrated.customStatement(
      "INSERT INTO items (id, title, status, created_at, updated_at, sync_status) "
      "VALUES ('item', 'New item', 'active', '2026-09-03T00:00:00.000Z', "
      "'2026-09-03T00:00:00.000Z', 'localOnly')",
    );
    await migrated.customStatement(
      "INSERT INTO reminders (id, item_id, remind_at, created_at, updated_at, sync_status) "
      "VALUES ('reminder', 'item', '2026-09-04T00:00:00.000Z', "
      "'2026-09-03T00:00:00.000Z', '2026-09-03T00:00:00.000Z', 'localOnly')",
    );
    expect(await migrated.remindersDao.findById('reminder'), isNotNull);
  });
}
