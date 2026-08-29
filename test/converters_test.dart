import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/converters/json_converters.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

void main() {
  test('unknown persisted enum values use conservative fallbacks', () {
    expect(
      const SavedItemCategoryConverter().fromSql('future_category'),
      SavedItemCategory.other,
    );
    expect(
      const SavedItemStatusConverter().fromSql('future_status'),
      SavedItemStatus.newItem,
    );
    expect(
      const AnalysisStatusConverter().fromSql('future_status'),
      AnalysisStatus.needsReview,
    );
    expect(
      const SyncStatusConverter().fromSql('future_status'),
      SyncStatus.error,
    );
  });

  test('JSON converters tolerate malformed and future values', () {
    expect(const JsonMapConverter().fromSql('not json'), isEmpty);
    expect(
      const SavedItemActionsConverter().fromSql('["openMaps", "futureAction"]'),
      [SavedItemActionType.openMaps],
    );
  });
}
