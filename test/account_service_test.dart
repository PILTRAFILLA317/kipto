import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/features/account/application/account_service.dart';

import 'fakes/fake_sync_dependencies.dart';
import 'test_helpers.dart';

void main() {
  test(
    'permanent logout stops runners and clears only local account data',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final auth = FakeAuthRepository(
        const KiptoUser(id: 'user-a', isAnonymous: false),
      );
      await DriftSavedItemsRepository(database).create(
        testSavedItem(
          id: 'item-a',
          now: DateTime.utc(2026, 8, 30),
          ownerId: 'user-a',
          localAssetId: 'photos-asset-a',
          originalAvailable: true,
        ),
      );
      final cloudObjects = {'user-a/item-a/preview-v1.jpg'};
      var syncStopped = false;
      var analysisStopped = false;
      var previewsStopped = false;
      var cacheCleared = false;
      var notificationsCleared = false;
      final service = AccountService(
        auth: auth,
        database: database,
        stopSync: () async => syncStopped = true,
        stopAnalysis: () => analysisStopped = true,
        stopPreviews: () => previewsStopped = true,
        clearPreviewCache: () async => cacheCleared = true,
        clearNotifications: () async => notificationsCleared = true,
      );

      await service.signOut();

      expect(syncStopped, isTrue);
      expect(analysisStopped, isTrue);
      expect(previewsStopped, isTrue);
      expect(cacheCleared, isTrue);
      expect(notificationsCleared, isTrue);
      expect(await database.savedItemsDao.getActive(), isEmpty);
      expect(auth.currentUser, isNull);
      expect(cloudObjects, contains('user-a/item-a/preview-v1.jpg'));
    },
  );

  test('anonymous logout is blocked without deleting its library', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final auth = FakeAuthRepository(
      const KiptoUser(id: 'user-a', isAnonymous: true),
    );
    await DriftSavedItemsRepository(database).create(
      testSavedItem(
        id: 'anonymous-item',
        now: DateTime.utc(2026, 8, 30),
        ownerId: 'user-a',
      ),
    );
    final service = AccountService(
      auth: auth,
      database: database,
      stopSync: () async {},
      stopAnalysis: () {},
      stopPreviews: () {},
      clearPreviewCache: () async {},
      clearNotifications: () async {},
    );

    await expectLater(service.signOut(), throwsStateError);
    expect(await database.savedItemsDao.getActive(), hasLength(1));
    expect(auth.currentUser, isNotNull);
  });
}
