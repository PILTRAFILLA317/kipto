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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _AccountSection(state: authState),
          _CloudSyncSection(
            authState: authState,
            status: syncStatus,
            now: ref.watch(currentTimeProvider),
            onSync: () =>
                ref.read(syncServiceProvider).syncNow(SyncReason.manual),
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
          const _SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications_none,
            primary: 'Not configured yet',
            secondary: 'Reminders are stored locally but are not scheduled.',
          ),
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
  const _AccountSection({required this.state});
  final KiptoAuthState? state;

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
      return const _SettingsSection(
        title: 'Account',
        icon: Icons.cloud_done_outlined,
        primary: 'Using Kipto without a permanent account',
        secondary:
            'Your library is linked to this installation. This anonymous '
            'account cannot yet be restored on another device. Account '
            'protection will be available in a future phase.',
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
    return _SettingsSection(
      title: 'Account',
      icon: Icons.person_outline,
      primary: status == KiptoAuthStatus.permanent
          ? 'Cloud sync active'
          : 'Connecting to cloud…',
      secondary: status == KiptoAuthStatus.permanent
          ? 'Your protected account is connected.'
          : 'Your local library remains available while Kipto connects.',
    );
  }
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
