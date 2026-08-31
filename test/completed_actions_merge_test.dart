import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/domain/policies/completed_actions_merge.dart';

import 'test_helpers.dart';

void main() {
  test('different device completions merge by key and newest timestamp', () {
    final merged = mergeCompletedActions(
      const {
        SavedItem.completedActionsEntityKey: {
          'save': '2026-08-30T10:00:00.000Z',
          'addCalendar': '2026-08-30T12:00:00.000Z',
        },
      },
      const {
        SavedItem.completedActionsEntityKey: {
          'save': '2026-08-30T11:00:00.000Z',
          'createReminder': '2026-08-30T13:00:00.000Z',
          'openMaps': '2026-08-30T14:00:00.000Z',
          'futureAction': 'not-a-date',
        },
      },
    );
    final completed = Map<String, Object?>.from(
      merged[SavedItem.completedActionsEntityKey]! as Map,
    );

    expect(
      completed.keys,
      containsAll(['save', 'addCalendar', 'createReminder']),
    );
    expect(completed['save'], '2026-08-30T11:00:00.000Z');
    expect(completed, isNot(contains('openMaps')));
    expect(completed, isNot(contains('futureAction')));
  });

  test('SavedItem exposes valid completions and hides reserved metadata', () {
    final item = testSavedItem(
      id: 'item',
      now: DateTime.utc(2026, 8, 30),
      entities: const {
        'merchant': 'Kipto',
        SavedItem.completedActionsEntityKey: {
          'save': '2026-08-30T11:00:00.000Z',
          'openMaps': 'not-a-date',
          'futureAction': '2026-08-30T11:00:00.000Z',
        },
      },
    );

    expect(item.hasCompletedAction(SavedItemActionType.save), isTrue);
    expect(item.completedActions, hasLength(1));
    expect(item.detectedEntities, {'merchant': 'Kipto'});
  });
}
