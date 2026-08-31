import 'dart:async';

import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/sync/remote_data_source.dart';
import 'package:kipto/core/sync/remote_models.dart';

final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.identity);
  KiptoUser? identity;

  @override
  KiptoUser? get currentUser => identity;
  @override
  KiptoSession? get currentSession =>
      identity == null ? null : KiptoSession(user: identity!, isExpired: false);
  @override
  bool get isAnonymous => identity?.isAnonymous ?? false;
  @override
  String? get userId => identity?.id;
  @override
  Future<KiptoSession?> ensureSession() async => currentSession;
  @override
  Future<KiptoSession?> recoverSession() async => currentSession;
  @override
  Future<void> protectWithApple() async {}
  @override
  Future<void> protectWithGoogle() async {}
  @override
  Future<void> signInExistingWithApple() async {}
  @override
  Future<void> signInExistingWithGoogle() async {}
  @override
  Future<void> signOut() async => identity = null;
  @override
  Stream<KiptoAuthState> watchAuthState() => Stream.value(
    identity == null
        ? const KiptoAuthState(KiptoAuthStatus.signedOut)
        : KiptoAuthState(
            identity!.isAnonymous
                ? KiptoAuthStatus.anonymous
                : KiptoAuthStatus.permanent,
            userId: identity!.id,
          ),
  );
}

final class FakeRemoteDataSource implements KiptoRemoteDataSource {
  final Map<String, RemoteSavedItem> savedItems = {};
  final Map<String, RemoteReminder> reminders = {};
  final List<RemoteDevice> devices = [];
  final StreamController<void> invalidations = StreamController.broadcast();
  bool fail = false;
  Duration delay = Duration.zero;
  int savedUpsertCalls = 0;
  int reminderUpsertCalls = 0;
  int activeCalls = 0;
  int maxActiveCalls = 0;
  int _tick = 0;

  DateTime _serverTime() =>
      DateTime.utc(2030, 1, 1).add(Duration(milliseconds: _tick++));

  Future<void> _enter() async {
    if (fail) throw const FakeNetworkError();
    activeCalls++;
    if (activeCalls > maxActiveCalls) maxActiveCalls = activeCalls;
    if (delay != Duration.zero) await Future<void>.delayed(delay);
  }

  void _leave() => activeCalls--;

  @override
  Future<List<RemoteSavedItem>> upsertSavedItems(
    List<RemoteSavedItem> items,
  ) async {
    await _enter();
    try {
      savedUpsertCalls++;
      final result = <RemoteSavedItem>[];
      for (final item in items) {
        final current = savedItems[item.id];
        final winner =
            current != null &&
                current.clientUpdatedAt.isAfter(item.clientUpdatedAt)
            ? current
            : _copySaved(item, serverUpdatedAt: _serverTime());
        savedItems[item.id] = winner;
        result.add(winner);
      }
      return result;
    } finally {
      _leave();
    }
  }

  @override
  Future<List<RemoteSavedItem>> fetchSavedItemsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    await _enter();
    try {
      final threshold = cursor?.subtract(const Duration(seconds: 2));
      final rows =
          savedItems.values
              .where(
                (row) =>
                    threshold == null ||
                    !row.serverUpdatedAt.isBefore(threshold),
              )
              .toList()
            ..sort((a, b) {
              final timestamp = a.serverUpdatedAt.compareTo(b.serverUpdatedAt);
              return timestamp == 0 ? a.id.compareTo(b.id) : timestamp;
            });
      return rows.skip(offset).take(limit).toList();
    } finally {
      _leave();
    }
  }

  @override
  Future<List<RemoteReminder>> upsertReminders(
    List<RemoteReminder> values,
  ) async {
    await _enter();
    try {
      reminderUpsertCalls++;
      final result = <RemoteReminder>[];
      for (final item in values) {
        final current = reminders[item.id];
        final winner =
            current != null &&
                current.clientUpdatedAt.isAfter(item.clientUpdatedAt)
            ? current
            : _copyReminder(item, serverUpdatedAt: _serverTime());
        reminders[item.id] = winner;
        result.add(winner);
      }
      return result;
    } finally {
      _leave();
    }
  }

  @override
  Future<List<RemoteReminder>> fetchRemindersChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    await _enter();
    try {
      final threshold = cursor?.subtract(const Duration(seconds: 2));
      final rows =
          reminders.values
              .where(
                (row) =>
                    threshold == null ||
                    !row.serverUpdatedAt.isBefore(threshold),
              )
              .toList()
            ..sort((a, b) => a.serverUpdatedAt.compareTo(b.serverUpdatedAt));
      return rows.skip(offset).take(limit).toList();
    } finally {
      _leave();
    }
  }

  @override
  Future<void> upsertDevice(RemoteDevice device) async {
    await _enter();
    try {
      devices.removeWhere((value) => value.id == device.id);
      devices.add(device);
    } finally {
      _leave();
    }
  }

  @override
  Future<RemoteInvalidationSubscription> subscribeToInvalidations(
    String userId,
  ) async => _FakeInvalidationSubscription(invalidations.stream);

  RemoteSavedItem _copySaved(
    RemoteSavedItem item, {
    required DateTime serverUpdatedAt,
  }) => RemoteSavedItem(
    id: item.id,
    userId: item.userId,
    title: item.title,
    summary: item.summary,
    category: item.category,
    subtype: item.subtype,
    intent: item.intent,
    status: item.status,
    favorite: item.favorite,
    capturedAt: item.capturedAt,
    eventAt: item.eventAt,
    expiresAt: item.expiresAt,
    snoozedUntil: item.snoozedUntil,
    location: item.location,
    entities: item.entities,
    availableActions: item.availableActions,
    cloudPreviewPath: item.cloudPreviewPath,
    imageHash: item.imageHash,
    analysisStatus: item.analysisStatus,
    analysisVersion: item.analysisVersion,
    confidence: item.confidence,
    clientUpdatedAt: item.clientUpdatedAt,
    serverUpdatedAt: serverUpdatedAt,
    sourceDeviceId: item.sourceDeviceId,
    createdAt: item.createdAt,
    deletedAt: item.deletedAt,
  );

  RemoteReminder _copyReminder(
    RemoteReminder item, {
    required DateTime serverUpdatedAt,
  }) => RemoteReminder(
    id: item.id,
    userId: item.userId,
    savedItemId: item.savedItemId,
    remindAt: item.remindAt,
    kind: item.kind,
    completedAt: item.completedAt,
    clientUpdatedAt: item.clientUpdatedAt,
    serverUpdatedAt: serverUpdatedAt,
    sourceDeviceId: item.sourceDeviceId,
    createdAt: item.createdAt,
    deletedAt: item.deletedAt,
  );
}

final class _FakeInvalidationSubscription
    implements RemoteInvalidationSubscription {
  _FakeInvalidationSubscription(this.invalidations);
  @override
  final Stream<void> invalidations;
  @override
  Future<void> dispose() async {}
}

final class FakeNetworkError implements Exception {
  const FakeNetworkError();
}
