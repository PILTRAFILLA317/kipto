import 'package:drift/drift.dart';

/// Durable transfers survive restarts and source tombstones. A deletion job
/// deliberately has no cascading FK to the source it must clean up.
@DataClassName('FileJobRow')
class FileJobs extends Table {
  TextColumn get sourceId => text()();
  TextColumn get ownerId => text()();
  IntColumn get revision => integer()();
  TextColumn get operation => text()();
  TextColumn get state => text().withDefault(const Constant('queued'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get transferredBytes => integer().withDefault(const Constant(0))();
  TextColumn get errorCode => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {sourceId, ownerId, revision};
}
