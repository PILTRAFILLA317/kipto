import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/analysis/application/analysis_preparer.dart';
import 'package:kipto/features/analysis/application/analysis_queue.dart';

import 'test_support.dart';

const sourceId = '873cc225-6483-41ea-bf64-c362f5c29677';
final now = DateTime.utc(2026, 9, 5);
Map<String, dynamic> fixture() =>
    jsonDecode(File('test/fixtures/analysis/invoice.json').readAsStringSync())
        as Map<String, dynamic>;
Map<String, dynamic> envelope(String payload) => {
  'requestId': (jsonDecode(payload) as Map)['requestId'],
  'schemaVersion': 1,
  'model': 'synthetic-provider',
  'promptVersion': 'test',
  'analyzedAt': now.toIso8601String(),
  'output': fixture()['output'],
  'usage': {'inputTokens': 1, 'outputTokens': 1},
};
Future<Map<String, Object?>> prepare(_) async => {
  'input': {
    'type': 'text',
    'textPages': fixture()['textPages'],
    'imagePages': [],
  },
  'coverage': {
    'totalPagesKnown': 1,
    'analyzedPages': [1],
    'isPartial': false,
  },
};
Future<LocalSyncCoordinator> seed(
  AppDatabase db,
  TestAuthRepository auth,
) async {
  final coordinator = LocalSyncCoordinator(
    database: db,
    auth: auth,
    onLocalChange: () {},
  );
  final item = await DriftItemsRepository(
    db,
    syncCoordinator: coordinator,
  ).create(title: 'Título elegido por mí');
  await db
      .into(db.sources)
      .insert(
        SourcesCompanion.insert(
          id: sourceId,
          itemId: item.id,
          ownerId: Value(auth.userId),
          kind: 'text',
          origin: 'manual',
          originalName: 'Factura',
          mimeType: 'text/plain',
          byteSize: 4,
          contentHash: 'synthetic',
          createdAt: now,
          updatedAt: now,
          syncStatus: SyncStatus.pendingCreate,
        ),
      );
  return coordinator;
}

