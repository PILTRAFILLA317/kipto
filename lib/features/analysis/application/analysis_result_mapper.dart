import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

final class AnalysisResultMapper {
  const AnalysisResultMapper();

  ScreenshotAnalysisEnvelope fromResponse(Map<String, Object?> response) {
    _exactKeys(response, const {'ok', 'analysis', 'meta'});
    if (response['ok'] != true) throw _invalid();
    final rawAnalysis = _map(response['analysis']);
    final meta = _map(response['meta']);
    _exactKeys(meta, const {'schemaVersion', 'promptVersion', 'model'});
    _exactKeys(rawAnalysis, const {
      'schemaVersion',
      'category',
      'subtype',
      'intent',
      'title',
      'summary',
      'sourceApp',
      'requiresAction',
      'suggestedActions',
      'eventAt',
      'expiresAt',
      'location',
      'entities',
      'relevance',
      'confidence',
      'uncertainFields',
      'searchKeywords',
    });
    final schemaVersion = _integer(rawAnalysis['schemaVersion']);
    if (schemaVersion != analysisSchemaVersion ||
        _integer(meta['schemaVersion']) != analysisSchemaVersion) {
      throw _invalid();
    }
    final model = _boundedString(meta['model'], max: 100);
    final promptVersion = _boundedString(meta['promptVersion'], max: 32);
    final category = _enumByStorage(
      rawAnalysis['category'],
      SavedItemCategory.values,
      (value) => value.storageValue,
    );
    final intent = _enumByStorage(
      rawAnalysis['intent'],
      ScreenshotIntent.values,
      (value) => value.storageValue,
    );
    final relevance = _enumByStorage(
      rawAnalysis['relevance'],
      AnalysisRelevance.values,
      (value) => value.storageValue,
    );
    final title = _boundedString(rawAnalysis['title'], max: 80);
    final summary = _boundedString(rawAnalysis['summary'], max: 200);
    final subtype = _nullableBoundedString(
      rawAnalysis['subtype'],
      max: 48,
      pattern: RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$'),
    );
    final sourceApp = _nullableBoundedString(rawAnalysis['sourceApp'], max: 60);
    final requiresAction = rawAnalysis['requiresAction'];
    if (requiresAction is! bool) throw _invalid();
    final confidenceValue = rawAnalysis['confidence'];
    if (confidenceValue is! num ||
        !confidenceValue.isFinite ||
        confidenceValue < 0 ||
        confidenceValue > 1) {
      throw _invalid();
    }
    final actions = _list(rawAnalysis['suggestedActions'])
        .map(
          (value) => _enumByStorage(
            value,
            SavedItemActionType.values,
            (action) => action.storageValue,
          ),
        )
        .toList(growable: false);
    if (actions.length > 9) throw _invalid();
    final uncertainFields = _stringList(
      rawAnalysis['uncertainFields'],
      maxItems: 12,
      maxLength: 40,
    );
    if (uncertainFields.any(
      (field) => !analysisUncertainFieldNames.contains(field),
    )) {
      throw _invalid();
    }
    final searchKeywords = _stringList(
      rawAnalysis['searchKeywords'],
      maxItems: 12,
      maxLength: 60,
    );
    final rawEntities = _map(rawAnalysis['entities']);
    _exactKeys(rawEntities, analysisEntityKeys);
    final entities = <String, Object?>{};
    for (final entry in rawEntities.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is! String || value.length > 500) throw _invalid();
      final normalized = value.trim();
      if (normalized.isNotEmpty) entities[entry.key] = normalized;
    }
    return ScreenshotAnalysisEnvelope(
      model: model,
      promptVersion: promptVersion,
      result: ScreenshotAnalysisResult(
        schemaVersion: schemaVersion,
        category: category,
        subtype: subtype,
        intent: intent,
        title: title,
        summary: summary,
        sourceApp: sourceApp,
        requiresAction: requiresAction,
        suggestedActions: List.unmodifiable(actions),
        eventAt: _nullableDate(rawAnalysis['eventAt']),
        expiresAt: _nullableDate(rawAnalysis['expiresAt']),
        location: _location(rawAnalysis['location']),
        entities: Map.unmodifiable(entities),
        relevance: relevance,
        confidence: confidenceValue.toDouble(),
        uncertainFields: uncertainFields,
        searchKeywords: searchKeywords,
      ),
    );
  }

  AnalysisLocation? _location(Object? value) {
    if (value == null) return null;
    final map = _map(value);
    _exactKeys(map, const {'name', 'address', 'city', 'country', 'query'});
    final location = AnalysisLocation(
      name: _nullableBoundedString(map['name'], max: 120),
      address: _nullableBoundedString(map['address'], max: 200),
      city: _nullableBoundedString(map['city'], max: 100),
      country: _nullableBoundedString(map['country'], max: 100),
      query: _nullableBoundedString(map['query'], max: 240),
    );
    return location.isUseful ? location : null;
  }

  DateTime? _nullableDate(Object? value) {
    if (value == null) return null;
    if (value is! String || value.length > 40) throw _invalid();
    if (!RegExp(r'(?:Z|[+-]\d{2}:\d{2})$').hasMatch(value)) {
      throw _invalid();
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw _invalid();
    return parsed.toUtc();
  }

  List<String> _stringList(
    Object? value, {
    required int maxItems,
    required int maxLength,
  }) {
    final raw = _list(value);
    if (raw.length > maxItems) throw _invalid();
    final values = raw
        .map((value) => _boundedString(value, max: maxLength))
        .toSet()
        .toList(growable: false);
    return List.unmodifiable(values);
  }

  T _enumByStorage<T extends Enum>(
    Object? value,
    List<T> values,
    String Function(T value) storage,
  ) {
    if (value is! String) throw _invalid();
    for (final candidate in values) {
      if (storage(candidate) == value) return candidate;
    }
    throw _invalid();
  }

  String _boundedString(Object? value, {required int max, RegExp? pattern}) {
    if (value is! String) throw _invalid();
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > max) throw _invalid();
    if (pattern != null && !pattern.hasMatch(normalized)) {
      throw _invalid();
    }
    return normalized;
  }

  String? _nullableBoundedString(
    Object? value, {
    required int max,
    RegExp? pattern,
  }) {
    if (value == null) return null;
    return _boundedString(value, max: max, pattern: pattern);
  }

  int _integer(Object? value) {
    if (value is int) return value;
    throw _invalid();
  }

  Map<String, Object?> _map(Object? value) {
    if (value is! Map) throw _invalid();
    try {
      return Map<String, Object?>.from(value);
    } on Object {
      throw _invalid();
    }
  }

  List<Object?> _list(Object? value) {
    if (value is! List) throw _invalid();
    return List<Object?>.from(value);
  }

  void _exactKeys(Map<String, Object?> value, Set<String> expected) {
    if (value.length != expected.length ||
        !value.keys.toSet().containsAll(expected)) {
      throw _invalid();
    }
  }

  AnalysisFailure _invalid() => const AnalysisFailure(
    code: AnalysisErrorCode.invalidResponse,
    retryable: true,
  );
}
