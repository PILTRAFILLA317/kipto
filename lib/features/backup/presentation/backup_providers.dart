import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/features/settings/application/privacy_preferences.dart';

import '../application/file_queue.dart';
import '../application/file_transport.dart';

final fileQueueProvider = Provider((ref) {
  final queue = FileQueue(
    database: ref.watch(appDatabaseProvider),
    files: () => ref.read(originalStoreProvider.future),
    owner: () => ref.read(authRepositoryProvider).userId,
    canUpload: () =>
        ref.read(privacyPreferencesProvider).backup &&
        ref.read(privacyPreferencesProvider).sync,
    transfer: (job, file, progress) async {
      final auth = ref.read(authRepositoryProvider);
      await auth.recoverSession();
      final session = ref.read(supabaseClientProvider)?.auth.currentSession;
      if (session == null ||
          session.user.id != job.ownerId ||
          auth.userId != job.ownerId) {
        throw const FileTransferFailure('unauthorized');
      }
      if (job.operation == 'upload' &&
          !ref.read(privacyPreferencesProvider).backup) {
        throw const FileTransferFailure('consentRequired');
      }
      await transferOriginal(
        config: ref.read(appConfigProvider),
        token: session.accessToken,
        sourceId: job.sourceId,
        revision: job.revision,
        operation: job.operation,
        file: file,
        progress: progress,
      );
    },
  );
  ref.onDispose(queue.dispose);
  return queue;
});
final fileJobsProvider = StreamProvider<List<FileJobRow>>((ref) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref.watch(fileQueueProvider).watch();
});
