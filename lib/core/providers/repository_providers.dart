import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/repositories/drift_sync_queue_repository.dart';
import 'package:kipto/core/repositories/reminders_repository.dart';
import 'package:kipto/core/repositories/saved_items_repository.dart';
import 'package:kipto/core/repositories/sync_queue_repository.dart';

final savedItemsRepositoryProvider = Provider<SavedItemsRepository>(
  (ref) => DriftSavedItemsRepository(ref.watch(appDatabaseProvider)),
);

final remindersRepositoryProvider = Provider<RemindersRepository>(
  (ref) => DriftRemindersRepository(ref.watch(appDatabaseProvider)),
);

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>(
  (ref) => DriftSyncQueueRepository(ref.watch(appDatabaseProvider)),
);
