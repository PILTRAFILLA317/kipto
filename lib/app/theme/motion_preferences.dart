import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final motionPreferencesProvider =
    StateNotifierProvider<
      MotionPreferencesController,
      ({bool reduced, bool haptics})
    >((ref) => MotionPreferencesController());

class MotionPreferencesController
    extends StateNotifier<({bool reduced, bool haptics})> {
  MotionPreferencesController() : super((reduced: false, haptics: true)) {
    _load();
  }
  bool _edited = false;
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted && !_edited) {
        state = (
          reduced: prefs.getBool('appearance.reducedMotion') ?? false,
          haptics: prefs.getBool('appearance.haptics') ?? true,
        );
      }
    } on Object {
      /* Platform preferences must not prevent local access. */
    }
  }

  Future<void> update({bool? reduced, bool? haptics}) async {
    _edited = true;
    state = (
      reduced: reduced ?? state.reduced,
      haptics: haptics ?? state.haptics,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('appearance.reducedMotion', state.reduced);
    await prefs.setBool('appearance.haptics', state.haptics);
  }
}
