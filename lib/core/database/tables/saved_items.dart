import 'package:drift/drift.dart';
import 'package:kipto/core/database/converters/json_converters.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

@DataClassName('SavedItemRow')
@TableIndex(name: 'saved_items_status_idx', columns: {#status})
@TableIndex(name: 'saved_items_category_idx', columns: {#category})
@TableIndex(name: 'saved_items_captured_at_idx', columns: {#capturedAt})
@TableIndex(name: 'saved_items_updated_at_idx', columns: {#updatedAt})
@TableIndex(name: 'saved_items_deleted_at_idx', columns: {#deletedAt})
@TableIndex(
  name: 'saved_items_local_asset_id_unique_idx',
  columns: {#localAssetId},
  unique: true,
)
class SavedItems extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get category => text().map(const SavedItemCategoryConverter())();
  TextColumn get subtype => text().nullable()();
  TextColumn get intent => text().nullable()();
  TextColumn get status => text().map(const SavedItemStatusConverter())();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get eventAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get entities =>
      text().map(const JsonMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get availableActions => text()
      .map(const SavedItemActionsConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get cloudPreviewPath => text().nullable()();
  TextColumn get imageHash => text().nullable()();
  TextColumn get analysisStatus =>
      text().map(const AnalysisStatusConverter())();
  IntColumn get analysisVersion => integer().withDefault(const Constant(1))();
  RealColumn get confidence => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get localAssetId => text().nullable()();
  BoolColumn get originalAvailable =>
      boolean().withDefault(const Constant(false))();
  TextColumn get previewCachePath => text().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
