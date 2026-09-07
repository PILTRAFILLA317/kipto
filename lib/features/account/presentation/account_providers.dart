import 'package:flutter/services.dart';
import 'package:kipto/features/capture/presentation/shared_intake.dart';
import 'package:kipto/features/billing/presentation/billing_providers.dart';

import 'dart:io';

import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:kipto/features/analysis/presentation/analysis_providers.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/account/application/account_service.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(
    auth: ref.watch(authRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
    stopSync: () async {
      ref.read(analysisQueueProvider).invalidateAccountOrConsent();
      await ref.read(fileQueueProvider).pause();
      await ref.read(syncServiceProvider).stopForAccountChange();
    },
    clearFiles: (owner, ids) async {
      final sameAccount =
          ref.read(authRepositoryProvider).userId == null ||
          ref.read(authRepositoryProvider).userId == owner;
      if (sameAccount && Platform.isIOS) {
        try {
          await captureChannel.invokeMethod<void>('clearSession');
        } on PlatformException {
          /* Missing capability. */
        } on MissingPluginException {
          /* No native integration. */
        }
      }
      try {
        if (sameAccount) await ref.read(billingRepositoryProvider).detach();
      } on Object {
        /* Rebinding is enforced before future purchases. */
      }
      final store = await ref.read(originalStoreProvider.future);
      for (final id in ids) {
        final folder = Directory('${store.root.path}/$id');
        if (await folder.exists()) await folder.delete(recursive: true);
      }
    },
    clearNotifications: ref
        .watch(reminderNotificationSchedulerProvider)
        .clearLocalProjection,
  ),
);
