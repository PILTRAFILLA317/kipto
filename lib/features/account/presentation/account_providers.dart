import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/account/application/account_service.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(
    auth: ref.watch(authRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
    stopSync: ref.watch(syncServiceProvider).stopForAccountChange,
    clearNotifications: ref
        .watch(reminderNotificationSchedulerProvider)
        .clearLocalProjection,
  ),
);
