import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/features/analysis/domain/analysis_contract.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);
  test('T07 date-only and ambiguous values never infer an instant', () {
    final date = DateFactValue.parse({
      'date': '2026-10-14',
      'raw': '14/10/2026',
    });
    expect(date.toJson()['date'], '2026-10-14');
    for (final raw in ['Mañana', '03/04', '14 de octubre']) {
      final uncertain = DateFactValue.parse({'date': null, 'raw': raw});
      expect(uncertain.date, isNull);
    }
    for (final invalid in [
      '2026-02-30',
      '2026-13-01',
      '03/04',
      '2026-01-01Z',
    ]) {
      expect(() => CalendarDate.parse(invalid), throwsFormatException);
    }
    expect(
      () => DateTimeFactValue(
        date: date.date,
        time: null,
        zone: null,
        raw: '14/10/2026',
      ).resolve(),
      throwsFormatException,
    );
    expect(RemindPayload().ready, isFalse);
  });
  test('T07 calendar month advance clamps explicitly, without replacing it with 30 days', () {
    final month = DurationFactValue(1, CalendarDurationUnit.calendarMonth);
    final result = month.before(CalendarDate(2026, 3, 31));
    expect(result.date.toString(), '2026-02-28');
    expect(result.clamped, isTrue);
    expect(
      month.before(CalendarDate(2026, 3, 3)).date.toString(),
      '2026-02-03',
    );
    expect(CalendarDate(2024, 2, 28).addDays(1).toString(), '2024-02-29');
  });
  test('T07 Madrid DST gap rejects and overlap requires an occurrence', () {
    final gap = resolveLocalTime(
      CalendarDate(2026, 3, 29),
      WallTime(2, 30),
      'Europe/Madrid',
    );
    expect(gap.status, LocalTimeStatus.nonexistent);
    expect(gap.confirm, throwsFormatException);
    final overlap = resolveLocalTime(
      CalendarDate(2026, 10, 25),
      WallTime(2, 30),
      'Europe/Madrid',
    );
    expect(overlap.status, LocalTimeStatus.ambiguous);
    expect(overlap.confirm, throwsFormatException);
    expect(overlap.instants, [
      DateTime.utc(2026, 10, 25, 0, 30),
      DateTime.utc(2026, 10, 25, 1, 30),
    ]);
    expect(
      overlap.confirm(chosenInstant: overlap.instants.last),
      DateTime.utc(2026, 10, 25, 1, 30),
    );
    final ordinary = resolveLocalTime(
      CalendarDate(2026, 10, 14),
      WallTime(9, 0),
      'Europe/Madrid',
    );
    expect(ordinary.confirm(), DateTime.utc(2026, 10, 14, 7));
    expect(
      () => resolveLocalTime(
        CalendarDate(2026, 10, 14),
        WallTime(9, 0),
        'Invented/Zone',
      ),
      throwsA(anything),
    );
  });
  test(
    'synthetic business fixtures validate; quote matching uses the real page',
    () async {
      for (final name in [
        'invoice',
        'return',
        'policy',
        'appointment',
        'warranty',
        'ambiguous',
      ]) {
        final fixture = jsonDecode(
          await File('test/fixtures/analysis/$name.json').readAsString(),
        ) as Map<String, dynamic>;
        final output = fixture['output'] as Map<String, dynamic>;
        final text = {
          for (final page in fixture['textPages'] as List)
            page['page'] as int: page['text'] as String,
        };
        AnalysisOutput parse({bool image = false, Map<int, String>? pages}) =>
            AnalysisOutput.parse(
              output,
              expectedRevision: 1,
              expectedPages: [1],
              expectedPartial: false,
              imageInput: image,
              textPages: pages ?? text,
            );
        expect(
          parse().facts.first.evidence.verification,
          EvidenceVerification.textMatched,
        );
        expect(
          parse(image: true).facts.first.evidence.verification,
          EvidenceVerification.visualReference,
        );
        expect(
          parse(pages: {1: 'Different actual text'})
              .facts
              .first
              .evidence
              .verification,
          EvidenceVerification.unverified,
        );
        final originalFacts = output['facts'];
        output['facts'] = [...originalFacts as List, originalFacts.first];
        expect(parse, throwsFormatException);
        output['facts'] = originalFacts;
        output['coverage'] = {
          'isPartial': true,
          'analyzedPages': [1],
        };
        expect(parse, throwsFormatException);
      }
    },
  );
  test('payload roundtrip preserves all-day dates, explicit instants and decimal money', () {
    final payloads = <ActionPayload>[
      const KeepPayload(),
      RemindPayload(
        instant: DateTime.utc(2026, 10, 14, 7),
        zone: 'Europe/Madrid',
      ),
      EventPayload(
        allDay: true,
        startDate: CalendarDate(2026, 10, 14),
        endDateExclusive: CalendarDate(2026, 10, 15),
      ),
      EventPayload(
        allDay: false,
        start: DateTime.utc(2026, 10, 14, 7),
        end: DateTime.utc(2026, 10, 14, 8),
        zone: 'Europe/Madrid',
      ),
    ];
    for (final payload in payloads) {
      expect(
        ActionPayload.parse(
          payload.kind,
          1,
          jsonDecode(jsonEncode(payload.toJson())) as Map<String, dynamic>,
        ).toJson(),
        payload.toJson(),
      );
    }
    final money = MoneyFactValue('1234.56', 'EUR');
    expect(
      FactValue.parse(money.type, money.toJson()).toJson(),
      money.toJson(),
    );
    expect(
      () => EventPayload(
        allDay: false,
        start: DateTime.utc(2026),
        end: DateTime.utc(2025),
      ),
      throwsFormatException,
    );
    expect(
      () => parseUtcInstant('2026-02-30T09:00:00Z'),
      throwsFormatException,
    );
  });
}
