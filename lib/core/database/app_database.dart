import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:kipto/core/database/converters/json_converters.dart';
import 'package:kipto/core/database/daos/reminders_dao.dart';
import 'package:kipto/core/database/daos/screenshot_import_state_dao.dart';
import 'package:kipto/core/database/daos/saved_items_dao.dart';
import 'package:kipto/core/database/daos/sync_queue_dao.dart';
import 'package:kipto/core/database/tables/reminders.dart';
import 'package:kipto/core/database/tables/screenshot_import_state.dart';
import 'package:kipto/core/database/tables/saved_items.dart';
import 'package:kipto/core/database/tables/sync_queue.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [SavedItems, Reminders, SyncQueue, ScreenshotImportStates],
  daos: [SavedItemsDao, RemindersDao, SyncQueueDao, ScreenshotImportStateDao],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'kipto'));

  @override
  int get schemaVersion => 2;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
