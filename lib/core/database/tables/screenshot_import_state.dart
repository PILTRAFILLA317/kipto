import 'package:drift/drift.dart';

@DataClassName('ScreenshotImportStateRow')
class ScreenshotImportStates extends Table {
  TextColumn get id => text().withDefault(const Constant('local'))();
  BoolColumn get initialImportCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastScanAt => dateTime().nullable()();
  IntColumn get lastKnownScreenshotCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSuccessfulScanAt => dateTime().nullable()();
  TextColumn get importScope => text().nullable()();
  IntColumn get scanVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastReconciledAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