AnalysisQueue makeQueue(
  AppDatabase db,
  TestAuthRepository auth,
  LocalSyncCoordinator coordinator, {
  required Future<Map<String, dynamic>> Function(String, String) send,
  bool Function()? consent,
  Clock? clock,
  Future<Map<String, Object?>> Function(dynamic)? preparation,
}) => AnalysisQueue(
  database: db,
  sources: DriftSourcesRepository(db, coordinator),
  repository: DriftLifeAdminRepository(
    db,
    coordinator,
    clock: Clock.fixed(now),
  ),
  currentOwner: () => auth.userId,
  consented: consent ?? () => true,
  prepare: preparation ?? prepare,
  send: send,
  clock: clock ?? Clock.fixed(now),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);
  test('T10 restart retries identical payload; reanalysis preserves corrections, title and accepted reminder', () async {
    final dir = Directory.systemTemp.createTempSync('kipto-analysis-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/test.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    final auth = TestAuthRepository();
    var coordinator = await seed(db, auth);
    final payloads = <String>[];
    var queue = makeQueue(
      db,
      auth,
      coordinator,
      send: (_, payload) async {
        payloads.add(payload);
        throw const AnalysisFailure(
          'network',
          retryAfter: Duration(seconds: 60),
        );
      },
    );
    await queue.enqueue(sourceId, locale: 'es', timeZone: 'Europe/Madrid');
    await queue.resume();
    expect((await db.select(db.analysisJobs).get()).single.state, 'retry');
    queue.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    addTearDown(() => db.close());
    coordinator = LocalSyncCoordinator(
      database: db,
      auth: auth,
      onLocalChange: () {},
    );
    var preparations = 0;
    queue = makeQueue(
      db,
      auth,
      coordinator,
      clock: Clock.fixed(now.add(const Duration(minutes: 2))),
      preparation: (source) async {
        preparations++;
        return prepare(source);
      },
      send: (_, payload) async {
        payloads.add(payload);
        return envelope(payload);
      },
    );
    addTearDown(queue.dispose);
    await queue.resume();
    expect(payloads, hasLength(2));
    expect(payloads[0], payloads[1]);
    expect(preparations, 0);
    final job = (await db.select(db.analysisJobs).get()).single;
    expect(job.state, 'done');
    expect(job.payload, isNull);
    expect(await db.select(db.facts).get(), hasLength(1));
    expect(await db.select(db.itemActions).get(), hasLength(1));
    expect(await db.select(db.reminders).get(), isEmpty);
    final repo = DriftLifeAdminRepository(
      db,
      coordinator,
      clock: Clock.fixed(now),
    );
    final factId = (await db.select(db.facts).get()).single.id;
    final actionId = (await db.select(db.itemActions).get()).single.id;
    await repo.correctFact(
      factId,
      DateFactValue(date: null, raw: 'Fecha pendiente de confirmar'),
    );
    await repo.accept(
      actionId,
      RemindPayload(
        instant: now.add(const Duration(days: 3)),
        zone: 'Europe/Madrid',
      ),
    );
    await queue.enqueue(sourceId, locale: 'es', timeZone: 'Europe/Madrid');
    await queue.resume();
    expect(
      (await db.select(db.items).get()).single.title,
      'Título elegido por mí',
    );
    expect((await repo.findFact(factId))!.userValue, isNotNull);
    expect((await repo.findAction(actionId))!.state, ActionState.accepted);
    expect(await db.select(db.itemActions).get(), hasLength(1));
    expect(await db.select(db.reminders).get(), hasLength(1));
    expect((await db.select(db.analysisJobs).get()).single.state, 'done');
  });

  for (final changed in ['owner', 'revision', 'deleted', 'consent']) {
    test('T10 drops an in-flight result after $changed changes', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final auth = TestAuthRepository();
      final coordinator = await seed(db, auth);
      final sent = Completer<String>(),
          response = Completer<Map<String, dynamic>>();
      var consent = true;
      final queue = makeQueue(
        db,
        auth,
        coordinator,
        consent: () => consent,
        send: (_, payload) {
          sent.complete(payload);
          return response.future;
        },
      );
      addTearDown(queue.dispose);
      await queue.enqueue(sourceId, locale: 'es', timeZone: 'Europe/Madrid');
      final payload = await sent.future;
      if (changed == 'owner') await auth.signOut();
      if (changed == 'revision') {
        await db
            .update(db.sources)
            .write(const SourcesCompanion(revision: Value(2)));
      }
      if (changed == 'deleted') {
        await db.update(db.items).write(ItemsCompanion(deletedAt: Value(now)));
      }
      if (changed == 'consent') consent = false;
      response.complete(envelope(payload));
      await queue.resume();
      expect(await db.select(db.facts).get(), isEmpty);
      expect(await db.select(db.itemActions).get(), isEmpty);
      expect(await db.select(db.reminders).get(), isEmpty);
      expect((await db.select(db.analysisJobs).get()).single.state, 'stale');
    });
  }
  test('T10 paused preparation persists bytes but does not send without foreground/consent', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = TestAuthRepository();
    final coordinator = await seed(db, auth);
    final started = Completer<void>(),
        prepared = Completer<Map<String, Object?>>();
    var sends = 0, consent = true;
    final queue = makeQueue(
      db,
      auth,
      coordinator,
      consent: () => consent,
      preparation: (_) {
        started.complete();
        return prepared.future;
      },
      send: (_, payload) async {
        sends++;
        return envelope(payload);
      },
    );
    addTearDown(queue.dispose);
    await queue.enqueue(sourceId, locale: 'es', timeZone: 'Europe/Madrid');
    final draining = queue.resume();
    await started.future;
    queue.pause();
    prepared.complete(await prepare(null));
    await draining;
    expect(sends, 0);
    expect((await db.select(db.analysisJobs).get()).single.payload, isNotNull);
    consent = false;
    await queue.resume();
    expect(sends, 0);
    consent = true;
    await queue.resume();
    expect(sends, 1);
  });
}
