import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/reminder.dart';

abstract interface class RemindersRepository {
  Stream<List<Reminder>> watchForSavedItem(String savedItemId);
  Future<Reminder> create({
    required String savedItemId,
    required DateTime remindAt,
    ReminderKind kind,
  });
  Future<void> complete(String id);
  Future<void> delete(String id);
  Future<List<Reminder>> futurePending({DateTime? from});
}
