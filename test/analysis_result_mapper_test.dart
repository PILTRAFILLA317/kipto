import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/analysis/application/analysis_result_mapper.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';

void main() {
  const mapper = AnalysisResultMapper();

  test('maps synthetic fixtures covering all controlled categories', () {
    final fixtures = (jsonDecode(
      File('test/fixtures/analysis/category_cases.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>();

    final mapped = fixtures.map(
      (fixture) => mapper.fromResponse(_response(fixture)),
    );

    expect(
      mapped.map((value) => value.result.category).toSet(),
      SavedItemCategory.values.toSet(),
    );
    expect(mapped.last.result.confidence, 0.42);
  });

  test('rejects invalid shape, enums, dates, and unknown entity keys', () {
    final valid = _response(_baseAnalysis());

    expect(
      () => mapper.fromResponse({
        ...valid,
        'analysis': {...valid['analysis']! as Map, 'category': 'social'},
      }),
      throwsA(_invalidResponse),
    );
    expect(
      () => mapper.fromResponse({
        ...valid,
        'analysis': {...valid['analysis']! as Map, 'eventAt': 'tomorrow'},
      }),
      throwsA(_invalidResponse),
    );
    expect(
      () => mapper.fromResponse({
        ...valid,
        'analysis': {
          ...valid['analysis']! as Map,
          'eventAt': '2026-09-18T20:00:00',
        },
      }),
      throwsA(_invalidResponse),
    );
    final analysis = Map<String, Object?>.from(valid['analysis']! as Map);
    final entities = Map<String, Object?>.from(analysis['entities']! as Map)
      ..['invented'] = 'no';
    expect(
      () => mapper.fromResponse({
        ...valid,
        'analysis': {...analysis, 'entities': entities},
      }),
      throwsA(_invalidResponse),
    );
  });
}

final _invalidResponse = isA<AnalysisFailure>().having(
  (failure) => failure.code,
  'code',
  AnalysisErrorCode.invalidResponse,
);

Map<String, Object?> _response(Map<String, Object?> partial) {
  final analysis = _baseAnalysis()..addAll(partial);
  return {
    'ok': true,
    'analysis': analysis,
    'meta': {
      'schemaVersion': analysisSchemaVersion,
      'promptVersion': analysisPromptVersion,
      'model': defaultAnalysisModel,
    },
  };
}

Map<String, Object?> _baseAnalysis() => {
  'schemaVersion': analysisSchemaVersion,
  'category': 'event',
  'subtype': 'concert',
  'intent': 'attend_event',
  'title': 'Coldplay',
  'summary': 'Concierto de Coldplay en Madrid.',
  'sourceApp': 'Instagram',
  'requiresAction': true,
  'suggestedActions': <Object?>['addCalendar'],
  'eventAt': '2026-09-18T20:00:00+02:00',
  'expiresAt': null,
  'location': {
    'name': 'Metropolitano',
    'address': null,
    'city': 'Madrid',
    'country': 'España',
    'query': 'Metropolitano Madrid',
  },
  'entities': {for (final key in analysisEntityKeys) key: null},
  'relevance': 'active',
  'confidence': 0.94,
  'uncertainFields': <Object?>[],
  'searchKeywords': <Object?>['coldplay', 'madrid'],
};
