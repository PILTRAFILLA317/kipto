import 'package:drift/drift.dart';
import 'package:kipto/core/database/tables/saved_items.dart';

@DataClassName('PreviewTransferJobRow')
@TableIndex(
  name: 'preview_transfer_jobs_due_idx',
  columns: {#state, #nextAttemptAt, #createdAt},
)
class PreviewTransferJobs extends Table {
  TextColumn get savedItemId =>
      text().references(SavedItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get operation => text()();
  TextColumn get state => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {savedItemId};
}
