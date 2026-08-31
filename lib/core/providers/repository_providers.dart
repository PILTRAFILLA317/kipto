import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/repositories/drift_sync_queue_repository.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:kipto/core/repositories/saved_items_repository.dart';
import 'package:kipto/core/repositories/sync_queue_repository.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/features/cloud_preview/presentation/cloud_preview_providers.dart';

final savedItemsRepositoryProvider = Provider<SavedItemsRepository>(
  (ref) => DriftSavedItemsRepository(
    ref.watch(appDatabaseProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
    onSavedItemDeleted: () =>
        ref.read(reminderNotificationSchedulerProvider).reconcile(),
    onSavedItemCreated: (id) =>
        ref.read(cloudPreviewBackupServiceProvider).enqueueSavedItem(id),
    onPreviewDeleteRequested: (id) =>
        ref.read(cloudPreviewBackupServiceProvider).enqueueDelete(id),
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
