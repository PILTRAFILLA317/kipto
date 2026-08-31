import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:kipto/core/database/converters/json_converters.dart';
import 'package:kipto/core/database/daos/reminders_dao.dart';
import 'package:kipto/core/database/daos/screenshot_import_state_dao.dart';
import 'package:kipto/core/database/daos/saved_items_dao.dart';
import 'package:kipto/core/database/daos/sync_queue_dao.dart';
import 'package:kipto/core/database/tables/reminders.dart';
import 'package:kipto/core/database/tables/cloud_sync_state.dart';
import 'package:kipto/core/database/tables/screenshot_import_state.dart';
import 'package:kipto/core/database/tables/saved_items.dart';
import 'package:kipto/core/database/tables/sync_queue.dart';
import 'package:kipto/core/database/tables/preview_transfer_jobs.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SavedItems,
    Reminders,
    SyncQueue,
    ScreenshotImportStates,
    CloudSyncStates,
    PreviewTransferJobs,
  ],
  daos: [SavedItemsDao, RemindersDao, SyncQueueDao, ScreenshotImportStateDao],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'kipto'));

  @override
  int get schemaVersion => 6;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createAnalysisQueue();
      await _createNotificationMappings();
    },
    onUpgrade: (migrator, from, to) async {
      if (from >= to) return;
      if (from == 1) {
        await migrator.createTable(screenshotImportStates);
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS '
          'saved_items_local_asset_id_unique_idx '
          'ON saved_items (local_asset_id)',
        );
      }
      if (from < 3) {
        if (!await _columnExists('saved_items', 'remote_server_updated_at')) {
          await migrator.addColumn(
            savedItems,
            savedItems.remoteServerUpdatedAt,
          );
        }
        if (!await _columnExists('reminders', 'last_synced_at')) {
          await migrator.addColumn(reminders, reminders.lastSyncedAt);
        }
        if (!await _columnExists('reminders', 'remote_server_updated_at')) {
          await migrator.addColumn(reminders, reminders.remoteServerUpdatedAt);
        }
        if (!await _tableExists('cloud_sync_states')) {
          await migrator.createTable(cloudSyncStates);
        }
      }
      if (from < 4) {
        await _createAnalysisQueue();
      }
      if (from < 5) {
        await _createNotificationMappings();
      }
      if (from < 6 && !await _tableExists('preview_transfer_jobs')) {
        await migrator.createTable(previewTransferJobs);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createAnalysisQueue() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS analysis_queue (
        saved_item_id TEXT NOT NULL PRIMARY KEY
          REFERENCES saved_items(id) ON DELETE CASCADE,
        state TEXT NOT NULL CHECK (
          state IN ('queued', 'processing', 'retryScheduled', 'paused')
        ),
        priority INTEGER NOT NULL DEFAULT 0,
        attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
        next_attempt_at TEXT,
        enqueued_at TEXT NOT NULL,
        started_at TEXT,
        last_error_code TEXT
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS analysis_queue_due_idx
      ON analysis_queue (state, next_attempt_at, priority, enqueued_at)
    ''');
  }

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

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((row) => row.data['name'] == column);
  }

  Future<bool> _tableExists(String table) async {
    final row = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
      variables: [Variable.withString(table)],
    ).getSingleOrNull();
    return row != null;
  }
}
