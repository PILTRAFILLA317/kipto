import 'package:drift/drift.dart';
import 'package:kipto/core/database/tables/items.dart';
import 'package:kipto/core/database/tables/sources.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

@DataClassName('FactRow')
@TableIndex(name: 'facts_item_idx', columns: {#itemId})
class Facts extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get ownerId => text().nullable()();
  TextColumn get sourceId => text().nullable().references(Sources, #id)();
  IntColumn get sourceRevision => integer().nullable()();
  TextColumn get key => text()();
  TextColumn get valueType => text()();
  TextColumn get value => text()();
  TextColumn get userValue => text().nullable()();
  TextColumn get provenance => text()();
  TextColumn get evidence => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get remoteServerUpdatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ItemActionRow')
@TableIndex(name: 'item_actions_item_idx', columns: {#itemId})
class ItemActions extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get ownerId => text().nullable()();
  TextColumn get sourceId => text().nullable().references(Sources, #id)();
  IntColumn get analysisRevision => integer().nullable()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  IntColumn get payloadVersion => integer().withDefault(const Constant(1))();
  TextColumn get payload => text()();
  TextColumn get origin => text()();
  TextColumn get evidenceFactIds => text().withDefault(const Constant('[]'))();
  TextColumn get state => text().withDefault(const Constant('proposed'))();
  TextColumn get executionState =>
      text().withDefault(const Constant('notRequested'))();
  DateTimeColumn get acceptedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get remoteServerUpdatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
