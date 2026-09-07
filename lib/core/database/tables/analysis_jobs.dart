import 'package:drift/drift.dart';
import 'package:kipto/core/database/tables/sources.dart';

/// Device-local work. Payload is immutable after preparation and is removed
/// after success; neither payload nor results are sent through metadata sync.
@DataClassName('AnalysisJobRow')
class AnalysisJobs extends Table {
  TextColumn get sourceId =>
      text().references(Sources, #id, onDelete: KeyAction.cascade)();
  TextColumn get requestId => text().unique()();
  TextColumn get ownerId => text()();
  IntColumn get revision => integer()();
  TextColumn get locale => text()();
  TextColumn get timeZone => text()();
  TextColumn get state => text().withDefault(const Constant('queued'))();
  TextColumn get payload => text().nullable()();
  TextColumn get envelope => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get requestedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {sourceId};
}
