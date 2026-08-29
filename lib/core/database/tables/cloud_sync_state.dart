import 'package:drift/drift.dart';

@DataClassName('CloudSyncStateRow')
class CloudSyncStates extends Table {
  TextColumn get id => text().withDefault(const Constant('local'))();
  TextColumn get installationId => text()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get lastSavedItemsCursor => dateTime().nullable()();
  DateTimeColumn get lastRemindersCursor => dateTime().nullable()();
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
