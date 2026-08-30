import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/features/analysis/application/analysis_queue_runner.dart';
import 'package:kipto/features/analysis/application/apply_screenshot_analysis.dart';
import 'package:kipto/features/analysis/data/drift_analysis_queue_repository.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:kipto/features/analysis/domain/analysis_image_preparation_service.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_client.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

import 'test_helpers.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  test(
    'queue deduplicates, pauses, resumes, and preserves retry metadata',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final items = DriftSavedItemsRepository(database);
      await items.create(
        testSavedItem(
          id: 'queued-item',
          now: now,
          analysisStatus: AnalysisStatus.unprocessed,
        ),
      );
      final queue = DriftAnalysisQueueRepository(database);

      await queue.enqueue('queued-item');
      await queue.enqueue('queued-item');
      expect((await queue.snapshot(paused: false)).queued, 1);

      await queue.markProcessing('queued-item', now);
      await queue.scheduleRetry(
        'queued-item',
        nextAttemptAt: now.add(const Duration(seconds: 30)),
        errorCode: AnalysisErrorCode.rateLimited,
        paused: false,
      );
      var entry = (await queue.find('queued-item'))!;
      expect(entry.attemptCount, 1);
      expect(entry.state, AnalysisQueueState.retryScheduled);
      expect(entry.lastErrorCode, AnalysisErrorCode.rateLimited);

      await queue.pausePending();
      expect(
        (await queue.find('queued-item'))!.state,
        AnalysisQueueState.paused,
      );
      await queue.resumePaused(now);
      entry = (await queue.find('queued-item'))!;
      expect(entry.state, AnalysisQueueState.retryScheduled);
    },
  );

  test('queue survives an application database restart', () async {
    final directory = await Directory.systemTemp.createTemp('kipto-analysis-');
    final file = File('${directory.path}/kipto.sqlite');
    addTearDown(() => directory.delete(recursive: true));
    var database = AppDatabase(NativeDatabase(file));
    await DriftSavedItemsRepository(database).create(
      testSavedItem(
        id: 'persistent-item',
        now: now,
        analysisStatus: AnalysisStatus.unprocessed,
      ),
    );
    final queue = DriftAnalysisQueueRepository(database);
    await queue.enqueue('persistent-item');
    await queue.markProcessing('persistent-item', now);
    await database.savedItemsDao.updateFields(
      'persistent-item',
      const SavedItemsCompanion(
        analysisStatus: Value(AnalysisStatus.processing),
      ),
    );
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final reopenedQueue = DriftAnalysisQueueRepository(database);
    await reopenedQueue.initialize();
    final entry = await reopenedQueue.find('persistent-item');
    expect(entry?.state, AnalysisQueueState.queued);
    expect(
      (await database.savedItemsDao.findById('persistent-item'))
          ?.analysisStatus,
      AnalysisStatus.unprocessed,
    );
  });

  test(
    'bulk runner processes 100 items with concurrency one and real progress',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final itemRepository = DriftSavedItemsRepository(database);
      final queue = DriftAnalysisQueueRepository(database);
      final ids = List.generate(100, (index) => 'bulk-$index');
      for (final id in ids) {
        await itemRepository.create(
          testSavedItem(
            id: id,
            now: now,
            localAssetId: 'asset-$id',
            originalAvailable: true,
            analysisStatus: AnalysisStatus.unprocessed,
          ),
        );
      }
      await queue.enqueueMany(ids);
      final client = _TrackingClient(delay: const Duration(milliseconds: 1));
      final runner = _runner(database, queue, client);
      addTearDown(runner.dispose);

      await runner.initialize(
        enabled: true,
        userPaused: false,
        foreground: false,
      );
      await runner.onForeground();
      await _waitUntil(
        () =>
            runner.currentSnapshot.runCompleted == 100 &&
            runner.currentSnapshot.remaining == 0,
      );

      expect(client.calls, 100);
      expect(client.maxActive, analysisConcurrency);
      expect(runner.currentSnapshot.runTotal, 100);
      expect(runner.currentSnapshot.runCompleted, 100);
    },
  );

  test('runner starts no work while paused and resumes the same job', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await DriftSavedItemsRepository(database).create(
      testSavedItem(
        id: 'paused-item',
        now: now,
        localAssetId: 'asset-paused',
        originalAvailable: true,
        analysisStatus: AnalysisStatus.unprocessed,
      ),
    );
    final queue = DriftAnalysisQueueRepository(database);
    await queue.enqueue('paused-item');
    final client = _TrackingClient();
    final runner = _runner(database, queue, client);
    addTearDown(runner.dispose);

    await runner.initialize(enabled: true, userPaused: true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(client.calls, 0);
    expect(runner.currentSnapshot.paused, isTrue);

    await runner.resume();
    await _waitUntil(() => runner.currentSnapshot.remaining == 0);
    expect(client.calls, 1);
  });

  test(
    'transient failures stop at max attempts and preserve SavedItem',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await DriftSavedItemsRepository(database).create(
        testSavedItem(
          id: 'retry-item',
          now: now,
          localAssetId: 'asset-retry',
          originalAvailable: true,
          analysisStatus: AnalysisStatus.unprocessed,
        ),
      );
      final queue = DriftAnalysisQueueRepository(database);
      await queue.enqueue('retry-item');
      final client = _TrackingClient(
        failure: const AnalysisFailure(
          code: AnalysisErrorCode.rateLimited,
          retryable: true,
          retryAfter: Duration.zero,
        ),
      );
      final runner = _runner(
        database,
        queue,
        client,
        retryDelays: const [Duration.zero, Duration.zero, Duration.zero],
      );
      addTearDown(runner.dispose);

      await runner.initialize(enabled: true, userPaused: false);
      await _waitUntil(() async {
        final row = await database.savedItemsDao.findById('retry-item');
        return row?.analysisStatus == AnalysisStatus.failed;
      });

      expect(client.calls, analysisMaxAttempts);
      expect(await queue.find('retry-item'), isNull);
      expect(await database.savedItemsDao.findById('retry-item'), isNotNull);
    },
  );

  test(
    'missing local asset fails permanently without invoking the client',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await DriftSavedItemsRepository(database).create(
        testSavedItem(
          id: 'missing-item',
          now: now,
          analysisStatus: AnalysisStatus.unprocessed,
        ),
      );
      final queue = DriftAnalysisQueueRepository(database);
      await queue.enqueue('missing-item');
      final client = _TrackingClient();
      final runner = _runner(database, queue, client);
      addTearDown(runner.dispose);

      await runner.initialize(enabled: true, userPaused: false);
      await _waitUntil(() async {
        final row = await database.savedItemsDao.findById('missing-item');
        return row?.analysisStatus == AnalysisStatus.failed;
      });

      expect(client.calls, 0);
      expect(await database.savedItemsDao.findById('missing-item'), isNotNull);
    },
  );
}

