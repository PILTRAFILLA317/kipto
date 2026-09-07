import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

import '../application/deletion_service.dart';

final deletionServiceProvider = Provider(
  (ref) => DeletionService(
    database: ref.watch(appDatabaseProvider),
    coordinator: ref.watch(localSyncCoordinatorProvider),
    originals: () => ref.read(originalStoreProvider.future),
    reconcile: () =>
        ref.read(reminderNotificationSchedulerProvider).reconcile(),
    wakeFiles: () => ref.read(fileQueueProvider).wake(),
  ),
);
