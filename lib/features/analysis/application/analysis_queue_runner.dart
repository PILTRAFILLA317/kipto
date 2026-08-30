// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/features/analysis/application/apply_screenshot_analysis.dart';
import 'package:kipto/features/analysis/data/drift_analysis_queue_repository.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:kipto/features/analysis/domain/analysis_image_preparation_service.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_client.dart';

final class AnalysisQueueRunner {
  AnalysisQueueRunner({
    required AppDatabase database,
    required DriftAnalysisQueueRepository queue,
    required ScreenshotAnalysisClient client,
    required AnalysisImagePreparationService imagePreparation,
    required ApplyScreenshotAnalysis applyAnalysis,
    required String Function() locale,
    Future<void> Function(bool value)? persistUserPaused,
    Clock? clock,
    this.maxAttempts = analysisMaxAttempts,
    this.retryDelays = const [
      Duration(seconds: 5),
      Duration(seconds: 30),
      Duration(minutes: 2),
    ],
  }) : _database = database,
       _queue = queue,
       _client = client,
       _imagePreparation = imagePreparation,
       _applyAnalysis = applyAnalysis,
       _locale = locale,
       _persistUserPaused = persistUserPaused,
       _clock = clock ?? const Clock();

  final AppDatabase _database;
  final DriftAnalysisQueueRepository _queue;
  final ScreenshotAnalysisClient _client;
  final AnalysisImagePreparationService _imagePreparation;
  final ApplyScreenshotAnalysis _applyAnalysis;
  final String Function() _locale;
  final Future<void> Function(bool value)? _persistUserPaused;
  final Clock _clock;
  final int maxAttempts;
  final List<Duration> retryDelays;
  final StreamController<AnalysisQueueSnapshot> _snapshots =
      StreamController.broadcast();

  AnalysisQueueSnapshot _snapshot = const AnalysisQueueSnapshot();
  Future<void>? _loop;
  bool _runAgain = false;
  Timer? _retryTimer;
  bool _initialized = false;
  bool _enabled = false;
  bool _foreground = true;
  bool _userPaused = false;
  int _runCompleted = 0;
  int _runTotal = 0;
  Duration? _lastLatency;
  AnalysisErrorCode? _lastErrorCode;

  AnalysisQueueSnapshot get currentSnapshot => _snapshot;

  Stream<AnalysisQueueSnapshot> watchStatus() async* {
    yield _snapshot;
    yield* _snapshots.stream;
  }

  Future<void> initialize({
    required bool enabled,
    required bool userPaused,
    bool foreground = true,
  }) async {
    if (_initialized) {
      await setEnabled(enabled);
      return;
    }
    _initialized = true;
    _enabled = enabled;
    _userPaused = userPaused;
    _foreground = foreground;
    await _queue.initialize();
    if (_userPaused) await _queue.pausePending();
    final initial = await _queue.snapshot(paused: _userPaused);
    _runTotal = initial.remaining;
    await _refresh();
    _ensureLoop();
  }

  Future<void> start() async {
    _foreground = true;
    await _refresh();
    _ensureLoop();
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (!enabled) _retryTimer?.cancel();
    await _refresh();
    _ensureLoop();
  }

  Future<void> enqueue(String savedItemId, {int priority = 0}) async {
    final before = (await _queue.snapshot(paused: _userPaused)).remaining;
    await _queue.enqueue(savedItemId, priority: priority);
    final after = (await _queue.snapshot(paused: _userPaused)).remaining;
    _runTotal += (after - before).clamp(0, 1);
    await _refresh();
    _log('analysis.queued', {'savedItemId': savedItemId});
    _ensureLoop();
  }

  Future<void> enqueueMany(Iterable<String> savedItemIds) async {
    final before = (await _queue.snapshot(paused: _userPaused)).remaining;
    await _queue.enqueueMany(savedItemIds);
    if (_userPaused) await _queue.pausePending();
    final after = (await _queue.snapshot(paused: _userPaused)).remaining;
    _runTotal += (after - before).clamp(0, after);
    await _refresh();
    _log('analysis.queued', {'count': after - before});
    _ensureLoop();
  }

  Future<int> enqueueUnprocessed() async {
    final ids = await _queue.analyzableUnprocessedIds();
    await enqueueMany(ids);
    return ids.length;
  }

  Future<void> retry(String savedItemId) async {
    final before = (await _queue.snapshot(paused: _userPaused)).remaining;
    await _queue.enqueue(savedItemId, priority: 100, resetAttempts: true);
    final after = (await _queue.snapshot(paused: _userPaused)).remaining;
    _runTotal += (after - before).clamp(0, 1);
    await _refresh();
    _ensureLoop();
  }

  Future<void> pause() async {
    _userPaused = true;
    _retryTimer?.cancel();
    await _queue.pausePending();
    await _persistUserPaused?.call(true);
    await _refresh();
    _log('analysis.paused', const {});
  }

  Future<void> resume() async {
    _userPaused = false;
    await _queue.resumePaused(_clock.now().toUtc());
    await _persistUserPaused?.call(false);
    await _refresh();
    _log('analysis.resumed', const {});
    _ensureLoop();
  }

