import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/item_action.dart';

import 'dart:async';

import 'package:kipto/core/domain/models/source.dart';

import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/sync/remote_data_source.dart';
import 'package:kipto/core/sync/remote_models.dart';

const testUser = KiptoUser(id: 'user-a', isAnonymous: true);

final class TestAuthRepository implements AuthRepository {
  TestAuthRepository([KiptoUser? user]) : _user = user ?? testUser;

  KiptoUser? _user;
  bool failSignOut = false;

  @override
  KiptoUser? get currentUser => _user;
  @override
  KiptoSession? get currentSession =>
      _user == null ? null : KiptoSession(user: _user!, isExpired: false);
  @override
  bool get isAnonymous => _user?.isAnonymous ?? false;
  @override
  String? get userId => _user?.id;
  @override
  Stream<KiptoAuthState> watchAuthState() => Stream.value(
    KiptoAuthState(
      _user == null ? KiptoAuthStatus.signedOut : KiptoAuthStatus.anonymous,
      userId: _user?.id,
    ),
  );
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
  Future<void> signOut() async {
    if (failSignOut) throw StateError('Synthetic logout failure');
    _user = null;
  }
}

class FakeRemoteDataSource implements KiptoRemoteDataSource {
  final Map<String, Source> sources = {};
  @override
  Future<List<Source>> upsertSources(List<Source> rows) async {
    calls.add('sources');
    for (final row in rows) {
      sources[row.id] = Source.fromJson({
        ...row.toJson(),
        'server_updated_at': _nextServerTime().toIso8601String(),
      });
    }
    return rows.map((r) => sources[r.id]!).toList();
  }

  @override
  Future<List<Source>> fetchSourcesChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async => sources.values
      .where((s) => cursor == null || !s.serverUpdatedAt!.isBefore(cursor))
      .skip(offset)
      .take(limit)
      .toList();
  final Map<String, RemoteItem> items = {};
  final Map<String, RemoteReminder> reminders = {};
  final List<RemoteDevice> devices = [];
  final List<String> calls = [];
  DateTime _serverTime = DateTime.utc(2030, 1, 1);

  DateTime _nextServerTime() =>
      _serverTime = _serverTime.add(const Duration(seconds: 1));

  @override
  Future<List<RemoteItem>> upsertItems(List<RemoteItem> rows) async {
    calls.add('items');
    return [for (final row in rows) _upsertItem(row)];
  }

  RemoteItem _upsertItem(RemoteItem row) {
    final current = items[row.id];
    if (current != null &&
        current.clientUpdatedAt.isAfter(row.clientUpdatedAt)) {
      return current;
    }
    final stored = RemoteItem(
      id: row.id,
      userId: row.userId,
      title: row.title,
      summary: row.summary,
      status: row.status,
      createdAt: row.createdAt,
      clientUpdatedAt: row.clientUpdatedAt,
      serverUpdatedAt: _nextServerTime(),
      resolvedAt: row.resolvedAt,
      deletedAt: row.deletedAt,
      sourceDeviceId: row.sourceDeviceId,
    );
    items[row.id] = stored;
    return stored;
  }

  @override
  Future<List<RemoteItem>> fetchItemsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async =>
      _page(items.values, cursor, offset, limit, (row) => row.serverUpdatedAt);

  @override
  Future<List<RemoteReminder>> upsertReminders(
    List<RemoteReminder> rows,
  ) async {
    calls.add('reminders');
    return [for (final row in rows) _upsertReminder(row)];
  }

  RemoteReminder _upsertReminder(RemoteReminder row) {
    if (!items.containsKey(row.itemId)) {
      throw StateError('A reminder cannot arrive before its item');
    }
    final current = reminders[row.id];
    if (current != null &&
        current.clientUpdatedAt.isAfter(row.clientUpdatedAt)) {
      return current;
    }
    final stored = RemoteReminder(
      id: row.id,
      userId: row.userId,
      itemId: row.itemId,
      actionId: row.actionId,
      title: row.title,
      timeZone: row.timeZone,
      remindAt: row.remindAt,
      createdAt: row.createdAt,
      clientUpdatedAt: row.clientUpdatedAt,
      serverUpdatedAt: _nextServerTime(),
      completedAt: row.completedAt,
      deletedAt: row.deletedAt,
      sourceDeviceId: row.sourceDeviceId,
    );
    reminders[row.id] = stored;
    return stored;
  }

  @override
  Future<List<RemoteReminder>> fetchRemindersChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async => _page(
    reminders.values,
    cursor,
    offset,
    limit,
    (row) => row.serverUpdatedAt,
  );

  List<T> _page<T>(
    Iterable<T> rows,
    DateTime? cursor,
    int offset,
    int limit,
    DateTime Function(T row) updatedAt,
  ) {
    final lowerBound = cursor?.subtract(const Duration(seconds: 2));
    final sorted =
        rows
            .where(
              (row) =>
                  lowerBound == null || !updatedAt(row).isBefore(lowerBound),
            )
            .toList()
          ..sort((left, right) => updatedAt(left).compareTo(updatedAt(right)));
    return sorted.skip(offset).take(limit).toList(growable: false);
  }

  final Map<String, Fact> facts = {};
  @override
  Future<List<Fact>> upsertFacts(List<Fact> rows) async {
    calls.add('facts');
    for (final row in rows) {
      facts[row.id] = Fact.fromJson({
        ...row.toJson(),
        'server_updated_at': _nextServerTime().toIso8601String(),
      });
    }
    return rows.map((r) => facts[r.id]!).toList();
  }

  @override
  Future<List<Fact>> fetchFactsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async => facts.values
      .where((r) => cursor == null || !r.serverUpdatedAt!.isBefore(cursor))
      .skip(offset)
      .take(limit)
      .toList();
  final Map<String, ItemAction> actions = {};
  @override
  Future<List<ItemAction>> upsertActions(List<ItemAction> rows) async {
    calls.add('item_actions');
    for (final row in rows) {
      actions[row.id] = ItemAction.fromJson({
        ...row.toJson(),
        'server_updated_at': _nextServerTime().toIso8601String(),
      });
    }
    return rows.map((r) => actions[r.id]!).toList();
  }

  @override
  Future<List<ItemAction>> fetchActionsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async => actions.values
      .where((r) => cursor == null || !r.serverUpdatedAt!.isBefore(cursor))
      .skip(offset)
      .take(limit)
      .toList();

  @override
  Future<void> upsertDevice(RemoteDevice device) async {
    devices.removeWhere((existing) => existing.id == device.id);
    devices.add(device);
  }

  @override
  Future<RemoteInvalidationSubscription> subscribeToInvalidations(
    String userId,
  ) async => const _EmptyInvalidations();
}

final class _EmptyInvalidations implements RemoteInvalidationSubscription {
  const _EmptyInvalidations();

  @override
  Stream<void> get invalidations => const Stream.empty();
  @override
  Future<void> dispose() async {}
}
