import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/features/analysis/data/ai_analysis_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('AI opt-in is off by default and persists per device', () async {
    final first = AiAnalysisPreferencesController();
    await first.load();
    expect(first.state.loaded, isTrue);
    expect(first.state.enabled, isFalse);

    await first.setEnabled(true);
    await first.setUserPaused(true);
    final restored = AiAnalysisPreferencesController();
    await restored.load();

    expect(restored.state.enabled, isTrue);
    expect(restored.state.userPaused, isTrue);
  });
}
