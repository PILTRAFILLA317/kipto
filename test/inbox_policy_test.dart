import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/inbox_overview.dart';

import 'test_helpers.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  test('inbox assigns every item once to its highest-priority section', () {
    final overlapping = testSavedItem(
      id: 'overlap',
      now: now,
      status: SavedItemStatus.needsAction,
      expiresAt: now.add(const Duration(days: 2)),
      analysisStatus: AnalysisStatus.unprocessed,
    );
    final raw = testSavedItem(
      id: 'raw',
      now: now,
      analysisStatus: AnalysisStatus.unprocessed,
    );

    final overview = InboxPolicy.organize([overlapping, raw], now);
    final ids = overview.sections
        .expand((section) => section.items)
        .map((item) => item.id)
        .toList();

    expect(ids, ['overlap', 'raw']);
    expect(overview.sections.first.kind, InboxSectionKind.needsAction);
    expect(overview.sections.last.kind, InboxSectionKind.readyToAnalyze);
  });

  test('expired is needs action and never expiring soon', () {
    final expired = testSavedItem(
      id: 'expired',
      now: now,
      expiresAt: now.subtract(const Duration(days: 1)),
    );
    final overview = InboxPolicy.organize([expired], now);
    expect(overview.sections.single.kind, InboxSectionKind.needsAction);
  });
}