  void onBackground() {
    _foreground = false;
    _retryTimer?.cancel();
  }

  Future<void> onForeground() async {
    _foreground = true;
    await _refresh();
    _ensureLoop();
  }

  Future<bool> processNext() async {
    if (!_canProcess) return false;
    final entry = await _queue.nextDue(_clock.now().toUtc());
    if (entry == null) {
      _scheduleNextRetry();
      return false;
    }
    await _process(entry.savedItemId);
    return true;
  }

  bool get _canProcess =>
      _initialized && _enabled && _foreground && !_userPaused;

  void _ensureLoop() {
    if (!_canProcess) return;
    if (_loop != null) {
      _runAgain = true;
      return;
    }
    _retryTimer?.cancel();
    final operation = _runLoop();
    _loop = operation;
    unawaited(
      operation.whenComplete(() {
        _loop = null;
        if (_runAgain) {
          _runAgain = false;
          _ensureLoop();
        }
      }),
    );
  }

  Future<void> _runLoop() async {
    while (_canProcess) {
      final didProcess = await processNext();
      if (!didProcess) return;
    }
  }

  Future<void> _process(String savedItemId) async {
    final started = _clock.now().toUtc();
    await _queue.markProcessing(savedItemId, started);
    await _applyAnalysis.markProcessing(savedItemId);
    await _refresh();
    _log('analysis.started', {'savedItemId': savedItemId});
    try {
      final row = await _database.savedItemsDao.findById(
        savedItemId,
        includeDeleted: true,
      );
      if (row == null) {
        await _queue.remove(savedItemId);
        await _completeRunItem();
        return;
      }
      if (!row.originalAvailable || row.localAssetId == null) {
        throw const AnalysisFailure(
          code: AnalysisErrorCode.noLocalAsset,
          retryable: false,
        );
      }
      final image = await _imagePreparation.prepare(row.localAssetId!);
      final envelope = await _client.analyze(
        ScreenshotAnalysisRequest(
          imageBytes: image.bytes,
          mimeType: image.mimeType,
          capturedAt: row.capturedAt,
          locale: _locale(),
        ),
      );
      await _applyAnalysis.apply(savedItemId, envelope);
      _lastLatency = _clock.now().toUtc().difference(started);
      _lastErrorCode = null;
      await _completeRunItem();
      _log('analysis.completed', {
        'savedItemId': savedItemId,
        'durationMs': _lastLatency!.inMilliseconds,
        'confidence': envelope.result.confidence,
        'category': envelope.result.category.storageValue,
      });
    } on AnalysisFailure catch (failure) {
      await _handleFailure(savedItemId, failure);
    } on Object {
      await _handleFailure(
        savedItemId,
        const AnalysisFailure(code: AnalysisErrorCode.unknown, retryable: true),
      );
    }
  }

  Future<void> _handleFailure(
    String savedItemId,
    AnalysisFailure failure,
  ) async {
    final current = await _queue.find(savedItemId);
    final attempts = current?.attemptCount ?? maxAttempts;
    _lastErrorCode = failure.code;
    if (failure.retryable && attempts < maxAttempts) {
      final delay =
          failure.retryAfter ??
          retryDelays[(attempts - 1).clamp(0, retryDelays.length - 1)];
      await _applyAnalysis.markWaitingForRetry(savedItemId);
      await _queue.scheduleRetry(
        savedItemId,
        nextAttemptAt: _clock.now().toUtc().add(delay),
        errorCode: failure.code,
        paused: _userPaused,
      );
      _log('analysis.retry', {
        'savedItemId': savedItemId,
        'attempt': attempts,
        'errorCode': failure.code.name,
      });
    } else {
      await _applyAnalysis.markFailed(savedItemId);
      await _completeRunItem(refresh: false);
      _log('analysis.failed', {
        'savedItemId': savedItemId,
        'errorCode': failure.code.name,
      });
    }
    await _refresh();
  }

  Future<void> _completeRunItem({bool refresh = true}) async {
    _runCompleted++;
    if (refresh) await _refresh();
  }

  Future<void> _scheduleNextRetry() async {
    _retryTimer?.cancel();
    if (!_canProcess) return;
    final next = await _queue.nextRetryAt();
    if (next == null) return;
    final delay = next.difference(_clock.now().toUtc());
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, _ensureLoop);
  }

  Future<void> _refresh() async {
    _snapshot = await _queue.snapshot(
      paused: _userPaused || !_enabled,
      runCompleted: _runCompleted,
      runTotal: _runTotal,
      lastLatency: _lastLatency,
      lastErrorCode: _lastErrorCode,
    );
    if (!_snapshots.isClosed) _snapshots.add(_snapshot);
  }

  void _log(String event, Map<String, Object?> fields) {
    if (kDebugMode) debugPrint('$event $fields');
  }

  Future<void> dispose() async {
    _foreground = false;
    _retryTimer?.cancel();
    await _snapshots.close();
  }
}
