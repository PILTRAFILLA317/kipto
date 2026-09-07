import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/sync/remote_models.dart';
import 'package:kipto/core/domain/models/source.dart';

abstract interface class RemoteInvalidationSubscription {
  Stream<void> get invalidations;
  Future<void> dispose();
}

abstract interface class KiptoRemoteDataSource {
  Future<List<RemoteItem>> upsertItems(List<RemoteItem> items);
  Future<List<RemoteItem>> fetchItemsChangedSince({
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
  Future<List<Source>> upsertSources(List<Source> sources);
  Future<List<Source>> fetchSourcesChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  });
  Future<List<Fact>> upsertFacts(List<Fact> rows);
  Future<List<Fact>> fetchFactsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  });
  Future<List<ItemAction>> upsertActions(List<ItemAction> rows);
  Future<List<ItemAction>> fetchActionsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  });

  Future<void> upsertDevice(RemoteDevice device);
  Future<RemoteInvalidationSubscription> subscribeToInvalidations(
    String userId,
  );
}
