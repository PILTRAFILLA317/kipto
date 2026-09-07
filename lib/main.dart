import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/bootstrap.dart';
import 'package:kipto/core/config/app_config.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  pdfrxFlutterInitialize();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  final config = AppConfig.fromEnvironment();
  SupabaseClient? client;
  if (config.isCloudConfigured) {
    final supabase = await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );
    client = supabase.client;
  }
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        supabaseClientProvider.overrideWithValue(client),
      ],
      child: const AppBootstrap(),
    ),
  );
}
