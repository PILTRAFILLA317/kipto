import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/config/app_config.dart';

void main() {
  test('cloud config requires both a valid URL and publishable key', () {
    expect(
      const AppConfig(
        supabaseUrl: '',
        supabasePublishableKey: '',
      ).isCloudConfigured,
      isFalse,
    );
    expect(
      const AppConfig(
        supabaseUrl: 'https://project.supabase.co',
        supabasePublishableKey: 'sb_publishable_test',
      ).isCloudConfigured,
      isTrue,
    );
  });
}
