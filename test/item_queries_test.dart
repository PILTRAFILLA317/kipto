import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/repositories/item_queries.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/inbox/domain/inbox_order.dart';
import 'package:kipto/features/notifications/application/notification_route_resolver.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'test_support.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);
  test('T13 review before dates before other; accepted reminder does not resolve or duplicate hero', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = TestAuthRepository();
    final now = DateTime.utc(2026, 9, 5);
    final clock = Clock.fixed(now);
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: auth,
      onLocalChange: () {},
    );
    final items = DriftItemsRepository(
      db,
      syncCoordinator: coordinator,
      clock: clock,
    );
    final repo = DriftLifeAdminRepository(db, coordinator, clock: clock);
    final other = await items.create(title: 'Sin fecha');
    final dated = await items.create(title: 'Próximo');
    final review = await items.create(title: 'Revisar');
    final archived = await items.create(title: 'Archivado');
    await items.setStatus(archived.id, ItemStatus.archived);
    for (final item in [review, dated]) {
      await repo.propose(
        ItemAction(
          id: item.id,
          itemId: item.id,
          ownerId: item.ownerId,
          title: item.title,
          payload: RemindPayload(),
          origin: ActionOrigin.user,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    await repo.accept(
      dated.id,
      RemindPayload(instant: now.add(const Duration(days: 2)), zone: 'UTC'),
    );
    final signals = await ItemQueries(db).watchSignals(auth.userId).first;
    final ordered = orderInbox(await items.watchAll().first, signals);
    expect(ordered.map((e) => e.item.id), [review.id, dated.id, other.id]);
    final hero = ordered.first;
    final rest = ordered.skip(1);
    expect(rest.any((e) => e.item.id == hero.item.id), isFalse);
    expect(ordered.map((e) => e.group), [
      InboxGroup.review,
      InboxGroup.dated,
      InboxGroup.other,
    ]);
    expect((await items.findById(dated.id))!.status, ItemStatus.active);
  });
  test('T14 source-text search is local, literal, owner scoped; notification checks both identifiers and tombstones', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = TestAuthRepository();
    final now = DateTime.utc(2026, 9, 5);
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: auth,
      onLocalChange: () {},
    );
    final items = DriftItemsRepository(db, syncCoordinator: coordinator);
    final item = await items.create(title: 'Factura');
    final another = await items.create(title: 'Otro');
    await db
        .into(db.sources)
        .insert(
          SourcesCompanion.insert(
            id: 'source',
            itemId: item.id,
            ownerId: Value(auth.userId),
            kind: 'text',
            origin: 'manual',
            originalName: 'Original',
            mimeType: 'text/plain',
            byteSize: 10,
            contentHash: 'hash',
            textContent: const Value('Referencia única ABC 100%'),
            createdAt: now,
            updatedAt: now,
            syncStatus: SyncStatus.pendingCreate,
          ),
        );
    final queries = ItemQueries(db);
    expect(await queries.search('ABC', auth.userId).first, {item.id});
    expect(await queries.search('100%', auth.userId).first, {item.id});
    expect(await queries.search('100_', auth.userId).first, isEmpty);
    expect(await queries.search('ABC', 'user-b').first, isEmpty);
    expect(await queries.search('hash', auth.userId).first, isEmpty);
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            id: 'reminder',
            itemId: item.id,
            ownerId: Value(auth.userId),
            remindAt: now,
            createdAt: now,
            updatedAt: now,
            syncStatus: SyncStatus.pendingCreate,
          ),
        );
    final resolver = NotificationRouteResolver(
      db,
      currentOwner: () => auth.userId,
    );
    final payload = ReminderNotificationPayload(
      itemId: item.id,
      reminderId: 'reminder',
    ).encode();
    expect(await resolver.routeForPayload(payload), '/items/${item.id}');
    expect(
      await resolver.routeForPayload(
        ReminderNotificationPayload(
          itemId: another.id,
          reminderId: 'reminder',
        ).encode(),
      ),
      '/inbox',
    );
    expect(
      await resolver.routeForPayload('{"itemId":"../../settings"}'),
      '/inbox',
    );
    expect(
      await NotificationRouteResolver(
        db,
        currentOwner: () => 'user-b',
      ).routeForPayload(payload),
      '/inbox',
    );
    await items.delete(item.id);
    expect(await items.findById(item.id), isNull);
    expect(await queries.search('ABC', auth.userId).first, isEmpty);
    expect(await resolver.routeForPayload(payload), '/inbox');
  });
}
