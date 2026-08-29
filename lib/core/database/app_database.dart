import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:kipto/core/database/converters/json_converters.dart';
import 'package:kipto/core/database/daos/reminders_dao.dart';
import 'package:kipto/core/database/daos/saved_items_dao.dart';
import 'package:kipto/core/database/daos/sync_queue_dao.dart';
import 'package:kipto/core/database/tables/reminders.dart';
import 'package:kipto/core/database/tables/saved_items.dart';
import 'package:kipto/core/database/tables/sync_queue.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [SavedItems, Reminders, SyncQueue],
  daos: [SavedItemsDao, RemindersDao, SyncQueueDao],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'kipto'));

  @override
  int get schemaVersion => 1;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Version 1 is the initial schema. Add explicit, sequential migration
      // steps here as schemaVersion evolves.
      if (from >= to) return;
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
