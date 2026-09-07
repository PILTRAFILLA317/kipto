import 'package:flutter/services.dart';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/features/capture/application/capture_service.dart';

final sourcesRepositoryProvider = Provider(
  (ref) => DriftSourcesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(localSyncCoordinatorProvider),
  ),
);
final itemSourcesProvider = StreamProvider.family<List<Source>, String>((
  ref,
  id,
) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref.watch(sourcesRepositoryProvider).watchForItem(id);
});
final originalStoreProvider = FutureProvider((ref) async {
  final directory = Directory(
    '${(await getApplicationSupportDirectory()).path}/originals',
  );
  await directory.create(recursive: true);
  if (Platform.isIOS) {
    try {
      await const MethodChannel('app.kipto/capture')
          .invokeMethod<void>('excludeOriginalsFromBackup', directory.path);
    } on MissingPluginException {
      /* Unit test / integration not built. */
    }
  }
  return OriginalStore(directory);
});
final captureScopeProvider = Provider<Future<String> Function()>(
  (ref) => () async {
    final owner = ref.read(authRepositoryProvider).userId;
    if (owner != null) return owner;
    try {
      final native = await const MethodChannel('app.kipto/capture')
          .invokeMethod<String>('localScope');
      if (native != null) return native;
    } on MissingPluginException {
      /* Desktop/test or iOS before extension configuration. */
    }
    final preferences = await SharedPreferences.getInstance();
    var installation = preferences.getString('capture.installation');
    if (installation == null) {
      installation = const Uuid().v4();
      await preferences.setString('capture.installation', installation);
    }
    return 'local:$installation';
  },
);
final captureServiceProvider = FutureProvider(
  (ref) async => CaptureService(
    files: await ref.watch(originalStoreProvider.future),
    sources: ref.watch(sourcesRepositoryProvider),
    scope: ref.watch(captureScopeProvider),
  ),
);
