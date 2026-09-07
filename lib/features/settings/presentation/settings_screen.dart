import 'package:kipto/features/notifications/presentation/notification_preferences.dart';
import 'package:kipto/features/privacy/presentation/account_deletion_screen.dart';
import 'package:kipto/features/privacy/presentation/export_sheet.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/theme/theme_mode_controller.dart';
import 'package:kipto/app/theme/motion_preferences.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/features/account/presentation/account_providers.dart';
import 'package:kipto/features/settings/application/privacy_preferences.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> _run(BuildContext context, Future<void> Function() work) async {
    try {
      await work();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).operationFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authRepositoryProvider);
    ref.watch(authStateProvider);
    final privacy = ref.watch(privacyPreferencesProvider);
    final motion = ref.watch(motionPreferencesProvider);
    final permission = ref
        .watch(notificationPermissionStatusProvider)
        .valueOrNull;
    final configured = ref.watch(appConfigProvider).isCloudConfigured;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Semantics(
              header: true,
              child: Text(
                l.account,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            if (!configured)
              Text(l.cloudUnavailable)
            else if (auth.currentUser == null) ...[
              FilledButton(
                onPressed: () => _run(context, () async {
                  final session = await auth.ensureSession();
                  if (session != null) {
                    await ref
                        .read(localSyncCoordinatorProvider)
                        .claimLocalOnlyData(session.user.id);
                  }
                }),
                child: Text(l.getStarted),
              ),
              TextButton(
                onPressed: () => _run(context, auth.signInExistingWithApple),
                child: Text(l.restoreApple),
              ),
              TextButton(
                onPressed: () => _run(context, auth.signInExistingWithGoogle),
                child: Text(l.restoreGoogle),
              ),
            ] else if (auth.isAnonymous) ...[
              Text(l.protectLibraryBody),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => _run(context, auth.protectWithApple),
                    child: const Text('Apple'),
                  ),
                  OutlinedButton(
                    onPressed: () => _run(context, auth.protectWithGoogle),
                    child: const Text('Google'),
                  ),
                ],
              ),
            ] else
              ListTile(
                title: Text(l.signOut),
                subtitle: Text(l.signOutBody),
                onTap: () => _run(context, () async {
                  final service = ref.read(accountServiceProvider);
                  final loss = await service.pendingLoss();
                  if (!context.mounted) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialog) => AlertDialog(
                      title: Text(l.signOut),
                      content: Text(
                        l.signOutWarning(loss.changes, loss.originals),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: Text(l.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: Text(l.signOut),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await service.signOut(discardLocalData: true);
                  }
                }),
              ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Kipto Pro'),
              subtitle: Text(l.proBody),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/pro'),
            ),
            const SizedBox(height: 32),
            Semantics(
              header: true,
              child: Text(
                l.cloud,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.syncConsent),
              subtitle: Text(l.syncConsentBody),
              value: privacy.sync,
              onChanged: !configured
                  ? null
                  : (value) => _run(context, () async {
                      await ref
                          .read(privacyPreferencesProvider.notifier)
                          .update(sync: value);
                      if (value) {
                        await ref.read(syncServiceProvider).initialize();
                        await ref.read(syncServiceProvider).syncNow();
                      }
                    }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.analysisConsent),
              subtitle: Text(l.analysisConsentShort),
              value: privacy.analysis,
              onChanged: !configured || auth.userId == null
                  ? null
                  : (value) => _run(context, () async {
                      if (value) {
                        final accepted = await showDialog<bool>(
                          context: context,
                          builder: (dialog) => AlertDialog(
                            title: Text(l.analysisConsentTitle),
                            content: SingleChildScrollView(
                              child: Text(l.analysisConsentBody),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialog, false),
                                child: Text(
                                  MaterialLocalizations.of(dialog)
                                      .cancelButtonLabel,
                                ),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(dialog, true),
                                child: Text(l.analysisConsent),
                              ),
                            ],
                          ),
                        );
                        if (accepted != true || !context.mounted) return;
                      }
                      await ref
                          .read(privacyPreferencesProvider.notifier)
                          .update(analysis: value);
                    }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.backupConsent),
              subtitle: Text(l.backupConsentBody),
              value: privacy.backup,
              onChanged: !configured || auth.userId == null || !privacy.sync
                  ? null
                  : (value) => _run(context, () async {
                      await ref
                          .read(privacyPreferencesProvider.notifier)
                          .update(backup: value);
                    }),
            ),
            ...ref
                .watch(fileJobsProvider)
                .when(
                  loading: () => <Widget>[],
                  error: (_, _) => [Text(l.operationFailed)],
                  data: (jobs) => [
                    if (jobs.any(
                      (j) => j.state == 'failed' || j.state == 'retry',
                    ))
                      TextButton(
                        onPressed: () => _run(
                          context,
                          ref.read(fileQueueProvider).retryFailed,
                        ),
                        child: Text(l.retry),
                      ),
                    if (jobs.any((j) => j.state != 'done'))
                      Text(
                        l.backupPending(
                          jobs.where((j) => j.state != 'done').length,
                        ),
                      ),
                  ],
                ),
            TextButton(
              onPressed: configured && privacy.sync
                  ? () => _run(context, ref.read(syncServiceProvider).syncNow)
                  : null,
              child: Text(l.syncNow),
            ),
            const SizedBox(height: 32),
            Semantics(
              header: true,
              child: Text(
                l.notifications,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(switch (permission) {
                NotificationPermissionStatus.granted => l.notificationEnabled,
                NotificationPermissionStatus.denied => l.notificationDisabled,
                NotificationPermissionStatus.notDetermined => l.notificationAsk,
                _ => l.notificationUnavailable,
              }),
              trailing: const Icon(Icons.notifications_outlined),
              onTap: () => _run(context, () async {
                final scheduler = ref.read(
                  reminderNotificationSchedulerProvider,
                );
                if (permission == NotificationPermissionStatus.denied) {
                  await scheduler.openSettings();
                } else {
                  await scheduler.requestPermission();
                }
                ref.invalidate(notificationPermissionStatusProvider);
              }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.notificationsThisDevice),
              subtitle: Text(l.notificationsDevicesBody),
              value: ref.watch(notificationPreferencesProvider).enabled,
              onChanged: (value) => _run(
                context,
                () => ref
                    .read(notificationPreferencesProvider.notifier)
                    .update(enabled: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.notificationTitles),
              subtitle: Text(l.notificationTitlesBody),
              value: ref.watch(notificationPreferencesProvider).includeTitle,
              onChanged: (value) => _run(
                context,
                () => ref
                    .read(notificationPreferencesProvider.notifier)
                    .update(includeTitle: value),
              ),
            ),
            const SizedBox(height: 32),
            Semantics(
              header: true,
              child: Text(
                l.appearance,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final choice in [
                    (ThemeMode.system, l.system),
                    (ThemeMode.light, l.light),
                    (ThemeMode.dark, l.dark),
                  ])
                    ChoiceChip(
                      label: Text(choice.$2),
                      selected: ref.watch(themeModeProvider) == choice.$1,
                      onSelected: (_) => ref
                          .read(themeModeProvider.notifier)
                          .setMode(choice.$1),
                    ),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.reduceMotion),
              value: motion.reduced,
              onChanged: (v) => _run(
                context,
                () => ref
                    .read(motionPreferencesProvider.notifier)
                    .update(reduced: v),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.haptics),
              value: motion.haptics,
              onChanged: (v) => _run(
                context,
                () => ref
                    .read(motionPreferencesProvider.notifier)
                    .update(haptics: v),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => ExportSheet(
                  itemIds:
                      ref
                          .read(allItemsProvider)
                          .valueOrNull
                          ?.map((i) => i.id)
                          .toList() ??
                      [],
                ),
              ),
              child: Text(l.exportData),
            ),
            if (auth.userId != null)
              TextButton(
                onPressed: () => _run(context, () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialog) => AlertDialog(
                      title: Text(l.deleteAccount),
                      content: SingleChildScrollView(
                        child: Text(l.deleteAccountBody),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: Text(l.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: Text(l.deleteAccount),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  await beginAccountDeletion(ref);
                  if (context.mounted) context.push('/account-deletion');
                }),
                child: Text(l.deleteAccount),
              ),
            if (kDebugMode)
              TextButton(
                onPressed: () => context.push('/design-preview'),
                child: Text(l.preview),
              ),
          ],
        ),
      ),
    );
  }
}
