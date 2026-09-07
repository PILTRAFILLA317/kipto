import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/repositories/life_admin_mapper.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/core/sync/sync_service.dart';

import 'test_support.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);
  test('T08 fact correction, accepted action and reminder round-trip in dependency order', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = TestAuthRepository();
    final now = DateTime.utc(2026, 9, 5);
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: auth,
      onLocalChange: () {},
    );
    final item = await DriftItemsRepository(
      db,
      syncCoordinator: coordinator,
    ).create(title: 'Synthetic invoice');
    final repo = DriftLifeAdminRepository(
      db,
      coordinator,
      clock: Clock.fixed(now),
    );
    final source = SourcesCompanion.insert(
      id: 'source',
      itemId: item.id,
      ownerId: Value(testUser.id),
      kind: 'text',
      origin: 'manual',
      originalName: 'Invoice',
      mimeType: 'text/plain',
      byteSize: 4,
      contentHash: 'hash',
      textContent: const Value('Amount: 10 EUR'),
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pendingCreate,
    );
    await db.into(db.sources).insert(source);
    await coordinator.enqueue(
      entityType: SyncEntityType.source,
      entityId: 'source',
      operation: SyncOperation.create,
    );
    final fact = Fact(
      id: 'fact',
      itemId: item.id,
      ownerId: testUser.id,
      sourceId: 'source',
      sourceRevision: 1,
      key: 'amount',
      value: MoneyFactValue('10', 'EUR'),
      provenance: FactProvenance.extracted,
      evidence: FactEvidence(
        page: 1,
        quote: '10 EUR',
        verification: EvidenceVerification.textMatched,
      ),
      createdAt: now,
      updatedAt: now,
    );
    await repo.insertFact(fact);
    await repo.correctFact('fact', MoneyFactValue('12', 'EUR'));
    final corrected = (await repo.findFact('fact'))!;
    expect(corrected.value.toJson()['amount'], '10');
    expect(corrected.effectiveValue.toJson()['amount'], '12');
    expect(corrected.evidence.quote, '10 EUR');
    final action = ItemAction(
      id: 'action',
      itemId: item.id,
      ownerId: testUser.id,
      title: 'Review invoice',
      payload: RemindPayload(),
      origin: ActionOrigin.analysis,
      sourceId: 'source',
      analysisRevision: 1,
      evidenceFactIds: ['fact'],
      createdAt: now,
      updatedAt: now,
    );
    await repo.propose(action);
    expect(await db.select(db.reminders).get(), isEmpty);
    final confirmed = RemindPayload(
      instant: DateTime.utc(2026, 10, 14, 7),
      zone: 'Europe/Madrid',
    );
    for (var retry = 0; retry < 2; retry++) {
      expect(await repo.accept('action', confirmed), 'action');
    }
    expect(await db.select(db.reminders).get(), hasLength(1));
    expect((await db.itemsDao.findById(item.id))!.status, ItemStatus.active);
    expect(
      (await repo.findAction('action'))!.executionState,
      ActionExecutionState.pending,
    );
    await expectLater(repo.dismiss('action'), throwsStateError);
    final remote = FakeRemoteDataSource();
    final sync = SyncService(database: db, auth: auth, remote: remote);
    addTearDown(sync.dispose);
    await sync.initialize();
    expect(
      remote.calls,
      containsAllInOrder([
        'items',
        'sources',
        'facts',
        'item_actions',
        'reminders',
      ]),
    );
    expect(remote.reminders['action']!.actionId, 'action');
    expect(remote.reminders['action']!.timeZone, 'Europe/Madrid');
    expect(remote.facts['fact']!.userValue!.toJson()['amount'], '12');
    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);
    final pull = SyncService(database: restored, auth: auth, remote: remote);
    addTearDown(pull.dispose);
    await pull.initialize();
    expect(pull.currentStatus.errorMessage, isNull);
    final restoredAction = actionFromRow(
      (await restored.select(restored.itemActions).get()).single,
    );
    expect(
      jsonEncode(restoredAction.toJson()),
      jsonEncode((await repo.findAction('action'))!.toJson()),
    );
    expect(
      (await restored.select(restored.reminders).get()).single.actionId,
      'action',
    );
  });
  test(
    'T08 database rejects cross-owner and cross-item evidence and reminders',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.utc(2026, 9, 5);
      for (final id in ['a', 'b']) {
        await db
            .into(db.items)
            .insert(
              ItemsCompanion.insert(
                id: id,
                ownerId: Value('owner-$id'),
                title: id,
                status: ItemStatus.active,
                createdAt: now,
                updatedAt: now,
                syncStatus: SyncStatus.synced,
              ),
            );
        await db
            .into(db.sources)
            .insert(
              SourcesCompanion.insert(
                id: 'source-$id',
                itemId: id,
                ownerId: Value('owner-$id'),
                kind: 'text',
                origin: 'manual',
                originalName: id,
                mimeType: 'text/plain',
                byteSize: 1,
                contentHash: 'h',
                createdAt: now,
                updatedAt: now,
                syncStatus: SyncStatus.synced,
              ),
            );
      }
      Fact make(String owner, String source) => Fact(
        id: 'f',
        itemId: 'a',
        ownerId: owner,
        sourceId: source,
        sourceRevision: 1,
        key: 'text',
        value: TextFactValue('x'),
        provenance: FactProvenance.extracted,
        evidence: FactEvidence(verification: EvidenceVerification.unverified),
        createdAt: now,
        updatedAt: now,
      );
      for (final fact in [
        make('owner-b', 'source-b'),
        make('owner-a', 'source-b'),
      ]) {
        await expectLater(
          db.into(db.facts).insert(factCompanion(fact, SyncStatus.synced)),
          throwsA(anything),
        );
      }
      await db
          .into(db.facts)
          .insert(
            factCompanion(make('owner-a', 'source-a'), SyncStatus.synced),
          );
      final wrongAction = ItemAction(
        id: 'action',
        itemId: 'b',
        ownerId: 'owner-b',
        title: 'x',
        payload: RemindPayload(),
        origin: ActionOrigin.user,
        evidenceFactIds: ['f'],
        createdAt: now,
        updatedAt: now,
      );
      await expectLater(
        db
            .into(db.itemActions)
            .insert(actionCompanion(wrongAction, SyncStatus.synced)),
        throwsA(anything),
      );
      final validAction = ItemAction(
        id: 'action',
        itemId: 'a',
        ownerId: 'owner-a',
        title: 'x',
        payload: RemindPayload(),
        origin: ActionOrigin.user,
        evidenceFactIds: ['f'],
        createdAt: now,
        updatedAt: now,
      );
      await db
          .into(db.itemActions)
          .insert(actionCompanion(validAction, SyncStatus.synced));
      await expectLater(
        db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                id: 'reminder',
                itemId: 'b',
                ownerId: const Value('owner-b'),
                actionId: const Value('action'),
                remindAt: now,
                createdAt: now,
                updatedAt: now,
                syncStatus: SyncStatus.synced,
              ),
            ),
        throwsA(anything),
      );
      expect(await db.select(db.reminders).get(), isEmpty);
    },
  );
}
