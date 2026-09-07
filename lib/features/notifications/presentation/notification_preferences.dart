import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationPreferencesProvider =
    StateNotifierProvider<
      NotificationPreferences,
      ({bool enabled, bool includeTitle})
    >((ref) => NotificationPreferences());

class NotificationPreferences
    extends StateNotifier<({bool enabled, bool includeTitle})> {
  NotificationPreferences() : super((enabled: false, includeTitle: false)) {
    ready = _load();
  }
  late final Future<void> ready;
  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) {
        state = (
          enabled: p.getBool('notifications.deviceEnabled') ?? true,
          includeTitle: p.getBool('notifications.includeTitle') ?? false,
        );
      }
    } on Object {
      /* Do not schedule until preferences are known. */
    }
  }

  Future<void> update({bool? enabled, bool? includeTitle}) async {
    await ready;
    if (!mounted) return;
    state = (
      enabled: enabled ?? state.enabled,
      includeTitle: includeTitle ?? state.includeTitle,
    );
    final p = await SharedPreferences.getInstance();
    await p.setBool('notifications.deviceEnabled', state.enabled);
    await p.setBool('notifications.includeTitle', state.includeTitle);
  }
}
