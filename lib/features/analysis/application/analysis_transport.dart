import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kipto/core/config/app_config.dart';
import 'package:kipto/features/analysis/application/analysis_preparer.dart';

/// REST here preserves Retry-After and bounds the response stream; the
/// functions SDK currently exposes neither response headers nor a size cap.
Future<Map<String, dynamic>> sendAnalysis(
  AppConfig config,
  String token,
  String payload,
) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    return await (() async {
      final request = await client.postUrl(
        Uri.parse('${config.supabaseUrl}/functions/v1/analyze-source'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('apikey', config.supabasePublishableKey);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(payload));
      final response = await request.close();
      final bytes = <int>[];
      await for (final chunk in response) {
        if (bytes.length + chunk.length > 256 * 1024) {
          throw const AnalysisFailure('invalidOutput');
        }
        bytes.addAll(chunk);
      }
      Map<String, dynamic>? body;
      try {
        body = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      } on Object {
        /* Report controlled status only. */
      }
      if (response.statusCode != 200) {
        final raw = body?['error'];
        const known = {
          'busy',
          'quotaBlocked',
          'globalLimit',
          'mismatch',
          'expired',
          'indeterminate',
          'failed',
          'authenticationRequired',
          'configurationUnavailable',
          'serviceUnavailable',
          'providerRateLimited',
          'invalidOutput',
          'invalidRequest',
          'refused',
          'providerUnavailable',
          'providerIndeterminate',
          'providerRefused',
          'providerRejected',
        };
        final seconds = int.tryParse(
          response.headers.value('retry-after') ?? '',
        );
        throw AnalysisFailure(
          known.contains(raw)
              ? raw as String
              : response.statusCode == 401
              ? 'authenticationRequired'
              : 'serviceUnavailable',
          retryAfter: seconds == null
              ? null
              : Duration(seconds: seconds.clamp(1, 86400)),
        );
      }
      if (body == null) throw const AnalysisFailure('invalidOutput');
      return body;
    })().timeout(const Duration(seconds: 60));
  } on AnalysisFailure {
    rethrow;
  } on TimeoutException {
    throw const AnalysisFailure('network');
  } on SocketException {
    throw const AnalysisFailure('network');
  } on HttpException {
    throw const AnalysisFailure('network');
  } finally {
    client.close(force: true);
  }
}
