import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

Map<String, Object?> mergeCompletedActions(
  Map<String, Object?> local,
  Map<String, Object?> remote,
) {
  final merged = Map<String, Object?>.from(remote);
  final localRaw = local[SavedItem.completedActionsEntityKey];
  final remoteRaw = remote[SavedItem.completedActionsEntityKey];
  final completed = <String, Object?>{};
  const allowed = {
    SavedItemActionType.addCalendar,
    SavedItemActionType.createReminder,
    SavedItemActionType.save,
  };
  for (final raw in [remoteRaw, localRaw]) {
    if (raw is! Map) continue;
    for (final entry in raw.entries) {
      if (entry.key is! String || entry.value is! String) continue;
      final action = allowed
          .where((candidate) => candidate.storageValue == entry.key)
          .firstOrNull;
      final candidateDate = DateTime.tryParse(entry.value as String)?.toUtc();
      if (action == null || candidateDate == null) continue;
      final currentValue = completed[entry.key];
      final currentDate = currentValue is String
          ? DateTime.tryParse(currentValue)?.toUtc()
          : null;
      if (currentDate == null || candidateDate.isAfter(currentDate)) {
        completed[entry.key as String] = candidateDate.toIso8601String();
      }
    }
  }
  if (completed.isNotEmpty) {
    merged[SavedItem.completedActionsEntityKey] = completed;
  }
  return merged;
}
