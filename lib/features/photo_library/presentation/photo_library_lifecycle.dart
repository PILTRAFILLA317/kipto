import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/domain/photo_library_repository.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:kipto/features/analysis/presentation/providers/analysis_providers.dart';

final class PhotoLibraryLifecycle extends ConsumerStatefulWidget {
  const PhotoLibraryLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PhotoLibraryLifecycle> createState() =>
      _PhotoLibraryLifecycleState();
}

final class _PhotoLibraryLifecycleState
    extends ConsumerState<PhotoLibraryLifecycle>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _changesSubscription;
  Timer? _debounce;
  PhotoLibraryRepository? _repository;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final repository = ref.read(photoLibraryRepositoryProvider);
    _repository = repository;
    final analysisInitialization = _initializeAnalysis();
    await ref.read(screenshotImportControllerProvider.notifier).initialize();
    _changesSubscription = repository.changes.listen((_) {
      if (!_active) return;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        ref
            .read(screenshotImportControllerProvider.notifier)
            .scanForNewScreenshots(forceReconcile: true);
      });
    });
    if (ref.read(screenshotImportControllerProvider).permission.hasAccess) {
      await repository.startObservingChanges();
    }
    await ref.read(syncServiceProvider).initialize();
    await analysisInitialization;
    if (!mounted) return;
    await ref.read(analysisQueueRunnerProvider).onForeground();
  }

  Future<void> _initializeAnalysis() async {
    final preferences = ref.read(aiAnalysisPreferencesProvider.notifier);
    await preferences.load();
    if (!mounted) return;
    final preferenceState = ref.read(aiAnalysisPreferencesProvider);
    await ref
        .read(analysisQueueRunnerProvider)
        .initialize(
          enabled: preferenceState.enabled,
          userPaused: preferenceState.userPaused,
          foreground: false,
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) {
      unawaited(_resume());
    } else {
      ref.read(analysisQueueRunnerProvider).onBackground();
      unawaited(_repository?.stopObservingChanges());
    }
  }

  Future<void> _resume() async {
    await ref.read(screenshotImportControllerProvider.notifier).onResumed();
    if (!mounted) return;
    if (ref.read(screenshotImportControllerProvider).permission.hasAccess) {
      await _repository?.startObservingChanges();
    } else {
      await _repository?.stopObservingChanges();
    }
    await ref.read(syncServiceProvider).syncNow(SyncReason.resume);
    await ref.read(analysisQueueRunnerProvider).onForeground();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _changesSubscription?.cancel();
    _repository?.stopObservingChanges();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
