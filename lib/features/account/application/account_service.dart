// ignore_for_file: prefer_initializing_formals

import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';

final class AccountService {
  const AccountService({
    required AuthRepository auth,
    required AppDatabase database,
    required Future<void> Function() stopSync,
    required void Function() stopAnalysis,
    required void Function() stopPreviews,
    required Future<void> Function() clearPreviewCache,
    required Future<void> Function() clearNotifications,
  }) : _auth = auth,
       _database = database,
       _stopSync = stopSync,
       _stopAnalysis = stopAnalysis,
       _stopPreviews = stopPreviews,
       _clearPreviewCache = clearPreviewCache,
       _clearNotifications = clearNotifications;

  final AuthRepository _auth;
  final AppDatabase _database;
  final Future<void> Function() _stopSync;
  final void Function() _stopAnalysis;
  final void Function() _stopPreviews;
  final Future<void> Function() _clearPreviewCache;
  final Future<void> Function() _clearNotifications;

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.isAnonymous) {
      throw StateError('Protect an anonymous library before signing out');
    }
    _stopPreviews();
    _stopAnalysis();
    await _stopSync();
    await _clearNotifications();
    await _clearPreviewCache();
    await _database.transaction(() async {
      await _database.delete(_database.previewTransferJobs).go();
      await _database.delete(_database.syncQueue).go();
      await _database.delete(_database.reminders).go();
      await _database.delete(_database.savedItems).go();
      await _database.delete(_database.cloudSyncStates).go();
      await _database.delete(_database.screenshotImportStates).go();
    });
    await _auth.signOut();
  }
}
