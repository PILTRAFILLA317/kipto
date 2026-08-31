import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/presentation/widgets/screenshot_import_panel.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:kipto/app/theme/theme_mode_controller.dart';
import 'package:kipto/core/providers/time_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/features/analysis/data/ai_analysis_preferences.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';
import 'package:kipto/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:kipto/features/analysis/presentation/widgets/analysis_queue_controls.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/features/account/presentation/account_providers.dart';
import 'package:kipto/features/cloud_preview/data/cloud_preview_preferences.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:kipto/features/cloud_preview/presentation/cloud_preview_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoState = ref.watch(screenshotImportControllerProvider);
    final photoController = ref.read(
      screenshotImportControllerProvider.notifier,
    );
    final authState = ref.watch(authStateProvider).valueOrNull;
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;
    final showImporter =
        photoState.phase == ScreenshotImportPhase.ready ||
        photoState.phase == ScreenshotImportPhase.importing ||
        photoState.phase == ScreenshotImportPhase.completed;
    final aiPreferences = ref.watch(aiAnalysisPreferencesProvider);
    final analysisCounts =
        ref.watch(analysisItemCountsProvider).valueOrNull ??
        const AnalysisItemCounts(
          unprocessed: 0,
          analyzableUnprocessed: 0,
          processing: 0,
          processed: 0,
          needsReview: 0,
          failed: 0,
        );
    final analysisQueue =
        ref.watch(analysisQueueStatusProvider).valueOrNull ??
        const AnalysisQueueSnapshot();
    final aiServerConfigured = ref.watch(aiServerConfiguredProvider);
    final cloudPreviewSettings = ref.watch(cloudPreviewSettingsProvider);
    final cloudPreviewCounts =
        ref.watch(cloudPreviewCountsProvider).valueOrNull ??
        const CloudPreviewCounts();
    final authRepository = ref.watch(authRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _AccountSection(
            state: authState,
            user: authRepository.currentUser,
            onProtect: (provider) => _protect(context, ref, provider),
            onSignOut: () => _signOut(context, ref),
          ),
          _CloudSyncSection(
            authState: authState,
            status: syncStatus,
            now: ref.watch(currentTimeProvider),
            onSync: () =>
                ref.read(syncServiceProvider).syncNow(SyncReason.manual),
          ),
          _CloudPreviewSection(
            settings: cloudPreviewSettings,
            counts: cloudPreviewCounts,
            configured:
                authState?.isAuthenticated == true &&
                ref.watch(supabaseClientProvider) != null,
            onModeChanged: (mode) =>
                _setCloudImageMode(context, ref, mode, cloudPreviewCounts),
            onBackupNow: () => _backupNow(ref),
            onPause: ref.read(cloudPreviewSettingsProvider.notifier).pause,
            onResume: ref.read(cloudPreviewSettingsProvider.notifier).resume,
            onClearCache: () => _clearPreviewCache(context, ref),
            onRemoveCloud: () => _removeCloudPreviews(context, ref),
          ),
          _ScreenshotHistorySection(
            state: photoState,
            onImportMore: photoController.showImportOptions,
            onScan: () =>
                photoController.scanForNewScreenshots(forceReconcile: true),
            onManage: photoController.manageLimitedAccess,
            onOpenSettings: photoController.openSettings,
          ),
          if (showImporter) const ScreenshotImportPanel(),
          _AppearanceSection(
            mode: ref.watch(themeModeProvider),
            onChanged: ref.read(themeModeProvider.notifier).setMode,
          ),
          _AiPrivacySection(
            preferences: aiPreferences,
            counts: analysisCounts,
            queue: analysisQueue,
            serverConfigured: aiServerConfigured,
            onEnabledChanged: (enabled) => _setAiEnabled(
              context,
              ref,
              enabled,
              currentlyEnabled: aiPreferences.enabled,
            ),
            onAnalyze: () =>
                ref.read(analysisQueueRunnerProvider).enqueueUnprocessed(),
            onPause: ref.read(analysisQueueRunnerProvider).pause,
            onResume: ref.read(analysisQueueRunnerProvider).resume,
          ),
          const _NotificationsSection(),
          const _SettingsSection(
            title: 'About',
            icon: Icons.info_outline,
            primary: 'Kipto',
            secondary: 'Version 1.0.0 · An inbox for things you saved.',
          ),
        ],
      ),
    );
  }

  Future<void> _setAiEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled, {
    required bool currentlyEnabled,
  }) async {
    if (enabled == currentlyEnabled) return;
    if (enabled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable AI analysis?'),
          content: const Text(
            'To understand a screenshot, Kipto sends an optimized temporary '
            'copy for AI analysis. The original remains in your photo library.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable AI analysis'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(aiAnalysisPreferencesProvider.notifier).setEnabled(enabled);
    await ref.read(analysisQueueRunnerProvider).setEnabled(enabled);
  }

  Future<void> _protect(
    BuildContext context,
    WidgetRef ref,
    KiptoIdentityProvider provider,
  ) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      if (provider == KiptoIdentityProvider.apple) {
        await repository.protectWithApple();
      } else {
        await repository.protectWithGoogle();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finish protecting your library in the browser.'),
          ),
        );
      }
    } on KiptoAuthFlowException catch (error) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Could not connect this account'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out of Kipto?'),
        content: const Text(
          'Synced Kipto data will be removed from this device. Your cloud '
          'library and screenshots in Photos will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(accountServiceProvider).signOut();
  }

  Future<void> _setCloudImageMode(
    BuildContext context,
    WidgetRef ref,
    CloudImageSyncMode mode,
    CloudPreviewCounts counts,
  ) async {
    final controller = ref.read(cloudPreviewSettingsProvider.notifier);
    if (mode == CloudImageSyncMode.metadataOnly) {
      await controller.setMode(mode);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Back up optimized previews?'),
        content: Text(
          '${counts.eligible} screenshots can be backed up. Kipto uploads '
          'smaller private previews; original screenshots remain in Photos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Back up previews'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.setMode(mode);
    await ref.read(cloudPreviewBackupServiceProvider).enqueueAllMissing();
  }

  Future<void> _backupNow(WidgetRef ref) async {
    final backup = ref.read(cloudPreviewBackupServiceProvider);
    await backup.retryFailed();
    await backup.enqueueAllMissing();
    await ref.read(syncServiceProvider).syncNow(SyncReason.manual);
  }

  Future<void> _clearPreviewCache(BuildContext context, WidgetRef ref) async {
    await ref.read(cloudPreviewBackupServiceProvider).clearDownloadedPreviews();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded previews cleared.')),
      );
    }
  }

  Future<void> _removeCloudPreviews(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove cloud screenshot previews?'),
        content: const Text(
          'Kipto will keep syncing titles, categories, reminders and other '
          'metadata. Original screenshots in Photos are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove previews'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(cloudPreviewBackupServiceProvider)
          .removeAllCloudPreviews();
      ref.invalidate(cloudPreviewSettingsProvider);
    }
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(notificationPermissionStatusProvider);
    final count = ref.watch(scheduledReminderCountProvider);
    final status = permission.valueOrNull;
    final scheduler = ref.read(reminderNotificationSchedulerProvider);
    final enabled = status == NotificationPermissionStatus.granted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    enabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                  ),
                  title: Text(
                    status == null
                        ? 'Checking permission…'
                        : enabled
                        ? 'Enabled'
                        : status == NotificationPermissionStatus.notDetermined
                        ? 'Not enabled yet'
                        : 'Disabled',
                  ),
                  subtitle: Text(
                    'Scheduled reminders ${count.valueOrNull ?? 0}',
                  ),
                  trailing: status == NotificationPermissionStatus.notDetermined
                      ? TextButton(
                          onPressed: () async {
                            await scheduler.requestPermission();
                            ref.invalidate(
                              notificationPermissionStatusProvider,
                            );
                            ref.invalidate(scheduledReminderCountProvider);
                          },
                          child: const Text('Enable'),
                        )
                      : null,
                ),
                if (status != null &&
                    status != NotificationPermissionStatus.unavailable)
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Open notification settings'),
                    onTap: scheduler.openSettings,
                  ),
                if (kDebugMode) ...[
                  ListTile(
                    leading: const Icon(Icons.notification_add_outlined),
                    title: const Text('Send test notification'),
                    onTap: scheduler.showTest,
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync_outlined),
                    title: const Text('Reconcile notifications'),
                    onTap: () async {
                      await scheduler.reconcile();
                      ref.invalidate(scheduledReminderCountProvider);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPrivacySection extends StatelessWidget {
  const _AiPrivacySection({
    required this.preferences,
    required this.counts,
    required this.queue,
    required this.serverConfigured,
    required this.onEnabledChanged,
    required this.onAnalyze,
    required this.onPause,
    required this.onResume,
  });

  final AiAnalysisPreferencesState preferences;
  final AnalysisItemCounts counts;
  final AnalysisQueueSnapshot queue;
  final bool serverConfigured;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onAnalyze;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final notConfigured =
        !serverConfigured || queue.lastErrorCode?.name == 'notConfigured';
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'AI & Privacy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.shield_outlined),
                  title: const Text('AI analysis'),
                  subtitle: Text(
                    preferences.enabled
                        ? 'New screenshots are analyzed automatically while Kipto is open.'
                        : 'Screenshot content is not sent for analysis.',
                  ),
                  value: preferences.enabled,
                  onChanged: preferences.loaded ? onEnabledChanged : null,
                ),
                if (notConfigured && preferences.enabled)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('AI analysis is not configured'),
                    subtitle: Text(
                      'Configure the Edge Function and OpenAI secret to analyze screenshots.',
                    ),
                  ),
                if (preferences.enabled)
                  AnalysisQueueControls(
                    counts: counts,
                    queue: queue,
                    onAnalyze: onAnalyze,
                    onPause: onPause,
                    onResume: onResume,
                  ),
                if (preferences.enabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Unprocessed ${counts.unprocessed} · Failed ${counts.failed} · Needs review ${counts.needsReview}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                if (kDebugMode && preferences.enabled)
                  ListTile(
                    title: const Text('Analysis diagnostics'),
                    subtitle: Text(
                      'Queued ${queue.queued} · Processing ${queue.processing} · '
                      'Schema $analysisSchemaVersion · Model $defaultAnalysisModel'
                      '${queue.lastLatency == null ? '' : ' · ${queue.lastLatency!.inMilliseconds} ms'}'
                      '${queue.lastErrorCode == null ? '' : ' · ${queue.lastErrorCode!.name}'}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.state,
    required this.user,
    required this.onProtect,
    required this.onSignOut,
  });
  final KiptoAuthState? state;
  final KiptoUser? user;
  final ValueChanged<KiptoIdentityProvider> onProtect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final status = state?.status ?? KiptoAuthStatus.initializing;
    if (status == KiptoAuthStatus.unconfigured) {
      return const _SettingsSection(
        title: 'Account',
        icon: Icons.person_outline,
        primary: 'Cloud sync not configured',
        secondary: 'Kipto remains fully usable on this device.',
      );
    }
    if (status == KiptoAuthStatus.anonymous) {
      return _SettingsCard(
        title: 'Account',
        children: [
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Kipto is not protected'),
            subtitle: Text(
              'Protect your library so you can restore it if you change or '
              'lose this device.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => onProtect(KiptoIdentityProvider.apple),
                  icon: const Icon(Icons.apple),
                  label: const Text('Continue with Apple'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => onProtect(KiptoIdentityProvider.google),
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('Continue with Google'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (status == KiptoAuthStatus.error ||
        status == KiptoAuthStatus.signedOut) {
      return const _SettingsSection(
        title: 'Account',
        icon: Icons.cloud_off_outlined,
        primary: 'Cloud account unavailable',
        secondary: 'Your local library is safe. Try syncing again later.',
      );
    }
    if (status != KiptoAuthStatus.permanent) {
      return const _SettingsSection(
        title: 'Account',
        icon: Icons.person_outline,
        primary: 'Connecting to cloud…',
        secondary: 'Your local library remains available while Kipto connects.',
      );
    }
    final providers = user?.identityProviders ?? const [];
    return _SettingsCard(
      title: 'Account',
      children: [
        ListTile(
          leading: const Icon(Icons.verified_user_outlined),
          title: const Text('Kipto account protected'),
          subtitle: Text(
            providers.isEmpty
                ? 'A recoverable identity is connected.'
                : providers
                      .map(
                        (provider) => '${_providerName(provider)} · Connected',
                      )
                      .join('\n'),
          ),
        ),
        if (!providers.contains(KiptoIdentityProvider.apple))
          ListTile(
            leading: const Icon(Icons.apple),
            title: const Text('Connect Apple'),
            onTap: () => onProtect(KiptoIdentityProvider.apple),
          ),
        if (!providers.contains(KiptoIdentityProvider.google))
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Connect Google'),
            onTap: () => onProtect(KiptoIdentityProvider.google),
          ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          subtitle: const Text(
            'Cloud data and screenshots in Photos stay intact.',
          ),
          onTap: onSignOut,
        ),
      ],
    );
  }

  static String _providerName(KiptoIdentityProvider provider) =>
      provider == KiptoIdentityProvider.apple ? 'Apple' : 'Google';
}

class _CloudPreviewSection extends StatelessWidget {
  const _CloudPreviewSection({
    required this.settings,
    required this.counts,
    required this.configured,
    required this.onModeChanged,
    required this.onBackupNow,
    required this.onPause,
    required this.onResume,
    required this.onClearCache,
    required this.onRemoveCloud,
  });

  final CloudPreviewPreferenceState settings;
  final CloudPreviewCounts counts;
  final bool configured;
  final ValueChanged<CloudImageSyncMode> onModeChanged;
  final VoidCallback onBackupNow;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onClearCache;
  final VoidCallback onRemoveCloud;

  @override
  Widget build(BuildContext context) => _SettingsCard(
    title: 'Cloud Backup',
    children: [
      ListTile(
        leading: const Icon(Icons.cloud_done_outlined),
        title: Text(configured ? 'Library synced' : 'Cloud unavailable'),
        subtitle: const Text(
          'Original screenshots remain in your photo library. Kipto can store '
          'smaller optimized previews in your private cloud library.',
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SegmentedButton<CloudImageSyncMode>(
          segments: const [
            ButtonSegment(
              value: CloudImageSyncMode.optimizedPreviews,
              label: Text('Optimized previews'),
            ),
            ButtonSegment(
              value: CloudImageSyncMode.metadataOnly,
              label: Text('Metadata only'),
            ),
          ],
          selected: {settings.mode},
          onSelectionChanged: configured && settings.loaded
              ? (value) => onModeChanged(value.single)
              : null,
        ),
      ),
      const SizedBox(height: 8),
      ListTile(
        title: Text('${counts.uploaded} backed up · ${counts.waiting} waiting'),
        subtitle: Text(
          settings.mode == CloudImageSyncMode.metadataOnly
              ? "Titles, categories and reminders sync, but new screenshot previews don't."
              : '${counts.eligible} eligible · ${counts.failed} failed',
        ),
        trailing: settings.mode == CloudImageSyncMode.optimizedPreviews
            ? TextButton(
                onPressed: configured ? onBackupNow : null,
                child: const Text('Back up now'),
              )
            : null,
      ),
      if (settings.mode == CloudImageSyncMode.optimizedPreviews)
        ListTile(
          leading: Icon(
            settings.userPaused
                ? Icons.play_arrow_outlined
                : Icons.pause_outlined,
          ),
          title: Text(
            settings.userPaused
                ? 'Resume preview backup'
                : 'Pause preview backup',
          ),
          onTap: settings.userPaused ? onResume : onPause,
        ),
      ListTile(
        leading: const Icon(Icons.cleaning_services_outlined),
        title: const Text('Clear downloaded previews'),
        subtitle: const Text('Only this device cache is cleared.'),
        onTap: onClearCache,
      ),
      if (counts.uploaded > 0)
        ListTile(
          leading: const Icon(Icons.cloud_off_outlined),
          title: const Text('Remove cloud screenshot previews'),
          subtitle: const Text('Keeps all metadata and Photos originals.'),
          onTap: onRemoveCloud,
        ),
    ],
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(child: Column(children: children)),
      ],
    ),
  );
}

class _CloudSyncSection extends StatelessWidget {
  const _CloudSyncSection({
    required this.authState,
    required this.status,
    required this.now,
    required this.onSync,
  });
  final KiptoAuthState? authState;
  final SyncStatusSnapshot? status;
  final DateTime now;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    if (authState?.status == KiptoAuthStatus.unconfigured) {
      return const _SettingsSection(
        title: 'Cloud Sync',
        icon: Icons.cloud_outlined,
        primary: 'Not configured',
        secondary: 'Add Supabase dart-defines to enable cloud metadata sync.',
      );
    }
    final value = status ?? const SyncStatusSnapshot(phase: SyncPhase.idle);
    final syncing = value.phase == SyncPhase.syncing;
    final failed = value.phase == SyncPhase.offlineOrFailed;
    final primary = syncing
        ? 'Syncing…'
        : failed
        ? 'Sync error'
        : 'Synced';
    final secondary = failed
        ? 'Your changes are safe on this device. '
              '${value.pendingCount} changes waiting.'
        : value.lastSuccessAt == null
        ? '${value.pendingCount} changes waiting to sync.'
        : 'Last synced ${_relative(value.lastSuccessAt!, now)}. '
              '${value.pendingCount} changes waiting.';
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Cloud Sync',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(failed ? Icons.cloud_off : Icons.cloud_outlined),
              title: Text(primary),
              subtitle: Text(secondary),
              trailing: TextButton(
                onPressed: syncing ? null : onSync,
                child: Text(failed ? 'Try again' : 'Sync now'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _relative(DateTime value, DateTime now) {
    final elapsed = now.toUtc().difference(value.toUtc());
    if (elapsed.inMinutes < 1) return 'just now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} minutes ago';
    if (elapsed.inDays < 1) return '${elapsed.inHours} hours ago';
    return '${elapsed.inDays} days ago';
  }
}

class _ScreenshotHistorySection extends StatelessWidget {
  const _ScreenshotHistorySection({
    required this.state,
    required this.onImportMore,
    required this.onScan,
    required this.onManage,
    required this.onOpenSettings,
  });

  final ScreenshotImportUiState state;
  final VoidCallback onImportMore;
  final VoidCallback onScan;
  final VoidCallback onManage;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final hasAccess = state.permission.hasAccess;
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Screenshots',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo_library_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasAccess
                              ? '${state.importedCount} imported · '
                                    '${state.availableCount} available'
                              : 'Photo access is ${state.permission.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  if (state.permission == PhotoAccessStatus.limited) ...[
                    const SizedBox(height: 8),
                    const Text('Kipto only has access to selected photos.'),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasAccess) ...[
                        FilledButton.tonal(
                          onPressed: onImportMore,
                          child: const Text('Import more'),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              state.phase == ScreenshotImportPhase.scanning
                              ? null
                              : onScan,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            state.phase == ScreenshotImportPhase.scanning
                                ? 'Scanning…'
                                : 'Scan for new screenshots',
                          ),
                        ),
                      ],
                      if (state.permission == PhotoAccessStatus.limited)
                        TextButton(
                          onPressed: onManage,
                          child: const Text('Manage access'),
                        ),
                      if (state.permission == PhotoAccessStatus.denied ||
                          state.permission == PhotoAccessStatus.restricted)
                        FilledButton(
                          onPressed: onOpenSettings,
                          child: const Text('Open Settings'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.brightness_6_outlined),
                    SizedBox(width: 12),
                    Text('Color mode'),
                  ],
                ),
                const SizedBox(height: 14),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                    ),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (value) => onChanged(value.single),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.primary,
    required this.secondary,
  });

  final String title;
  final IconData icon;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(primary),
            subtitle: Text(secondary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
          ),
        ),
      ],
    ),
  );
}
