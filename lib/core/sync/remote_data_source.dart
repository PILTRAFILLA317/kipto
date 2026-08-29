import 'package:kipto/core/sync/remote_models.dart';

abstract interface class RemoteInvalidationSubscription {
  Stream<void> get invalidations;
  Future<void> dispose();
}

abstract interface class KiptoRemoteDataSource {
  Future<List<RemoteSavedItem>> upsertSavedItems(List<RemoteSavedItem> items);
  Future<List<RemoteSavedItem>> fetchSavedItemsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  });
  Future<List<RemoteReminder>> upsertReminders(List<RemoteReminder> reminders);
  Future<List<RemoteReminder>> fetchRemindersChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  });
  Future<void> upsertDevice(RemoteDevice device);
  Future<RemoteInvalidationSubscription> subscribeToInvalidations(
    String userId,
  );
}
