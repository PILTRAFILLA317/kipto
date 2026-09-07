import 'package:drift/drift.dart';

enum ItemStatus { active, resolved, archived }

enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  localOnly,
  error,
}

enum SyncEntityType { item, reminder, source, fact, action }

enum SyncOperation { create, update, delete }

T _parseEnum<T extends Enum>(String value, List<T> values, T fallback) =>
    values.where((candidate) => candidate.name == value).firstOrNull ??
    fallback;

extension ItemStatusStorage on ItemStatus {
  String get storageValue => name;
  static ItemStatus fromStorage(String value) =>
      _parseEnum(value, ItemStatus.values, ItemStatus.active);
}

extension SyncStatusStorage on SyncStatus {
  String get storageValue => name;
  static SyncStatus fromStorage(String value) =>
      _parseEnum(value, SyncStatus.values, SyncStatus.error);
}

extension SyncEntityTypeStorage on SyncEntityType {
  String get storageValue => name;
  static SyncEntityType fromStorage(String value) =>
      _parseEnum(value, SyncEntityType.values, SyncEntityType.item);
}

extension SyncOperationStorage on SyncOperation {
  String get storageValue => name;
  static SyncOperation fromStorage(String value) =>
      _parseEnum(value, SyncOperation.values, SyncOperation.update);
}

final class ItemStatusConverter extends TypeConverter<ItemStatus, String> {
  const ItemStatusConverter();
  @override
  ItemStatus fromSql(String fromDb) => ItemStatusStorage.fromStorage(fromDb);
  @override
  String toSql(ItemStatus value) => value.storageValue;
}

final class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();
  @override
  SyncStatus fromSql(String fromDb) => SyncStatusStorage.fromStorage(fromDb);
  @override
  String toSql(SyncStatus value) => value.storageValue;
}

final class SyncEntityTypeConverter
    extends TypeConverter<SyncEntityType, String> {
  const SyncEntityTypeConverter();
  @override
  SyncEntityType fromSql(String fromDb) =>
      SyncEntityTypeStorage.fromStorage(fromDb);
  @override
  String toSql(SyncEntityType value) => value.storageValue;
}

final class SyncOperationConverter
    extends TypeConverter<SyncOperation, String> {
  const SyncOperationConverter();
  @override
  SyncOperation fromSql(String fromDb) =>
      SyncOperationStorage.fromStorage(fromDb);
  @override
  String toSql(SyncOperation value) => value.storageValue;
}
