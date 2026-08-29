import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/dev/seed/development_seed.dart';

final class DemoSeedService {
  DemoSeedService(this._database);

  final AppDatabase _database;

  Future<void> clearSeedData() => _database.transaction(() async {
    await (_database.delete(_database.reminders)..where(
          (row) =>
              row.id.equals(DevelopmentSeed.reminderId) |
              row.savedItemId.isIn(DevelopmentSeed.knownItemIds),
        ))
        .go();
    await (_database.delete(
      _database.savedItems,
    )..where((row) => row.id.isIn(DevelopmentSeed.knownItemIds))).go();
  });
}
