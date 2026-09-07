import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: prefer_initializing_formals

import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';

final class AccountService {
  const AccountService({
    required AuthRepository auth,
    required AppDatabase database,
    required Future<void> Function() stopSync,
    required Future<void> Function() clearNotifications,
    this.clearFiles,
  }) : _auth = auth,
       _database = database,
       _stopSync = stopSync,
       _clearNotifications = clearNotifications;

  final AuthRepository _auth;
  final AppDatabase _database;
  final Future<void> Function() _stopSync;
  final Future<void> Function() _clearNotifications;

  final Future<void> Function(String owner, List<String> sourceIds)? clearFiles;
  Future<({int changes, int originals})> pendingLoss() async {
    final user = _auth.userId;
    if (user == null) return (changes: 0, originals: 0);
    final changes = await _database
        .customSelect(
          "SELECT count(*) AS n FROM items WHERE owner_id=? AND sync_status<>'synced'",
          variables: [Variable(user)],
        )
        .getSingle();
    final originals = await _database
        .customSelect(
          """SELECT count(*) AS n FROM sources s JOIN source_files f ON f.source_id=s.id
      WHERE s.owner_id=? AND f.original_relative_path IS NOT NULL AND NOT EXISTS
      (SELECT 1 FROM file_jobs j WHERE j.owner_id=s.owner_id AND j.source_id=s.id AND j.revision=s.revision AND j.state='done' AND j.operation='upload')""",
          variables: [Variable(user)],
        )
        .getSingle();
    return (
      changes: changes.read<int>('n'),
      originals: originals.read<int>('n'),
    );
  }

  static const pendingSignOutKey = 'account.pendingSignOut.v1';

  Future<void> recoverSignOutCleanup() async {
    final prefs = await SharedPreferences.getInstance();
    final owner = prefs.getString(pendingSignOutKey);
    if (owner == null) return;
    // If logout never succeeded, preserve the original signed-in library.
    if (_auth.userId != owner) await _clearLibrary(owner);
    if (!await prefs.remove(pendingSignOutKey)) {
      throw StateError('Cleanup pending');
    }
  }

  Future<void> signOut({bool discardLocalData = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.isAnonymous) {
      throw StateError('Protect an anonymous library before signing out');
    }
    if (!discardLocalData) {
      throw StateError('Confirm local library removal before signing out');
    }
    await _stopSync();
    // A failed logout must leave the library and pending changes intact.
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(pendingSignOutKey, user.id)) {
      throw StateError('Could not persist cleanup');
    }
    try {
      await _auth.signOut();
    } on Object {
      if (_auth.userId == user.id) await prefs.remove(pendingSignOutKey);
      rethrow;
    }
    await _clearNotifications();
    await _clearLibrary(user.id);
    if (!await prefs.remove(pendingSignOutKey)) {
      throw StateError('Cleanup pending');
    }
  }

  Future<void> finishAccountDeletion(String owner) async {
    if (_auth.userId != null && _auth.userId != owner) {
      throw StateError('Account changed');
    }
    await _stopSync();
    await _clearNotifications();
    try {
      await _auth.signOut();
    } on Object {
      if (_auth.userId != null) rethrow;
      // The SDK has cleared its session despite the remote error.
    }
    await _clearLibrary(owner);
  }

  Future<void> _clearLibrary(String owner) async {
    final sources = await (_database.select(
      _database.sources,
    )..where((s) => s.ownerId.equals(owner))).get();
    await clearFiles?.call(owner, sources.map((s) => s.id).toList());
    await _database.transaction(() async {
      for (final table in [
        'items',
        'sources',
        'facts',
        'item_actions',
        'reminders',
      ]) {
        await _database.customStatement(
          'DELETE FROM sync_queue WHERE entity_id IN (SELECT id FROM $table WHERE owner_id=?)',
          [owner],
        );
      }
      await (_database.delete(
        _database.fileJobs,
      )..where((j) => j.ownerId.equals(owner))).go();
      await (_database.delete(
        _database.reminders,
      )..where((r) => r.ownerId.equals(owner))).go();
      await (_database.delete(
        _database.itemActions,
      )..where((r) => r.ownerId.equals(owner))).go();
      await (_database.delete(
        _database.facts,
      )..where((r) => r.ownerId.equals(owner))).go();
      await (_database.delete(
        _database.sources,
      )..where((r) => r.ownerId.equals(owner))).go();
      await (_database.delete(
        _database.items,
      )..where((r) => r.ownerId.equals(owner))).go();
      await (_database.delete(
        _database.cloudSyncStates,
      )..where((r) => r.userId.equals(owner))).go();
    });
  }
}
