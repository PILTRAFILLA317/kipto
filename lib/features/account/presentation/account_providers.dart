import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/account/application/account_service.dart';
import 'package:kipto/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:kipto/features/cloud_preview/presentation/cloud_preview_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(
    auth: ref.watch(authRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
    stopSync: ref.watch(syncServiceProvider).stopForAccountChange,
    stopAnalysis: ref.watch(analysisQueueRunnerProvider).onBackground,
    stopPreviews: ref.watch(cloudPreviewBackupServiceProvider).onBackground,
    clearPreviewCache: ref
        .watch(cloudPreviewBackupServiceProvider)
        .clearDownloadedPreviews,
    clearNotifications: ref
        .watch(reminderNotificationSchedulerProvider)
        .clearLocalProjection,
  ),
);
