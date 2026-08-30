import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/features/analysis/data/supabase_screenshot_analysis_client.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('maps network, auth, oversized, rate, and server HTTP failures', () {
    final cases = <int, AnalysisErrorCode>{
      0: AnalysisErrorCode.network,
      401: AnalysisErrorCode.unauthorized,
      403: AnalysisErrorCode.unauthorized,
      413: AnalysisErrorCode.payloadTooLarge,
      429: AnalysisErrorCode.rateLimited,
      503: AnalysisErrorCode.serverError,
    };

    for (final entry in cases.entries) {
      final failure = analysisFailureFromFunctionException(
        FunctionException(status: entry.key),
      );
      expect(failure.code, entry.value, reason: 'HTTP ${entry.key}');
    }
  });

  test('prefers sanitized server taxonomy and bounds Retry-After', () {
    final failure = analysisFailureFromFunctionException(
      const FunctionException(
        status: 429,
        details:
            '{"error":{"code":"quota_exceeded","retryable":true,'
            '"retryAfterSeconds":999999}}',
      ),
    );

    expect(failure.code, AnalysisErrorCode.quotaExceeded);
    expect(failure.retryable, isTrue);
    expect(failure.retryAfter, const Duration(days: 1));
  });

  test(
    'all controlled wire codes round-trip without leaking provider details',
    () {
      for (final code in AnalysisErrorCode.values) {
        expect(AnalysisErrorCodeStorage.fromWire(code.wireValue), code);
      }
      expect(
        AnalysisErrorCodeStorage.fromWire('provider_internal_stack'),
        AnalysisErrorCode.unknown,
      );
    },
  );
}
