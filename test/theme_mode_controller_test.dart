import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/theme/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appearance mode loads and persists locally', () async {
    SharedPreferences.setMockInitialValues({
      'appearance.themeMode': ThemeMode.dark.name,
    });
    final controller = ThemeModeController();
    addTearDown(controller.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state, ThemeMode.dark);

    await controller.setMode(ThemeMode.light);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('appearance.themeMode'), 'light');
  });
}
