// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_cache.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_repository.dart';

final class CloudPreviewResolver {
  CloudPreviewResolver({
    required AppDatabase database,
    required AuthRepository auth,
    required CloudPreviewRepository? remote,
    required CloudPreviewCache cache,
    this.maxConcurrentDownloads = 3,
  }) : _database = database,
       _auth = auth,
       _remote = remote,
       _cache = cache;

  final AppDatabase _database;
  final AuthRepository _auth;
  final CloudPreviewRepository? _remote;
  final CloudPreviewCache _cache;
  final int maxConcurrentDownloads;
  final Map<String, Future<String?>> _inFlight = {};
  final List<Completer<void>> _waiters = [];
  int _active = 0;

  Future<String?> resolve({
    required String savedItemId,
    required String cloudPath,
  }) => _inFlight.putIfAbsent(
    cloudPath,
    () => _resolve(savedItemId: savedItemId, cloudPath: cloudPath).whenComplete(
      () {
        _inFlight.remove(cloudPath);
      },
    ),
  );

  Future<String?> _resolve({
    required String savedItemId,
    required String cloudPath,
  }) async {
    final userId = _auth.userId;
    if (userId == null || !cloudPath.startsWith('$userId/')) return null;
    final cached = await _cache.lookup(
      savedItemId: savedItemId,
      cloudPath: cloudPath,
    );
    if (cached != null) {
      await _remember(savedItemId, cloudPath, cached);
      return cached;
    }
    if (_remote == null) return null;
    await _acquire();
    final started = DateTime.now().toUtc();
    try {
      _log('preview.download.started', {'savedItemId': savedItemId});
      final bytes = await _remote.download(cloudPath);
      final path = await _cache.store(
        savedItemId: savedItemId,
        cloudPath: cloudPath,
        bytes: bytes,
      );
      await _remember(savedItemId, cloudPath, path);
      _log('preview.download.completed', {
        'savedItemId': savedItemId,
        'durationMs': DateTime.now().toUtc().difference(started).inMilliseconds,
      });
      return path;
    } on Object {
      return null;
    } finally {
      _release();
    }
  }

  Future<void> _remember(
    String savedItemId,
    String cloudPath,
    String localPath,
  ) async {
    final item = await _database.savedItemsDao.findById(savedItemId);
    if (item == null || item.cloudPreviewPath != cloudPath) return;
    if (item.previewCachePath == localPath) return;
    await _database.savedItemsDao.updateFields(
      savedItemId,
      SavedItemsCompanion(previewCachePath: Value(localPath)),
    );
  }

  Future<void> _acquire() async {
    if (_active < maxConcurrentDownloads) {
      _active++;
      return;
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
    _active++;
  }

  void _release() {
    _active--;
    if (_waiters.isNotEmpty) _waiters.removeAt(0).complete();
  }

  void _log(String event, Map<String, Object?> fields) {
    if (kDebugMode) debugPrint('$event $fields');
  }
}
