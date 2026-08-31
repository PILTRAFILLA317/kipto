import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/cloud_preview/application/cloud_preview_backup_service.dart';
import 'package:kipto/features/cloud_preview/application/cloud_preview_resolver.dart';
import 'package:kipto/features/cloud_preview/data/cloud_preview_preferences.dart';
import 'package:kipto/features/cloud_preview/data/file_cloud_preview_cache.dart';
import 'package:kipto/features/cloud_preview/data/photo_manager_cloud_preview_generator.dart';
import 'package:kipto/features/cloud_preview/data/supabase_cloud_preview_repository.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_cache.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_generator.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_repository.dart';

final cloudPreviewGeneratorProvider = Provider<CloudPreviewGenerator>(
  (_) => const PhotoManagerCloudPreviewGenerator(),
);

final cloudPreviewRepositoryProvider = Provider<CloudPreviewRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseCloudPreviewRepository(client);
});

final cloudPreviewCacheProvider = Provider<CloudPreviewCache>(
  (_) => FileCloudPreviewCache(),
);

final cloudPreviewPreferencesProvider = Provider<CloudPreviewPreferences>(
  (_) => SharedPreferencesCloudPreviewPreferences(),
);

final cloudPreviewBackupServiceProvider = Provider<CloudPreviewBackupService>(
  (ref) => CloudPreviewBackupService(
    database: ref.watch(appDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
    generator: ref.watch(cloudPreviewGeneratorProvider),
    remote: ref.watch(cloudPreviewRepositoryProvider),
    cache: ref.watch(cloudPreviewCacheProvider),
    preferences: ref.watch(cloudPreviewPreferencesProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
  ),
);

final cloudPreviewResolverProvider = Provider<CloudPreviewResolver>(
  (ref) => CloudPreviewResolver(
    database: ref.watch(appDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
    remote: ref.watch(cloudPreviewRepositoryProvider),
    cache: ref.watch(cloudPreviewCacheProvider),
  ),
);

typedef CloudPreviewRequest = ({String savedItemId, String cloudPath});

final resolvedCloudPreviewProvider = FutureProvider.autoDispose
    .family<String?, CloudPreviewRequest>(
      (ref, request) => ref
          .watch(cloudPreviewResolverProvider)
          .resolve(
            savedItemId: request.savedItemId,
            cloudPath: request.cloudPath,
          ),
    );

final cloudPreviewCountsProvider = StreamProvider<CloudPreviewCounts>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(cloudPreviewBackupServiceProvider).watchCounts();
});

final cloudPreviewSettingsProvider =
    StateNotifierProvider<
      CloudPreviewSettingsController,
      CloudPreviewPreferenceState
    >((ref) {
      final controller = CloudPreviewSettingsController(
        ref.watch(cloudPreviewPreferencesProvider),
        ref.watch(cloudPreviewBackupServiceProvider),
      );
      unawaited(controller.load());
      return controller;
    });

final class CloudPreviewSettingsController
    extends StateNotifier<CloudPreviewPreferenceState> {
  CloudPreviewSettingsController(this._preferences, this._backup)
    : super(const CloudPreviewPreferenceState());

  final CloudPreviewPreferences _preferences;
  final CloudPreviewBackupService _backup;

  Future<void> load() async => state = await _preferences.load();

  Future<void> setMode(CloudImageSyncMode mode) async {
    await _backup.setMode(mode);
    state = _backup.preferenceState;
  }

  Future<void> pause() async {
    await _backup.pause();
    state = _backup.preferenceState;
  }

  Future<void> resume() async {
    await _backup.resume();
    state = _backup.preferenceState;
  }
}
