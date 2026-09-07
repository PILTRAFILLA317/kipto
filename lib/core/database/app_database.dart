import 'package:kipto/core/database/tables/file_jobs.dart';
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

import 'package:kipto/core/database/tables/sources.dart';
import 'package:kipto/core/database/tables/life_admin.dart';
import 'package:kipto/core/database/tables/analysis_jobs.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Items,
    Reminders,
    SyncQueue,
    CloudSyncStates,
    Sources,
    SourceFiles,
    Facts,
    ItemActions,
    AnalysisJobs,
    FileJobs,
  ],
  daos: [ItemsDao, RemindersDao, SyncQueueDao],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'kipto'));

  @override
  int get schemaVersion => 11;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createNotificationMappings();
      await _createSourceOwnershipGuards();
      await _createLifeAdminGuards();
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
      if (from < 8) {
        await migrator.createTable(sources);
        await migrator.createTable(sourceFiles);
        if (from >= 7) {
          await migrator.addColumn(
            cloudSyncStates,
            cloudSyncStates.lastSourcesCursor,
          );
        }
        await _createSourceOwnershipGuards();
      }
      if (from < 9) {
        await migrator.createTable(facts);
        await migrator.createTable(itemActions);
        if (from >= 7) {
          await migrator.addColumn(reminders, reminders.actionId);
          await migrator.addColumn(reminders, reminders.title);
          await migrator.addColumn(reminders, reminders.timeZone);
          await migrator.addColumn(
            cloudSyncStates,
            cloudSyncStates.lastFactsCursor,
          );
          await migrator.addColumn(
            cloudSyncStates,
            cloudSyncStates.lastActionsCursor,
          );
        }
        await _createLifeAdminGuards();
      }
      if (from < 10) {
        await migrator.createTable(analysisJobs);
      }
      if (from < 11) {
        await migrator.createTable(fileJobs);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createSourceOwnershipGuards() async {
    for (final operation in ['INSERT', 'UPDATE']) {
      await customStatement("""
        CREATE TRIGGER IF NOT EXISTS sources_owner_${operation.toLowerCase()}
        BEFORE $operation ON sources
        WHEN NOT EXISTS (SELECT 1 FROM items i WHERE i.id = NEW.item_id AND i.owner_id IS NEW.owner_id)
        BEGIN SELECT RAISE(ABORT, 'Source owner must match Item owner'); END
      """);
    }
  }

  Future<void> _createLifeAdminGuards() async {
    for (final operation in ['INSERT', 'UPDATE']) {
      for (final table in ['facts', 'item_actions', 'reminders']) {
        await customStatement("""
          CREATE TRIGGER IF NOT EXISTS ${table}_owner_${operation.toLowerCase()}
          BEFORE $operation ON $table
          WHEN NOT EXISTS (SELECT 1 FROM items i WHERE i.id = NEW.item_id AND i.owner_id IS NEW.owner_id)
          BEGIN SELECT RAISE(ABORT, 'Child owner must match Item owner'); END
        """);
      }
      for (final table in ['facts', 'item_actions']) {
        await customStatement("""
          CREATE TRIGGER IF NOT EXISTS ${table}_source_${operation.toLowerCase()}
          BEFORE $operation ON $table
          WHEN NEW.source_id IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM sources s WHERE s.id = NEW.source_id
              AND s.item_id = NEW.item_id AND s.owner_id IS NEW.owner_id)
          BEGIN SELECT RAISE(ABORT, 'Evidence source must match Item and owner'); END
        """);
      }
      await customStatement("""
        CREATE TRIGGER IF NOT EXISTS item_actions_facts_${operation.toLowerCase()}
        BEFORE $operation ON item_actions
        WHEN EXISTS (SELECT 1 FROM json_each(NEW.evidence_fact_ids) ref
          WHERE NOT EXISTS (SELECT 1 FROM facts f WHERE f.id = ref.value
            AND f.item_id = NEW.item_id AND f.owner_id IS NEW.owner_id))
        BEGIN SELECT RAISE(ABORT, 'Action evidence must match Item and owner'); END
      """);
      await customStatement("""
        CREATE TRIGGER IF NOT EXISTS reminders_action_${operation.toLowerCase()}
        BEFORE $operation ON reminders
        WHEN NEW.action_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM item_actions a
          WHERE a.id = NEW.action_id AND a.item_id = NEW.item_id AND a.owner_id IS NEW.owner_id AND a.kind = 'remind')
        BEGIN SELECT RAISE(ABORT, 'Reminder action must match Item and owner'); END
      """);
    }
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS reminders_action_idx ON reminders(action_id) WHERE action_id IS NOT NULL',
    );
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
}
