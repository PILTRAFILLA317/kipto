import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/policies/date_presets.dart';

void main() {
  test('date presets produce deterministic future local dates', () {
    final now = DateTime(2026, 8, 30, 20);

    expect(
      DatePresetPolicy.resolve(DatePreset.laterToday, now),
      DateTime(2026, 8, 30, 22),
    );
    expect(
      DatePresetPolicy.resolve(DatePreset.tomorrow, now),
      DateTime(2026, 8, 31, 9),
    );
    expect(
      DatePresetPolicy.resolve(DatePreset.nextWeek, now).weekday,
      DateTime.monday,
    );
  });
}
