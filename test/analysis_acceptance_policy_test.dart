import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/analysis/domain/analysis_acceptance_policy.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

void main() {
  const policy = AnalysisAcceptancePolicy();

  test('removes actions whose controlled prerequisites are absent', () {
    final actions = policy.validActions(
      _result(
        actions: const [
          SavedItemActionType.addCalendar,
          SavedItemActionType.openMaps,
          SavedItemActionType.trackPackage,
          SavedItemActionType.openUrl,
          SavedItemActionType.copyCode,
          SavedItemActionType.webSearch,
        ],
      ),
    );

    expect(actions, [SavedItemActionType.webSearch]);
  });

  test('keeps valid actions but applies a higher sensitive threshold', () {
    final actions = policy.validActions(
      _result(
        confidence: analysisSensitiveActionThreshold,
        requiresAction: true,
        actions: const [
          SavedItemActionType.addCalendar,
          SavedItemActionType.openMaps,
          SavedItemActionType.trackPackage,
          SavedItemActionType.openUrl,
          SavedItemActionType.copyCode,
          SavedItemActionType.createReminder,
        ],
        eventAt: DateTime.utc(2026, 9, 18, 20),
        expiresAt: DateTime.utc(2026, 9, 20),
        location: const AnalysisLocation(query: 'Madrid'),
        entities: const {
          'trackingCode': 'TRACK-123',
          'primaryUrl': 'https://example.test/order',
          'couponCode': 'SAVE20',
        },
      ),
    );

    expect(actions, hasLength(6));
  });

  test('maps confidence to processed versus needsReview', () {
    expect(
      policy.analysisStatusFor(_result(confidence: 0.92)),
      AnalysisStatus.processed,
    );
    expect(
      policy.analysisStatusFor(_result(confidence: 0.55)),
      AnalysisStatus.needsReview,
    );
  });

  test('derives status and preserves user-owned lifecycle states', () {
    final result = _result(
      requiresAction: true,
      actions: const [SavedItemActionType.webSearch],
    );
    final actions = policy.validActions(result);
    expect(
      policy.statusFor(SavedItemStatus.newItem, result, actions),
      SavedItemStatus.needsAction,
    );
    for (final status in const [
      SavedItemStatus.archived,
      SavedItemStatus.done,
      SavedItemStatus.snoozed,
    ]) {
      expect(policy.statusFor(status, result, actions), status);
    }
    expect(
      policy.statusFor(SavedItemStatus.needsAction, _result(), const []),
      SavedItemStatus.newItem,
    );
  });
}

ScreenshotAnalysisResult _result({
  double confidence = 0.9,
  bool requiresAction = false,
  List<SavedItemActionType> actions = const [],
  DateTime? eventAt,
  DateTime? expiresAt,
  AnalysisLocation? location,
  Map<String, Object?> entities = const {},
}) => ScreenshotAnalysisResult(
  schemaVersion: analysisSchemaVersion,
  category: SavedItemCategory.information,
  intent: ScreenshotIntent.keepForReference,
  title: 'Reference',
  summary: 'Useful reference information.',
  requiresAction: requiresAction,
  suggestedActions: actions,
  eventAt: eventAt,
  expiresAt: expiresAt,
  location: location,
  entities: entities,
  relevance: AnalysisRelevance.evergreen,
  confidence: confidence,
  uncertainFields: const [],
  searchKeywords: const ['reference'],
);
