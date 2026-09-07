import 'package:drift/drift.dart';
import 'package:kipto/core/database/tables/items.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

@DataClassName('SourceRow')
@TableIndex(name: 'sources_item_idx', columns: {#itemId})
class Sources extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get origin => text()();
  TextColumn get originalName => text()();
  TextColumn get mimeType => text()();
  IntColumn get byteSize => integer()();
  TextColumn get contentHash => text()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get textContent => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get remoteServerUpdatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().map(const SyncStatusConverter())();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SourceFileRow')
class SourceFiles extends Table {
  TextColumn get sourceId =>
      text().references(Sources, #id, onDelete: KeyAction.cascade)();
  TextColumn get originalRelativePath => text().nullable()();
  TextColumn get thumbnailRelativePath => text().nullable()();
  TextColumn get availability => text().withDefault(const Constant('local'))();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {sourceId};
}
