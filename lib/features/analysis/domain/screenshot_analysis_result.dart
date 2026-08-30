import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';

enum ScreenshotIntent {
  attendEvent,
  visitPlace,
  considerPurchase,
  trackOrder,
  cookRecipe,
  useCoupon,
  rememberTask,
  saveMedia,
  keepForReference,
  entertainment,
  unknown,
}

final class AnalysisLocation {
  const AnalysisLocation({
    this.name,
    this.address,
    this.city,
    this.country,
    this.query,
  });

  final String? name;
  final String? address;
  final String? city;
  final String? country;
  final String? query;

  bool get isUseful => [
    name,
    address,
    city,
    country,
    query,
  ].any((value) => value != null && value.trim().isNotEmpty);

  String? get displayValue {
    final preferred = [query, name, address, city]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);
    return preferred.firstOrNull;
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'address': address,
    'city': city,
    'country': country,
    'query': query,
  };
}

final class ScreenshotAnalysisResult {
  const ScreenshotAnalysisResult({
    required this.schemaVersion,
    required this.category,
    required this.intent,
    required this.title,
    required this.summary,
    required this.requiresAction,
    required this.suggestedActions,
    required this.entities,
    required this.relevance,
    required this.confidence,
    required this.uncertainFields,
    required this.searchKeywords,
    this.subtype,
    this.sourceApp,
    this.eventAt,
    this.expiresAt,
    this.location,
  });

  final int schemaVersion;
  final SavedItemCategory category;
  final String? subtype;
  final ScreenshotIntent intent;
  final String title;
  final String summary;
  final String? sourceApp;
  final bool requiresAction;
  final List<SavedItemActionType> suggestedActions;
  final DateTime? eventAt;
  final DateTime? expiresAt;
  final AnalysisLocation? location;
  final Map<String, Object?> entities;
  final AnalysisRelevance relevance;
  final double confidence;
  final List<String> uncertainFields;
  final List<String> searchKeywords;

  bool get isCurrentSchema => schemaVersion == analysisSchemaVersion;
}

final class ScreenshotAnalysisEnvelope {
  const ScreenshotAnalysisEnvelope({
    required this.result,
    required this.model,
    required this.promptVersion,
  });

  final ScreenshotAnalysisResult result;
  final String model;
  final String promptVersion;
}

extension ScreenshotIntentStorage on ScreenshotIntent {
  String get storageValue => switch (this) {
    ScreenshotIntent.attendEvent => 'attend_event',
    ScreenshotIntent.visitPlace => 'visit_place',
    ScreenshotIntent.considerPurchase => 'consider_purchase',
    ScreenshotIntent.trackOrder => 'track_order',
    ScreenshotIntent.cookRecipe => 'cook_recipe',
    ScreenshotIntent.useCoupon => 'use_coupon',
    ScreenshotIntent.rememberTask => 'remember_task',
    ScreenshotIntent.saveMedia => 'save_media',
    ScreenshotIntent.keepForReference => 'keep_for_reference',
    ScreenshotIntent.entertainment => 'entertainment',
    ScreenshotIntent.unknown => 'unknown',
  };

  static ScreenshotIntent? tryParse(String value) {
    for (final intent in ScreenshotIntent.values) {
      if (intent.storageValue == value) return intent;
    }
    return null;
  }
}
