import 'dart:typed_data';

import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

final class ScreenshotAnalysisRequest {
  const ScreenshotAnalysisRequest({
    required this.imageBytes,
    required this.mimeType,
    required this.capturedAt,
    required this.locale,
  });

  final Uint8List imageBytes;
  final String mimeType;
  final DateTime capturedAt;
  final String locale;
}

abstract interface class ScreenshotAnalysisClient {
  Future<ScreenshotAnalysisEnvelope> analyze(ScreenshotAnalysisRequest request);
}

final class FakeScreenshotAnalysisClient implements ScreenshotAnalysisClient {
  FakeScreenshotAnalysisClient(this.handler);

  final Future<ScreenshotAnalysisEnvelope> Function(
    ScreenshotAnalysisRequest request,
  )
  handler;

  int calls = 0;

  @override
  Future<ScreenshotAnalysisEnvelope> analyze(
    ScreenshotAnalysisRequest request,
  ) {
    calls++;
    return handler(request);
  }
}
