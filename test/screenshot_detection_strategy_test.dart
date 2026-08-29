import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/features/photo_library/data/screenshot_detection_strategy.dart';

void main() {
  const strategy = ScreenshotDetectionStrategy();

  test('recognizes common and localized Android screenshot locations', () {
    expect(
      strategy.isAndroidScreenshotLocation(
        albumName: 'Screenshots',
        relativePath: 'Pictures/Screenshots/',
      ),
      isTrue,
    );
    expect(
      strategy.isAndroidScreenshotLocation(
        albumName: 'Capturas de pantalla',
        relativePath: 'DCIM/Capturas de pantalla/',
      ),
      isTrue,
    );
    expect(
      strategy.isAndroidScreenshotLocation(
        albumName: 'Camera',
        relativePath: 'DCIM/Camera/',
      ),
      isFalse,
    );
  });

  test('uses display name as a centralized fallback', () {
    expect(
      strategy.isAndroidScreenshotAsset(
        title: 'Screenshot_20260829.png',
        relativePath: 'Pictures/',
      ),
      isTrue,
    );
  });
}
