// ignore_for_file: prefer_initializing_formals

import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';

final class AccountService {
  const AccountService({
    required AuthRepository auth,
    required AppDatabase database,
    required Future<void> Function() stopSync,
    required Future<void> Function() clearNotifications,
  }) : _auth = auth,
       _database = database,
       _stopSync = stopSync,
       _clearNotifications = clearNotifications;

  final AuthRepository _auth;
  final AppDatabase _database;
  final Future<void> Function() _stopSync;
  final Future<void> Function() _clearNotifications;

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.isAnonymous) {
      throw StateError('Protect an anonymous library before signing out');
    }
    await _stopSync();
    await _clearNotifications();
    await _database.transaction(() async {
      await _database.customStatement('DELETE FROM notification_mappings');
      await _database.delete(_database.syncQueue).go();
      await _database.delete(_database.reminders).go();
      await _database.delete(_database.items).go();
      await _database.delete(_database.cloudSyncStates).go();
    });
    await _auth.signOut();
  }
}
