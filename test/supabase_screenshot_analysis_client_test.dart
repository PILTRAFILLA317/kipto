import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/features/analysis/data/supabase_screenshot_analysis_client.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_client.dart';

void main() {
  test(
    'analysis request serializes capturedAt with an explicit UTC offset',
    () {
      final body = encodeScreenshotAnalysisRequest(
        ScreenshotAnalysisRequest(
          imageBytes: Uint8List.fromList(const [0xff, 0xd8, 0xff, 0xd9]),
          mimeType: 'image/jpeg',
          capturedAt: DateTime(2026, 8, 30, 14, 47, 32),
          locale: 'es-ES',
        ),
      );

      expect(body['capturedAt'], endsWith('Z'));
      expect(DateTime.parse(body['capturedAt']! as String).isUtc, isTrue);
    },
  );
}
