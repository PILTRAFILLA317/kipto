import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:kipto/core/database/daos/items_dao.dart';
import 'package:kipto/core/database/daos/reminders_dao.dart';
import 'package:kipto/core/database/daos/sync_queue_dao.dart';
import 'package:kipto/core/database/tables/cloud_sync_state.dart';
import 'package:kipto/core/database/tables/items.dart';
import 'package:kipto/core/database/tables/reminders.dart';
import 'package:kipto/core/database/tables/sync_queue.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Items, Reminders, SyncQueue, CloudSyncStates],
  daos: [ItemsDao, RemindersDao, SyncQueueDao],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'kipto'));

  @override
  int get schemaVersion => 7;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createNotificationMappings();
    },
    onUpgrade: (migrator, from, to) async {
      if (from >= to) return;
      if (from < 7) {
        // Pre-release product reset: legacy Screenshot Inbox data is not
        // meaningful in Life Admin and is intentionally discarded.
        await customStatement('DROP TABLE IF EXISTS notification_mappings');
        await customStatement('DROP TABLE IF EXISTS preview_transfer_jobs');
        await customStatement('DROP TABLE IF EXISTS analysis_queue');
        await customStatement('DROP TABLE IF EXISTS screenshot_import_states');
        await customStatement('DROP TABLE IF EXISTS reminders');
        await customStatement('DROP TABLE IF EXISTS saved_items');
        await customStatement('DROP TABLE IF EXISTS sync_queue');
        await customStatement('DROP TABLE IF EXISTS cloud_sync_states');
        await migrator.createTable(items);
        await migrator.createTable(reminders);
        await migrator.createTable(syncQueue);
        await migrator.createTable(cloudSyncStates);
        await _createNotificationMappings();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createNotificationMappings() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS notification_mappings (
        reminder_id TEXT NOT NULL PRIMARY KEY
          REFERENCES reminders(id) ON DELETE CASCADE,
        notification_id INTEGER NOT NULL UNIQUE,
        scheduled_for TEXT NOT NULL,
        timezone TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS notification_mappings_id_idx
      ON notification_mappings (notification_id)
    ''');
  }
}