AnalysisQueueRunner _runner(
  AppDatabase database,
  DriftAnalysisQueueRepository queue,
  ScreenshotAnalysisClient client, {
  List<Duration> retryDelays = const [Duration.zero],
}) => AnalysisQueueRunner(
  database: database,
  queue: queue,
  client: client,
  imagePreparation: const _FakeImagePreparation(),
  applyAnalysis: ApplyScreenshotAnalysis(database: database),
  locale: () => 'es-ES',
  retryDelays: retryDelays,
);

final class _FakeImagePreparation implements AnalysisImagePreparationService {
  const _FakeImagePreparation();

  @override
  Future<PreparedAnalysisImage> prepare(String localAssetId) async =>
      PreparedAnalysisImage(
        bytes: Uint8List.fromList(const [0xff, 0xd8, 0xff, 0xd9]),
        mimeType: 'image/jpeg',
        width: 1080,
        height: 2340,
      );
}

final class _TrackingClient implements ScreenshotAnalysisClient {
  _TrackingClient({this.delay = Duration.zero, this.failure});

  final Duration delay;
  final AnalysisFailure? failure;
  int calls = 0;
  int active = 0;
  int maxActive = 0;

  @override
  Future<ScreenshotAnalysisEnvelope> analyze(
    ScreenshotAnalysisRequest request,
  ) async {
    calls++;
    active++;
    if (active > maxActive) maxActive = active;
    try {
      if (delay != Duration.zero) await Future<void>.delayed(delay);
      final currentFailure = failure;
      if (currentFailure != null) throw currentFailure;
      return _envelope;
    } finally {
      active--;
    }
  }
}

const _envelope = ScreenshotAnalysisEnvelope(
  model: defaultAnalysisModel,
  promptVersion: analysisPromptVersion,
  result: ScreenshotAnalysisResult(
    schemaVersion: analysisSchemaVersion,
    category: SavedItemCategory.information,
    subtype: 'reference',
    intent: ScreenshotIntent.keepForReference,
    title: 'Useful reference',
    summary: 'Information saved for later.',
    requiresAction: false,
    suggestedActions: [SavedItemActionType.save],
    entities: {'creator': 'Kipto'},
    relevance: AnalysisRelevance.evergreen,
    confidence: 0.9,
    uncertainFields: [],
    searchKeywords: ['reference'],
  ),
);

Future<void> _waitUntil(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  throw TimeoutException('Condition not reached in $timeout');
}
