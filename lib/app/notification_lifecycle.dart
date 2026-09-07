import 'package:kipto/features/account/presentation/account_providers.dart';
import 'package:kipto/app/theme/motion_preferences.dart';
import 'package:kipto/features/notifications/presentation/notification_preferences.dart';
import 'package:kipto/features/privacy/presentation/account_deletion_screen.dart';
import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:kipto/features/capture/application/shared_manifest.dart';
import 'package:flutter/services.dart';
import 'package:kipto/features/analysis/presentation/analysis_providers.dart';
import 'package:kipto/features/capture/presentation/shared_intake.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:kipto/features/privacy/application/export_service.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/settings/application/privacy_preferences.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final class NotificationLifecycle extends ConsumerStatefulWidget {
  const NotificationLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationLifecycle> createState() =>
      _NotificationLifecycleState();
}

final class _NotificationLifecycleState
    extends ConsumerState<NotificationLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    captureChannel.setMethodCallHandler((call) async {
      if (call.method == 'intakeChanged' && mounted) {
        ref.invalidate(pendingSharedCapturesProvider);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    try {
      await ExportService.purgeExpired(
        Directory('${(await getTemporaryDirectory()).path}/kipto-exports'),
      );
    } on Object {
      /* Temporary cleanup retries on the next launch. */
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(accountDeletionKey)) {
      appRouter.go('/account-deletion');
      return;
    }
    await ref.read(accountServiceProvider).recoverSignOutCleanup();
    await _recoverCapture();
    if (!mounted) return;
    await ref.read(syncServiceProvider).initialize();
    if (mounted) {
      unawaited(ref.read(analysisQueueProvider).wake());
      await ref.read(fileQueueProvider).resume();
    }
    try {
      final payload = await ref
          .read(reminderNotificationSchedulerProvider)
          .initialize((value) => unawaited(_openPayload(value)));
      if (payload != null) await _openPayload(payload);
      _refreshSettings();
    } on Object {
      // Device integrations must never prevent the local-first app from opening.
    }
  }

  Future<void> _openPayload(String value) async {
    final route = await ref
        .read(notificationRouteResolverProvider)
        .routeForPayload(value);
    appRouter.go(route);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      ref.read(analysisQueueProvider).pause();
      unawaited(ref.read(fileQueueProvider).pause());
      return;
    }
    unawaited(ref.read(analysisQueueProvider).resume());
    unawaited(_resume());
  }

  Future<void> _resume() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(accountDeletionKey)) {
      appRouter.go('/account-deletion');
      return;
    }
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null && state != AppLifecycleState.resumed) return;
    await _recoverCapture();
    if (!mounted) return;
    await ref.read(syncServiceProvider).initialize();
    await ref.read(syncServiceProvider).syncNow();
    if (mounted) {
      await ref.read(fileQueueProvider).resume();
      await ref.read(fileQueueProvider).enqueueLocalUploads();
    }
    if (mounted) unawaited(ref.read(analysisQueueProvider).wake());
    try {
      await ref.read(reminderNotificationSchedulerProvider).reconcile();
      _refreshSettings();
    } on Object {
      // Scheduling failure is recoverable on the next resume or explicit action.
    }
  }

  Future<void>? _recovery;
  Future<void> _recoverCapture() =>
      _recovery ??= _performRecovery().whenComplete(() => _recovery = null);

  Future<void> _performRecovery() async {
    try {
      final service = await ref.read(captureServiceProvider.future);
      var failures = await service.recover();
      if (Platform.isIOS) {
        final path = await captureChannel.invokeMethod<String>(
          'incomingDirectory',
        );
        if (path != null) {
          failures += await importConfirmedSharedPackages(
            Directory(path),
            service,
            await ref.read(captureScopeProvider)(),
            afterImport: ref.read(importSharedAnalysisProvider),
          );
        }
      }
      if (mounted) {
        ref.read(captureRecoveryFailuresProvider.notifier).state = failures;
      }
      if (!mounted) return;
      try {
        await captureChannel.invokeMethod<void>(
          'setScope',
          await ref.read(captureScopeProvider)(),
        );
      } on MissingPluginException {
        /* Platform integration not configured. */
      }
      await _shareSession();
      ref.invalidate(pendingSharedCapturesProvider);
      if (!mounted || !Platform.isAndroid) return;
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('capture.pendingPicker');
      final scope = prefs.getString('capture.pendingPickerScope');
      if (id == null || scope != await ref.read(captureScopeProvider)()) return;
      final lost = await ImagePicker().retrieveLostData();
      if (lost.files?.isNotEmpty == true) {
        final file = lost.files!.first;
        await service.importFile(
          captureId: id,
          file: File(file.path),
          name: file.name,
        );
        await prefs.remove('capture.pendingPicker');
      }
    } on Object {
      if (mounted) ref.read(captureRecoveryFailuresProvider.notifier).state = 1;
      // Interrupted captures remain in persistent storage for explicit recovery.
    }
  }

  Future<void> _shareSession() async {
    if (!Platform.isIOS || !mounted) return;
    await _shareAppearance();
    if (!mounted) return;
    final session = ref.read(supabaseClientProvider)?.auth.currentSession;
    try {
      if (session == null) {
        await captureChannel.invokeMethod<void>('clearSession');
        return;
      }
      final config = ref.read(appConfigProvider);
      await captureChannel.invokeMethod<void>('setAnalysisSession', {
        'userId': session.user.id,
        'accessToken': session.accessToken,
        'expiresAt': session.expiresAt?.toDouble() ?? 0,
        'apiURL': config.supabaseUrl,
        'publicKey': config.supabasePublishableKey,
        'consent': ref.read(privacyPreferencesProvider).analysis,
      });
    } on PlatformException {
      /* Shared Keychain capability is not configured. */
    } on MissingPluginException {
      /* Platform setup unavailable. */
    }
  }

  Future<void> _shareAppearance() async {
    if (!Platform.isIOS || !mounted) return;
    try {
      await captureChannel.invokeMethod<void>(
        'setReducedMotion',
        ref.read(motionPreferencesProvider).reduced,
      );
    } on PlatformException {
      /* The extension defaults to reduced motion until setup is available. */
    } on MissingPluginException {
      /* Platform setup unavailable. */
    }
  }

  void _refreshSettings() {
    ref.invalidate(notificationPermissionStatusProvider);
    ref.invalidate(scheduledReminderCountProvider);
  }

  @override
  void dispose() {
    captureChannel.setMethodCallHandler(null);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      motionPreferencesProvider.select((value) => value.reduced),
      (_, _) => unawaited(_shareAppearance()),
    );
    ref.listen(authStateProvider, (before, after) {
      if (before?.valueOrNull?.userId != after.valueOrNull?.userId) {
        ref.read(analysisQueueProvider).invalidateAccountOrConsent();
        ref.read(fileQueueProvider).invalidate();
      }
      unawaited(_resume());
    });
    ref.listen(notificationPreferencesProvider, (before, after) {
      unawaited(ref.read(reminderNotificationSchedulerProvider).reconcile());
    });
    ref.listen(privacyPreferencesProvider, (before, after) {
      unawaited(_shareSession());
      if (before?.analysis == true && !after.analysis) {
        ref.read(analysisQueueProvider).invalidateAccountOrConsent();
      }
      if (after.analysis && before?.analysis != true) {
        unawaited(ref.read(analysisQueueProvider).wake());
      }
      if (before?.backup == true && !after.backup) {
        ref.read(fileQueueProvider).invalidate();
      }
      if (after.backup && before?.backup != true) unawaited(_resume());
      if (after.sync && before?.sync != true) unawaited(_resume());
    });
    return widget.child;
  }
}
