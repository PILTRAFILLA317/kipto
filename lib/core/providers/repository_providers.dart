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

final itemsRepositoryProvider = Provider<ItemsRepository>(
  (ref) => DriftItemsRepository(
    ref.watch(appDatabaseProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
  ),
);

final remindersRepositoryProvider = Provider<RemindersRepository>(
  (ref) => DriftRemindersRepository(
    ref.watch(appDatabaseProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
    onChanged: () =>
        ref.read(reminderNotificationSchedulerProvider).reconcile(),
  ),
);

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>(
  (ref) => DriftSyncQueueRepository(ref.watch(appDatabaseProvider)),
);
