import 'package:kipto/core/domain/models/reminder.dart';

abstract interface class RemindersRepository {
  Stream<List<Reminder>> watchForItem(String itemId);
  Future<Reminder?> findById(String id, {bool includeDeleted = false});
  Future<Reminder> create({required String itemId, required DateTime remindAt});
  Future<void> edit(String id, DateTime remindAt);
  Future<void> complete(String id);
  Future<void> delete(String id);
}
