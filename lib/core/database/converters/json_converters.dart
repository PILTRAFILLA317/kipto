import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

final class JsonMapConverter
    extends TypeConverter<Map<String, Object?>, String> {
  const JsonMapConverter();

  @override
  Map<String, Object?> fromSql(String fromDb) {
    try {
      final decoded = jsonDecode(fromDb);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  @override
  String toSql(Map<String, Object?> value) => jsonEncode(value);
}

final class SavedItemActionsConverter
    extends TypeConverter<List<SavedItemActionType>, String> {
  const SavedItemActionsConverter();

  @override
  List<SavedItemActionType> fromSql(String fromDb) {
    try {
      final decoded = jsonDecode(fromDb);
      if (decoded is! List) return const [];
      return decoded
          .whereType<String>()
          .map(SavedItemActionTypeStorage.fromStorage)
          .where((action) => action != SavedItemActionType.none)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  @override
  String toSql(List<SavedItemActionType> value) =>
      jsonEncode(value.map((action) => action.storageValue).toList());
}
