import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/features/items/presentation/item_detail_screen.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/presentation/widgets/kipto_animated_sliver_list.dart';
import 'package:kipto/core/presentation/widgets/life_admin_card.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/inbox/presentation/inbox_screen.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

import 'test_support.dart';

Future<void> driveUntil(WidgetTester tester, bool Function() ready) async {
  for (var n = 0; n < 100 && !ready(); n++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }
  expect(ready(), isTrue);
}

Future<void> mutate(
  WidgetTester tester,
  Future<void> Function() operation,
) async {
  var done = false;
  Object? failure;
  await tester.runAsync(() async {
    operation().then(
      (_) => done = true,
      onError: (Object error) {
        failure = error;
        done = true;
      },
    );
  });
  await driveUntil(tester, () => done);
  if (failure != null) throw failure!;
}

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'T21 list snapshots reorder, reverse deletion and remove old account immediately; reduced=$reduced',
      (tester) async {
        final rows = ValueNotifier((owner: 'a', ids: ['a', 'b']));
        addTearDown(rows.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: ValueListenableBuilder(
              valueListenable: rows,
              builder: (context, value, _) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: reduced),
                child: CustomScrollView(
                  slivers: [
                    KiptoAnimatedSliverList<String>(
                      accountScope: value.owner,
                      items: value.ids,
                      idOf: (id) => id,
                      itemBuilder: (context, id, index) {
                        // Check that outgoing rows receive their original snapshot index.
                        expect(value.ids[index], id);
                        return SizedBox(
                          height: 60,
                          child: TextButton(
                            onPressed: () {},
                            child: Hero(tag: id, child: Text(id)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        rows.value = (owner: 'a', ids: ['c', 'd', 'e', 'b', 'a']);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 30));
        rows.value = (owner: 'a', ids: ['a', 'e']);
        await tester.pump();
        rows.value = (owner: 'a', ids: ['a', 'b', 'e']);
        await tester.pump();
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<Text>(find.byType(Text))
              .map((w) => w.data)
              .toList(),
          ['a', 'b', 'e'],
        );
        rows.value = (owner: 'a', ids: <String>[]);
        await tester.pump();
        rows.value = (owner: 'b', ids: ['private-b']);
        await tester.pump();
        for (final old in ['a', 'b', 'c', 'd', 'e']) {
          expect(find.text(old), findsNothing);
        }
        expect(find.text('private-b'), findsOneWidget);
        rows.value = (owner: 'b', ids: List.generate(50, (i) => 'row-$i'));
        await tester.pumpAndSettle();
        expect(find.byType(TextButton).evaluate().length, lessThan(50));
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position;
        final offset = position.pixels;
        expect(offset, greaterThan(0));
        rows.value = (owner: 'b', ids: List.of(rows.value.ids));
        await tester.pumpAndSettle();
        expect(position.pixels, offset);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );

    testWidgets(
      'T21 actual inbox follows repository resolve/undo and opens a Hero during changes; reduced=$reduced',
      (tester) async {
        tester.view.physicalSize = const Size(360, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final authA = TestAuthRepository();
        final authB = TestAuthRepository(
          const KiptoUser(id: 'user-b', isAnonymous: true),
        );
        final selectedAuth = StateProvider<AuthRepository>((ref) => authA);
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            authRepositoryProvider.overrideWith(
              (ref) => ref.watch(selectedAuth),
            ),
            itemsRepositoryProvider.overrideWith(
              (ref) => DriftItemsRepository(
                db,
                syncCoordinator: LocalSyncCoordinator(
                  database: db,
                  auth: ref.watch(authRepositoryProvider),
                  onLocalChange: () {},
                ),
              ),
            ),
            itemSignalsProvider.overrideWith((ref) => Stream.value({})),
          ],
        );
        addTearDown(container.dispose);
        final repository = container.read(itemsRepositoryProvider);
        final first = await tester.runAsync(
          () => repository.create(title: 'Asunto A1'),
        );
        await tester.runAsync(() => repository.create(title: 'Asunto A2'));
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: InboxScreen()),
            ),
            GoRoute(
              path: '/items/:id',
              builder: (_, state) =>
                  ItemDetailScreen(itemId: state.pathParameters['id']!),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.dark(),
              locale: const Locale('es'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: reduced,
                  textScaler: const TextScaler.linear(2),
                ),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await mutate(
          tester,
          () => repository.updateText(
            first!.id,
            title: 'Asunto A1 editado',
            summary: '',
          ),
        );
        await driveUntil(
          tester,
          () => find.text('Asunto A1 editado').evaluate().isNotEmpty,
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<LifeAdminCard>(find.byType(LifeAdminCard))
              .first
              .itemId,
          first!.id,
        );
        await mutate(
          tester,
          () => repository.setStatus(first.id, ItemStatus.resolved),
        );
        await driveUntil(
          tester,
          () => find.text('1 asunto activo').evaluate().isNotEmpty,
        );
        if (!reduced) {
          expect(
            find.byWidgetPredicate((w) => w is HeroMode && !w.enabled),
            findsWidgets,
          );
        }
        await mutate(
          tester,
          () => repository.setStatus(first.id, ItemStatus.active),
        );
        await driveUntil(
          tester,
          () => find.text('2 asuntos activos').evaluate().isNotEmpty,
        );
        // A push while the removed copy still animates must not register two Heroes.
        final card = tester
            .widgetList<LifeAdminCard>(find.byType(LifeAdminCard))
            .firstWhere((card) => card.itemId == first.id);
        card.onTap!();
        await tester.pumpAndSettle();
        expect(find.byType(ItemDetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        router.pop();
        await tester.pumpAndSettle();
        await mutate(
          tester,
          () => repository.setStatus(first.id, ItemStatus.resolved),
        );
        await driveUntil(
          tester,
          () => find.text('1 asunto activo').evaluate().isNotEmpty,
        );
        container.read(selectedAuth.notifier).state = authB;
        await tester.pump();
        expect(find.text('Asunto A1 editado'), findsNothing);
        expect(find.text('Asunto A2'), findsNothing);
        final other = container.read(itemsRepositoryProvider);
        late String otherId;
        await mutate(tester, () async {
          otherId = (await other.create(title: 'Asunto B')).id;
        });
        await driveUntil(
          tester,
          () => find.text('Asunto B').evaluate().isNotEmpty,
        );
        await tester.pumpAndSettle();
        expect(find.text('Asunto A2'), findsNothing);
        await mutate(
          tester,
          () => other.setStatus(otherId, ItemStatus.resolved),
        );
        await driveUntil(
          tester,
          () => find.text('Ningún asunto activo').evaluate().isNotEmpty,
        );
        await tester.pumpAndSettle();
        expect(find.byType(LifeAdminCard), findsNothing);
        await mutate(tester, () => other.setStatus(otherId, ItemStatus.active));
        await driveUntil(
          tester,
          () => find.text('Asunto B').evaluate().isNotEmpty,
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
}
