import 'package:drift/drift.dart';

enum SavedItemCategory {
  event,
  place,
  product,
  order,
  recipe,
  coupon,
  conversation,
  media,
  meme,
  information,
  other,
}

enum SavedItemStatus { newItem, needsAction, snoozed, done, archived }

enum AnalysisStatus { unprocessed, processing, processed, needsReview, failed }

enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  localOnly,
  error,
}

enum SavedItemActionType {
  addCalendar,
  createReminder,
  openMaps,
  openUrl,
  webSearch,
  copyCode,
  trackPackage,
  save,
  none,
}

enum ReminderKind { followUp, event, expiration, custom }

enum SyncEntityType { savedItem, reminder }

enum SyncOperation { create, update, delete }

T _parseEnum<T extends Enum>(
  String value,
  List<T> values,
  T fallback, {
  Map<String, T> aliases = const {},
}) {
  return aliases[value] ??
      values.where((candidate) => candidate.name == value).firstOrNull ??
      fallback;
}

extension SavedItemCategoryStorage on SavedItemCategory {
  String get storageValue => name;

  static SavedItemCategory fromStorage(String value) =>
      _parseEnum(value, SavedItemCategory.values, SavedItemCategory.other);
}

extension SavedItemStatusStorage on SavedItemStatus {
  String get storageValue => this == SavedItemStatus.newItem ? 'new' : name;

  static SavedItemStatus fromStorage(String value) => _parseEnum(
    value,
    SavedItemStatus.values,
    SavedItemStatus.newItem,
    aliases: const {'new': SavedItemStatus.newItem},
  );
}

extension AnalysisStatusStorage on AnalysisStatus {
  String get storageValue => name;

  static AnalysisStatus fromStorage(String value) =>
      _parseEnum(value, AnalysisStatus.values, AnalysisStatus.needsReview);
}

extension SyncStatusStorage on SyncStatus {
  String get storageValue => name;

  static SyncStatus fromStorage(String value) =>
      _parseEnum(value, SyncStatus.values, SyncStatus.error);
}

extension SavedItemActionTypeStorage on SavedItemActionType {
  String get storageValue => name;

  static SavedItemActionType fromStorage(String value) =>
      _parseEnum(value, SavedItemActionType.values, SavedItemActionType.none);
}

extension ReminderKindStorage on ReminderKind {
  String get storageValue => name;

  static ReminderKind fromStorage(String value) =>
      _parseEnum(value, ReminderKind.values, ReminderKind.custom);
}

extension SyncEntityTypeStorage on SyncEntityType {
  String get storageValue => name;

  static SyncEntityType fromStorage(String value) =>
      _parseEnum(value, SyncEntityType.values, SyncEntityType.savedItem);
}

extension SyncOperationStorage on SyncOperation {
  String get storageValue => name;

  static SyncOperation fromStorage(String value) =>
      _parseEnum(value, SyncOperation.values, SyncOperation.update);
}

final class SavedItemCategoryConverter
    extends TypeConverter<SavedItemCategory, String> {
  const SavedItemCategoryConverter();

  @override
  SavedItemCategory fromSql(String fromDb) =>
      SavedItemCategoryStorage.fromStorage(fromDb);

  @override
  String toSql(SavedItemCategory value) => value.storageValue;
}

final class SavedItemStatusConverter
    extends TypeConverter<SavedItemStatus, String> {
  const SavedItemStatusConverter();

  @override
  SavedItemStatus fromSql(String fromDb) =>
      SavedItemStatusStorage.fromStorage(fromDb);

  @override
  String toSql(SavedItemStatus value) => value.storageValue;
}

final class AnalysisStatusConverter
    extends TypeConverter<AnalysisStatus, String> {
  const AnalysisStatusConverter();

  @override
  AnalysisStatus fromSql(String fromDb) =>
      AnalysisStatusStorage.fromStorage(fromDb);

  @override
  String toSql(AnalysisStatus value) => value.storageValue;
}

final class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();

  @override
  SyncStatus fromSql(String fromDb) => SyncStatusStorage.fromStorage(fromDb);

  @override
  String toSql(SyncStatus value) => value.storageValue;
}

final class ReminderKindConverter extends TypeConverter<ReminderKind, String> {
  const ReminderKindConverter();

  @override
  ReminderKind fromSql(String fromDb) =>
      ReminderKindStorage.fromStorage(fromDb);

  @override
  String toSql(ReminderKind value) => value.storageValue;
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
