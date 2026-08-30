import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/analysis/application/analysis_queue_runner.dart';
import 'package:kipto/features/analysis/application/apply_screenshot_analysis.dart';
import 'package:kipto/features/analysis/data/ai_analysis_preferences.dart';
import 'package:kipto/features/analysis/data/drift_analysis_queue_repository.dart';
import 'package:kipto/features/analysis/data/photo_manager_analysis_image_preparation_service.dart';
import 'package:kipto/features/analysis/data/supabase_screenshot_analysis_client.dart';
import 'package:kipto/features/analysis/domain/analysis_image_preparation_service.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_client.dart';

final aiAnalysisPreferencesProvider =
    StateNotifierProvider<
      AiAnalysisPreferencesController,
      AiAnalysisPreferencesState
    >((_) => AiAnalysisPreferencesController());

final analysisQueueRepositoryProvider = Provider<DriftAnalysisQueueRepository>(
  (ref) => DriftAnalysisQueueRepository(ref.watch(appDatabaseProvider)),
);

final screenshotAnalysisClientProvider = Provider<ScreenshotAnalysisClient>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return client == null
      ? const UnconfiguredScreenshotAnalysisClient()
      : SupabaseScreenshotAnalysisClient(client);
});

final analysisImagePreparationServiceProvider =
    Provider<AnalysisImagePreparationService>(
      (_) => const PhotoManagerAnalysisImagePreparationService(),
    );

final applyScreenshotAnalysisProvider = Provider<ApplyScreenshotAnalysis>(
  (ref) => ApplyScreenshotAnalysis(
    database: ref.watch(appDatabaseProvider),
    syncCoordinator: ref.watch(localSyncCoordinatorProvider),
  ),
);

final analysisQueueRunnerProvider = Provider<AnalysisQueueRunner>((ref) {
  final runner = AnalysisQueueRunner(
    database: ref.watch(appDatabaseProvider),
    queue: ref.watch(analysisQueueRepositoryProvider),
    client: ref.watch(screenshotAnalysisClientProvider),
    imagePreparation: ref.watch(analysisImagePreparationServiceProvider),
    applyAnalysis: ref.watch(applyScreenshotAnalysisProvider),
    locale: () => Platform.localeName.replaceAll('_', '-'),
    persistUserPaused: (value) =>
        ref.read(aiAnalysisPreferencesProvider.notifier).setUserPaused(value),
  );
  ref.onDispose(runner.dispose);
  return runner;
});

final analysisQueueStatusProvider = StreamProvider<AnalysisQueueSnapshot>(
  (ref) => ref.watch(analysisQueueRunnerProvider).watchStatus(),
);

final analysisItemCountsProvider = StreamProvider<AnalysisItemCounts>(
  (ref) => ref.watch(analysisQueueRepositoryProvider).watchItemCounts(),
);

final aiServerConfiguredProvider = Provider<bool>(
  (ref) => ref.watch(supabaseClientProvider) != null,
);
