import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/features/settings/application/privacy_preferences.dart';
import 'package:kipto/features/analysis/application/analysis_preparer.dart';
import 'package:kipto/features/analysis/application/analysis_queue.dart';
import 'package:kipto/features/analysis/application/analysis_transport.dart';

final analysisQueueProvider = Provider((ref) {
  final queue = AnalysisQueue(
    database: ref.watch(appDatabaseProvider),
    sources: ref.watch(sourcesRepositoryProvider),
    repository: ref.watch(lifeAdminRepositoryProvider),
    currentOwner: () => ref.read(authRepositoryProvider).userId,
    consented: () => ref.read(privacyPreferencesProvider).analysis,
    prepare: (source) async => AnalysisPreparer(
      ref.read(sourcesRepositoryProvider),
      await ref.read(originalStoreProvider.future),
    ).prepare(source),
    send: (owner, payload) async {
      final auth = ref.read(authRepositoryProvider);
      await auth.recoverSession();
      final session = ref.read(supabaseClientProvider)?.auth.currentSession;
      if (auth.userId != owner ||
          session?.user.id != owner ||
          session == null) {
        throw const AnalysisFailure('authenticationRequired');
      }
      if (!ref.read(privacyPreferencesProvider).analysis) {
        throw const AnalysisFailure('consentRequired');
      }
      return sendAnalysis(
        ref.read(appConfigProvider),
        session.accessToken,
        payload,
      );
    },
  );
  final state = WidgetsBinding.instance.lifecycleState;
  if (state != null && state != AppLifecycleState.resumed) queue.pause();
  ref.onDispose(queue.dispose);
  return queue;
});
final analysisJobProvider = StreamProvider.family<AnalysisJobRow?, String>(
  (ref, id) => ref.watch(analysisQueueProvider).watch(id),
);
