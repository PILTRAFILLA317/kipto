import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/presentation/widgets/screenshot_import_panel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoState = ref.watch(screenshotImportControllerProvider);
    final photoController = ref.read(
      screenshotImportControllerProvider.notifier,
    );
    final showImporter =
        photoState.phase == ScreenshotImportPhase.ready ||
        photoState.phase == ScreenshotImportPhase.importing ||
        photoState.phase == ScreenshotImportPhase.completed;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ScreenshotHistorySection(
            state: photoState,
            onImportMore: photoController.showImportOptions,
            onScan: () =>
                photoController.scanForNewScreenshots(forceReconcile: true),
            onManage: photoController.manageLimitedAccess,
            onOpenSettings: photoController.openSettings,
          ),
          if (showImporter) const ScreenshotImportPanel(),
          const _SettingsSection(
            title: 'Account',
            icon: Icons.person_outline,
            primary: 'Local mode',
            secondary: 'Cloud account support will arrive later.',
          ),
          const _SettingsSection(
            title: 'Cloud Sync',
            icon: Icons.cloud_outlined,
            primary: 'Not configured yet',
            secondary: 'Your data currently stays on this device.',
          ),
          const _SettingsSection(
            title: 'AI & Privacy',
            icon: Icons.shield_outlined,
            primary: 'AI analysis not enabled yet',
            secondary: 'No screenshot content is sent to an AI service.',
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
            secondary: 'Keep what matters. Capture what comes next.',
          ),
        ],
      ),
    );
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
              'Screenshot history',
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
