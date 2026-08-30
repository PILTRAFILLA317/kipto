import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'appearance.themeMode';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (_) => ThemeModeController(),
);

final class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _load();
  }

  bool _changedByUser = false;

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_themeModeKey);
      if (!mounted || stored == null || _changedByUser) return;
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == stored,
        orElse: () => ThemeMode.system,
      );
    } on Object {
      // Appearance persistence must never prevent the offline app from opening.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _changedByUser = true;
    state = mode;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_themeModeKey, mode.name);
    } on Object {
      // The selected mode still applies for the current session.
    }
  }
}
