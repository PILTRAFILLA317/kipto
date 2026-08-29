import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/domain/photo_library_repository.dart';

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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) {
      unawaited(_resume());
    } else {
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
