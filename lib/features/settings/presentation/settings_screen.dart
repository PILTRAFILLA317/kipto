import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/theme_mode_controller.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/account/presentation/account_providers.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final permission = ref
        .watch(notificationPermissionStatusProvider)
        .valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Kipto – Life Admin'),
            subtitle: Text('Foundation after legacy cleanup'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Appearance'),
            trailing: DropdownButton<ThemeMode>(
              value: ref.watch(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setMode(value);
                }
              },
              items: ThemeMode.values
                  .map(
                    (mode) =>
                        DropdownMenuItem(value: mode, child: Text(mode.name)),
                  )
                  .toList(growable: false),
            ),
          ),
          ListTile(
            title: const Text('Notifications'),
            subtitle: Text(_notificationLabel(permission)),
            onTap: permission == NotificationPermissionStatus.granted
                ? null
                : () => ref
                      .read(reminderNotificationSchedulerProvider)
                      .requestPermission(),
          ),
          const Divider(),
          if (auth.currentUser?.isAnonymous == true) ...[
            const ListTile(
              title: Text('Protect your library'),
              subtitle: Text(
                'Connect Apple or Google without changing this library.',
              ),
            ),
            OverflowBar(
              children: [
                TextButton(
                  onPressed: () => auth.protectWithApple(),
                  child: const Text('Apple'),
                ),
                TextButton(
                  onPressed: () => auth.protectWithGoogle(),
                  child: const Text('Google'),
                ),
              ],
            ),
          ] else if (auth.currentUser != null)
            ListTile(
              title: const Text('Sign out'),
              subtitle: const Text(
                'Removes this library from this device only.',
              ),
              onTap: () => ref.read(accountServiceProvider).signOut(),
            ),
          ListTile(
            title: const Text('Sync now'),
            onTap: () => ref.read(syncServiceProvider).syncNow(),
          ),
        ],
      ),
    );
  }

  String _notificationLabel(NotificationPermissionStatus? value) =>
      switch (value) {
        NotificationPermissionStatus.granted => 'Local reminders are enabled',
        NotificationPermissionStatus.denied => 'Notifications are disabled',
        NotificationPermissionStatus.notDetermined =>
          'Enable when you create a reminder',
        NotificationPermissionStatus.unavailable ||
        null => 'Not available on this device',
      };
}
