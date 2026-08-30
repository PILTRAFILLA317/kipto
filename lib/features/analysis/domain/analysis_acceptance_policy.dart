import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

final class AnalysisAcceptancePolicy {
  const AnalysisAcceptancePolicy({
    this.confidenceThreshold = analysisConfidenceThreshold,
    this.sensitiveActionThreshold = analysisSensitiveActionThreshold,
  });

  final double confidenceThreshold;
  final double sensitiveActionThreshold;

  AnalysisStatus analysisStatusFor(ScreenshotAnalysisResult result) =>
      result.confidence >= confidenceThreshold
      ? AnalysisStatus.processed
      : AnalysisStatus.needsReview;

  List<SavedItemActionType> validActions(ScreenshotAnalysisResult result) {
    final output = <SavedItemActionType>[];
    for (final action in result.suggestedActions) {
      if (action == SavedItemActionType.none || output.contains(action)) {
        continue;
      }
      final valid = switch (action) {
        SavedItemActionType.addCalendar => result.eventAt != null,
        SavedItemActionType.openMaps => result.location?.isUseful ?? false,
        SavedItemActionType.openUrl => _hasEntity(result, 'primaryUrl'),
        SavedItemActionType.trackPackage =>
          _hasEntity(result, 'trackingCode') ||
              _hasEntity(result, 'primaryUrl'),
        SavedItemActionType.copyCode =>
          _hasEntity(result, 'couponCode') ||
              _hasEntity(result, 'trackingCode') ||
              _hasEntity(result, 'orderNumber'),
        SavedItemActionType.createReminder =>
          result.requiresAction &&
              (result.eventAt != null || result.expiresAt != null),
        SavedItemActionType.webSearch || SavedItemActionType.save => true,
        SavedItemActionType.none => false,
      };
      final sensitive =
          action == SavedItemActionType.addCalendar ||
          action == SavedItemActionType.trackPackage;
      if (valid &&
          (!sensitive || result.confidence >= sensitiveActionThreshold)) {
        output.add(action);
      }
    }
    return List.unmodifiable(output);
  }

  SavedItemStatus statusFor(
    SavedItemStatus existing,
    ScreenshotAnalysisResult result,
    List<SavedItemActionType> validActions,
  ) {
    if (existing == SavedItemStatus.archived ||
        existing == SavedItemStatus.done ||
        existing == SavedItemStatus.snoozed) {
      return existing;
    }
    return result.requiresAction && validActions.isNotEmpty
        ? SavedItemStatus.needsAction
        : SavedItemStatus.newItem;
  }

  bool _hasEntity(ScreenshotAnalysisResult result, String key) {
    final value = result.entities[key];
    return value is String && value.trim().isNotEmpty;
  }
}
