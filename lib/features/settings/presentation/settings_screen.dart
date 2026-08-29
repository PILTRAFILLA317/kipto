import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        _SettingsSection(
          title: 'Account',
          icon: Icons.person_outline,
          primary: 'Local mode',
          secondary: 'Cloud account support will arrive later.',
        ),
        _SettingsSection(
          title: 'Cloud Sync',
          icon: Icons.cloud_outlined,
          primary: 'Not configured yet',
          secondary: 'Your data currently stays on this device.',
        ),
        _SettingsSection(
          title: 'AI & Privacy',
          icon: Icons.shield_outlined,
          primary: 'AI analysis not enabled yet',
          secondary: 'No screenshot content is sent to an AI service.',
        ),
        _SettingsSection(
          title: 'Notifications',
          icon: Icons.notifications_none,
          primary: 'Not configured yet',
          secondary: 'Reminders are stored locally but are not scheduled.',
        ),
        _SettingsSection(
          title: 'About',
          icon: Icons.info_outline,
          primary: 'Kipto',
          secondary: 'Keep what matters. Capture what comes next.',
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
