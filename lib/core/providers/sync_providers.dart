import 'package:kipto/features/settings/application/privacy_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/auth/supabase_auth_repository.dart';
import 'package:kipto/core/config/app_config.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/core/sync/remote_data_source.dart';
import 'package:kipto/core/sync/supabase_remote_data_source.dart';
import 'package:kipto/core/sync/sync_service.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final appConfigProvider = Provider<AppConfig>(
  (_) => AppConfig.fromEnvironment(),
);

final supabaseClientProvider = Provider<SupabaseClient?>((_) => null);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null
      ? const UnconfiguredAuthRepository()
      : SupabaseAuthRepository(client.auth);
});

final authStateProvider = StreamProvider<KiptoAuthState>(
  (ref) => ref.watch(authRepositoryProvider).watchAuthState(),
);

final remoteDataSourceProvider = Provider<KiptoRemoteDataSource?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseRemoteDataSource(client);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    canSync: () => ref.read(privacyPreferencesProvider).sync,
    database: ref.watch(appDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
    remote: ref.watch(remoteDataSourceProvider),
    onRemindersChanged: () =>
        ref.read(reminderNotificationSchedulerProvider).reconcile(),
  );
  ref.onDispose(service.dispose);
  return service;
});

final localSyncCoordinatorProvider = Provider<LocalSyncCoordinator>(
  (ref) => LocalSyncCoordinator(
    database: ref.watch(appDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
    onLocalChange: () =>
        ref.read(syncServiceProvider).scheduleSync(SyncReason.localChange),
  ),
);

final syncStatusProvider = StreamProvider<SyncStatusSnapshot>(
  (ref) => ref.watch(syncServiceProvider).watchStatus(),
);
