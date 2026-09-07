import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_sync_queue_repository.dart';
import 'package:kipto/core/repositories/items_repository.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:kipto/core/repositories/sync_queue_repository.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return DriftItemsRepository(
    ref.watch(appDatabaseProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
    onChanged: () =>
        ref.read(reminderNotificationSchedulerProvider).reconcile(),
  );
});

final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return DriftRemindersRepository(
    ref.watch(appDatabaseProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
    onChanged: () =>
        ref.read(reminderNotificationSchedulerProvider).reconcile(),
  );
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>(
  (ref) => DriftSyncQueueRepository(ref.watch(appDatabaseProvider)),
);

final lifeAdminRepositoryProvider = Provider(
  (ref) => DriftLifeAdminRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(localSyncCoordinatorProvider),
  ),
);
final itemFactsProvider = StreamProvider.family<List<Fact>, String>((ref, id) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref.watch(lifeAdminRepositoryProvider).watchFacts(id);
});
final itemActionsProvider = StreamProvider.family<List<ItemAction>, String>((
  ref,
  id,
) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref.watch(lifeAdminRepositoryProvider).watchActions(id);
});
