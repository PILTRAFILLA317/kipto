import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/analysis/application/apply_screenshot_analysis.dart';
import 'package:kipto/features/analysis/data/drift_analysis_queue_repository.dart';
import 'package:kipto/features/analysis/domain/analysis_constants.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

import 'fakes/fake_sync_dependencies.dart';
import 'test_helpers.dart';

void main() {
  const ownerId = '00000000-0000-4000-8000-000000000001';
  final now = DateTime.utc(2026, 8, 30, 12);
  late AppDatabase database;
  late DriftAnalysisQueueRepository queue;
  late LocalSyncCoordinator syncCoordinator;
  late ApplyScreenshotAnalysis apply;

  setUp(() {
    database = createTestDatabase();
    queue = DriftAnalysisQueueRepository(database);
    syncCoordinator = LocalSyncCoordinator(
      database: database,
      auth: FakeAuthRepository(const KiptoUser(id: ownerId, isAnonymous: true)),
      onLocalChange: () {},
      clock: Clock.fixed(now),
    );
    apply = ApplyScreenshotAnalysis(
      database: database,
      syncCoordinator: syncCoordinator,
      clock: Clock.fixed(now),
    );
  });

  tearDown(() => database.close());

  test('atomically applies analysis, preserves overrides/status, and enqueues sync', () async {
    const id = 'user-edited-item';
    await DriftSavedItemsRepository(database).create(
      testSavedItem(
        id: id,
        now: now,
        ownerId: ownerId,
        title: 'Concierto con Ana',
        category: SavedItemCategory.conversation,
        status: SavedItemStatus.archived,
        analysisStatus: AnalysisStatus.unprocessed,
        entities: const {
          SavedItem.userNoteEntityKey: 'Ir con Ana',
          'pixelWidth': 1170,
          'pixelHeight': 2532,
          SavedItem.analysisMetadataEntityKey: {
            'titleSource': 'user',
            'categorySource': 'user',
          },
        },
      ),
    );
    await queue.enqueue(id);
    final reminders = DriftRemindersRepository(
      database,
      idGenerator: () => 'existing-reminder',
      clock: Clock.fixed(now),
    );
    await reminders.create(
      savedItemId: id,
      remindAt: now.add(const Duration(days: 1)),
    );

    await apply.apply(id, _eventEnvelope());

    final row = (await database.savedItemsDao.findById(id))!;
    expect(row.title, 'Concierto con Ana');
    expect(row.category, SavedItemCategory.conversation);
    expect(row.status, SavedItemStatus.archived);
    expect(row.analysisStatus, AnalysisStatus.processed);
    expect(row.analysisVersion, analysisSchemaVersion);
    expect(row.intent, 'attend_event');
    expect(row.entities[SavedItem.userNoteEntityKey], 'Ir con Ana');
    expect(row.entities['pixelWidth'], 1170);
    final metadata = Map<String, Object?>.from(
      row.entities[SavedItem.analysisMetadataEntityKey]! as Map,
    );
    expect(metadata['model'], defaultAnalysisModel);
    expect(metadata['promptVersion'], analysisPromptVersion);
    expect(metadata['titleSource'], 'user');
    expect(metadata['categorySource'], 'user');
    expect(await queue.find(id), isNull);
    final sync = await database.syncQueueDao.pending();
    expect(sync, hasLength(1));
    expect(sync.single.entityId, id);
    expect(sync.single.operation, SyncOperation.update);
    expect(
      (await database.remindersDao.findById('existing-reminder'))?.savedItemId,
      id,
    );
  });

  test('low confidence is needsReview and never creates a reminder', () async {
    const id = 'low-confidence';
    await DriftSavedItemsRepository(database).create(
      testSavedItem(
        id: id,
        now: now,
        ownerId: ownerId,
        analysisStatus: AnalysisStatus.unprocessed,
      ),
    );

    await apply.apply(id, _eventEnvelope(confidence: 0.55));

    final row = (await database.savedItemsDao.findById(id))!;
    expect(row.analysisStatus, AnalysisStatus.needsReview);
    expect(row.status, SavedItemStatus.needsAction);
    expect(
      await database.customSelect('SELECT * FROM reminders').get(),
      isEmpty,
    );
  });

  test(
    'rolls back SavedItem, sync operation, and queue removal together',
    () async {
      const id = 'rollback-item';
      await DriftSavedItemsRepository(database).create(
        testSavedItem(
          id: id,
          now: now,
          ownerId: ownerId,
          title: 'Before',
          analysisStatus: AnalysisStatus.unprocessed,
        ),
      );
      await queue.enqueue(id);
      await database.customStatement('''
      CREATE TRIGGER reject_analysis_sync
      BEFORE INSERT ON sync_queue
      BEGIN
        SELECT RAISE(ABORT, 'synthetic sync failure');
      END
    ''');

      await expectLater(apply.apply(id, _eventEnvelope()), throwsA(isNotNull));

      final row = (await database.savedItemsDao.findById(id))!;
      expect(row.title, 'Before');
      expect(row.analysisStatus, AnalysisStatus.unprocessed);
      expect(await queue.find(id), isNotNull);
      expect(await database.syncQueueDao.pending(), isEmpty);
    },
  );
}

ScreenshotAnalysisEnvelope _eventEnvelope({double confidence = 0.94}) =>
    ScreenshotAnalysisEnvelope(
      model: defaultAnalysisModel,
      promptVersion: analysisPromptVersion,
      result: ScreenshotAnalysisResult(
        schemaVersion: analysisSchemaVersion,
        category: SavedItemCategory.event,
        subtype: 'concert',
        intent: ScreenshotIntent.attendEvent,
        title: 'Coldplay',
        summary: 'Concierto de Coldplay en Madrid el 18 de septiembre.',
        sourceApp: 'Instagram',
        requiresAction: true,
        suggestedActions: const [
          SavedItemActionType.addCalendar,
          SavedItemActionType.createReminder,
        ],
        eventAt: DateTime.utc(2026, 9, 18, 20),
        location: const AnalysisLocation(
          name: 'Metropolitano',
          city: 'Madrid',
          query: 'Metropolitano Madrid',
        ),
        entities: const {'artist': 'Coldplay', 'venue': 'Metropolitano'},
        relevance: AnalysisRelevance.active,
        confidence: confidence,
        uncertainFields: const [],
        searchKeywords: const ['coldplay', 'madrid', 'concert'],
      ),
    );
