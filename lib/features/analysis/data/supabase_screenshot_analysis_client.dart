// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:kipto/features/analysis/application/analysis_result_mapper.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_client.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseScreenshotAnalysisClient
    implements ScreenshotAnalysisClient {
  SupabaseScreenshotAnalysisClient(
    this._client, {
    AnalysisResultMapper mapper = const AnalysisResultMapper(),
    this.timeout = analysisRequestTimeout,
  }) : _mapper = mapper;

  final SupabaseClient _client;
  final AnalysisResultMapper _mapper;
  final Duration timeout;

  @override
  Future<ScreenshotAnalysisEnvelope> analyze(
    ScreenshotAnalysisRequest request,
  ) async {
    final abort = Completer<void>();
    var timedOut = false;
    final timer = Timer(timeout, () {
      timedOut = true;
      abort.complete();
    });
    try {
      final response = await _client.functions.invoke(
        'analyze-screenshot',
        body: {
          'requestVersion': 1,
          'imageBase64': base64Encode(request.imageBytes),
          'mimeType': request.mimeType,
          'capturedAt': request.capturedAt.toLocal().toIso8601String(),
          'locale': request.locale,
        },
        abortSignal: abort.future,
      );
      if (response.data is! Map) throw _invalidResponse();
      return _mapper.fromResponse(
        Map<String, Object?>.from(response.data as Map),
      );
    } on AnalysisFailure {
      rethrow;
    } on FunctionException catch (error) {
      if (timedOut) throw _timeout();
      throw analysisFailureFromFunctionException(error);
    } on Object {
      if (timedOut) throw _timeout();
      throw const AnalysisFailure(
        code: AnalysisErrorCode.network,
        retryable: true,
      );
    } finally {
      timer.cancel();
    }
  }

  AnalysisFailure _timeout() => const AnalysisFailure(
    code: AnalysisErrorCode.upstreamTimeout,
    retryable: true,
  );

  AnalysisFailure _invalidResponse() => const AnalysisFailure(
    code: AnalysisErrorCode.invalidResponse,
    retryable: true,
  );
}

AnalysisFailure analysisFailureFromFunctionException(
  FunctionException exception,
) {
  final details = exception.details;
  Map<String, Object?>? body;
  if (details is Map) {
    body = Map<String, Object?>.from(details);
  } else if (details is String) {
    try {
      final decoded = jsonDecode(details);
      if (decoded is Map) body = Map<String, Object?>.from(decoded);
    } on Object {
      // Fall back to the sanitized HTTP status taxonomy below.
    }
  }
  final rawError = body?['error'];
  if (rawError is Map) {
    final error = Map<String, Object?>.from(rawError);
    final retryAfter = error['retryAfterSeconds'];
    return AnalysisFailure(
      code: AnalysisErrorCodeStorage.fromWire(error['code']),
      retryable: error['retryable'] == true,
      retryAfter: retryAfter is num
          ? Duration(seconds: retryAfter.toInt().clamp(1, 86400))
          : null,
    );
  }
  return switch (exception.status) {
    0 => const AnalysisFailure(
      code: AnalysisErrorCode.network,
      retryable: true,
    ),
    401 || 403 => const AnalysisFailure(
      code: AnalysisErrorCode.unauthorized,
      retryable: false,
    ),
    413 => const AnalysisFailure(
      code: AnalysisErrorCode.payloadTooLarge,
      retryable: false,
    ),
    429 => const AnalysisFailure(
      code: AnalysisErrorCode.rateLimited,
      retryable: true,
    ),
    >= 500 => const AnalysisFailure(
      code: AnalysisErrorCode.serverError,
      retryable: true,
    ),
    _ => const AnalysisFailure(
      code: AnalysisErrorCode.invalidResponse,
      retryable: true,
    ),
  };
}

final class UnconfiguredScreenshotAnalysisClient
    implements ScreenshotAnalysisClient {
  const UnconfiguredScreenshotAnalysisClient();

  @override
  Future<ScreenshotAnalysisEnvelope> analyze(
    ScreenshotAnalysisRequest request,
  ) => Future.error(
    const AnalysisFailure(
      code: AnalysisErrorCode.notConfigured,
      retryable: false,
    ),
  );
}
