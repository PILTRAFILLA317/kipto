import 'package:kipto/features/settings/application/privacy_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/account/application/account_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Concurrent consent choices persist without inheriting another account',
    () async {
      final prefs = PrivacyPreferencesController(scope: 'a');
      addTearDown(prefs.dispose);
      await prefs.ready;
      await Future.wait([
        prefs.update(sync: true),
        prefs.update(analysis: true),
      ]);
      expect(prefs.state.sync, isTrue);
      expect(prefs.state.analysis, isTrue);
      final restored = PrivacyPreferencesController(scope: 'a');
      final other = PrivacyPreferencesController(scope: 'b');
      addTearDown(restored.dispose);
      addTearDown(other.dispose);
      await Future.wait([restored.ready, other.ready]);
      expect(restored.state.sync, isTrue);
      expect(restored.state.analysis, isTrue);
      expect(other.state.sync, isFalse);
      expect(other.state.analysis, isFalse);
    },
  );
  test(
    'T20 failed logout preserves library; interrupted cleanup resumes durably',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final auth = TestAuthRepository(
        const KiptoUser(id: 'account', isAnonymous: false),
      );
      final items = DriftItemsRepository(
        db,
        syncCoordinator: LocalSyncCoordinator(
          database: db,
          auth: auth,
          onLocalChange: () {},
        ),
      );
      final item = await items.create(title: 'Pending original');
      var failFiles = false;
      final service = AccountService(
        auth: auth,
        database: db,
        stopSync: () async {},
        clearNotifications: () async {},
        clearFiles: (_, _) async {
          if (failFiles) throw StateError('Synthetic filesystem failure');
        },
      );
      auth.failSignOut = true;
      await expectLater(
        service.signOut(discardLocalData: true),
        throwsStateError,
      );
      expect(await db.itemsDao.findById(item.id), isNotNull);
      expect(auth.userId, 'account');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AccountService.pendingSignOutKey), isNull);
      auth.failSignOut = false;
      failFiles = true;
      await expectLater(
        service.signOut(discardLocalData: true),
        throwsStateError,
      );
      expect(auth.userId, isNull);
      expect(await db.itemsDao.findById(item.id), isNotNull);
      expect(prefs.getString(AccountService.pendingSignOutKey), 'account');
      failFiles = false;
      await service.recoverSignOutCleanup();
      expect(await db.itemsDao.findById(item.id), isNull);
      expect(prefs.getString(AccountService.pendingSignOutKey), isNull);
      await service.recoverSignOutCleanup();
      expect(await db.select(db.syncQueue).get(), isEmpty);
    },
  );
}
