import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/features/actions/application/device_action_services.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/actions/domain/calendar_event_draft.dart';
import 'package:kipto/features/actions/domain/safe_uri_policy.dart';

import 'test_helpers.dart';

void main() {
  group('SafeUriPolicy', () {
    const policy = SafeUriPolicy();

    test('allows only safe http URLs and conservative normalization', () {
      expect(policy.normalizeWebUri('https://example.com')?.scheme, 'https');
      expect(policy.normalizeWebUri('http://example.com')?.scheme, 'http');
      expect(
        policy.normalizeWebUri('www.example.com/path')?.toString(),
        'https://www.example.com/path',
      );
      for (final unsafe in [
        'javascript:alert(1)',
        'file:///tmp/a',
        'data:text/html,test',
        'intent://example.com',
        'https://user:password@example.com',
        'not a url',
      ]) {
        expect(policy.normalizeWebUri(unsafe), isNull, reason: unsafe);
      }
    });
  });

  test('Calendar draft applies the same safe URL policy', () {
    final now = DateTime.utc(2026, 8, 30);
    final unsafe = testSavedItem(
      id: 'unsafe-calendar-url',
      now: now,
      eventAt: now.add(const Duration(days: 1)),
      entities: const {'primaryUrl': 'javascript:alert(1)'},
    );
    final normalized = testSavedItem(
      id: 'normalized-calendar-url',
      now: now,
      eventAt: now.add(const Duration(days: 1)),
      entities: const {'primaryUrl': 'www.example.com/event'},
    );

    expect(
      const CalendarEventDraftBuilder().fromSavedItem(unsafe)?.url,
      isNull,
    );
    expect(
      const CalendarEventDraftBuilder()
          .fromSavedItem(normalized)
          ?.url
          .toString(),
      'https://www.example.com/event',
    );
  });

  test('Maps builds a specific encoded query and uses web fallback', () async {
    final launcher = _FakeLauncher([false, true]);
    final service = MapsActionService(launcher: launcher);
    final item = testSavedItem(
      id: 'place',
      now: DateTime.utc(2026, 8, 30),
      entities: const {
        '__kiptoAnalysis': {
          'location': {
            'name': 'Café Norte',
            'address': 'Calle Mayor 1',
            'city': 'Madrid',
            'country': 'España',
            'query': 'fallback query',
          },
        },
      },
    );

    final result = await service.open(item);

    expect(result.status, ActionExecutionStatus.success);
    expect(launcher.uris, hasLength(2));
    expect(
      launcher.uris.first.queryParameters['q'],
      'Café Norte, Calle Mayor 1, Madrid, España',
    );
    expect(
      launcher.uris.last.queryParameters['query'],
      'Café Norte, Calle Mayor 1, Madrid, España',
    );
    expect(launcher.uris.last.toString(), contains('Caf%C3%A9'));
  });

  test('Maps rejects a missing location', () async {
    final service = MapsActionService(launcher: _FakeLauncher([]));
    final item = testSavedItem(
      id: 'missing-place',
      now: DateTime.utc(2026, 8, 30),
      entities: const {},
    );
    expect(
      (await service.open(item)).status,
      ActionExecutionStatus.invalidData,
    );
  });

  test(
    'web search uses title, entities and keywords with URI encoding',
    () async {
      final launcher = _FakeLauncher([true]);
      final urls = ExternalUrlService(launcher: launcher);
      final service = WebSearchActionService(urls: urls);
      final item = testSavedItem(
        id: 'shoe',
        now: DateTime.utc(2026, 8, 30),
        title: 'Nike Air Max 95',
        entities: const {
          'productName': 'Nike Air Max 95 black',
          '__kiptoAnalysis': {
            'searchKeywords': ['black trainers'],
          },
        },
      );

      final result = await service.search(item);

      expect(result.isSuccess, isTrue);
      expect(
        launcher.uris.single.queryParameters['q'],
        'Nike Air Max 95 black trainers',
      );
    },
  );

  test(
    'clipboard resolves controlled codes and copies the selected value',
    () async {
      final writer = _FakeClipboard();
      final service = ClipboardActionService(clipboard: writer);
      final item = testSavedItem(
        id: 'coupon',
        now: DateTime.utc(2026, 8, 30),
        entities: const {
          'couponCode': 'SAVE20',
          'trackingCode': 'TRACK1',
          'random': 'do-not-copy',
        },
      );

      final candidates = service.candidates(item);
      expect(candidates.map((value) => value.value), ['SAVE20', 'TRACK1']);
      expect((await service.copy(candidates.first.value)).isSuccess, isTrue);
      expect(writer.value, 'SAVE20');
    },
  );

  test(
    'tracking prioritizes safe explicit URL then useful search fallback',
    () async {
      final directLauncher = _FakeLauncher([true]);
      final direct = TrackingActionService(
        urls: ExternalUrlService(launcher: directLauncher),
      );
      final now = DateTime.utc(2026, 8, 30);
      final explicit = testSavedItem(
        id: 'direct',
        now: now,
        entities: const {
          'primaryUrl': 'https://carrier.example/track/ABC',
          'trackingCode': 'ABC',
        },
      );
      await direct.open(explicit);
      expect(directLauncher.uris.single.host, 'carrier.example');

      final searchLauncher = _FakeLauncher([true]);
      final fallback = TrackingActionService(
        urls: ExternalUrlService(launcher: searchLauncher),
      );
      final codeOnly = testSavedItem(
        id: 'fallback',
        now: now,
        entities: const {
          'primaryUrl': 'javascript:alert(1)',
          'carrier': 'Correos',
          'trackingCode': 'ES 123/45',
        },
      );
      expect((await fallback.open(codeOnly)).isSuccess, isTrue);
      expect(
        searchLauncher.uris.single.queryParameters['q'],
        'Correos ES 123/45 tracking',
      );
    },
  );
}

final class _FakeLauncher implements ExternalLauncher {
  _FakeLauncher(this._results);

  final List<bool> _results;
  final List<Uri> uris = [];

  @override
  Future<bool> launch(Uri uri) async {
    uris.add(uri);
    return _results.isEmpty ? false : _results.removeAt(0);
  }
}

final class _FakeClipboard implements ClipboardWriter {
  String? value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}
