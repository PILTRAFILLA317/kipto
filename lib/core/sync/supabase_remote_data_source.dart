import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/item_action.dart';

import 'dart:async';

import 'package:kipto/core/domain/models/source.dart';

import 'package:kipto/core/sync/remote_data_source.dart';
import 'package:kipto/core/sync/remote_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseRemoteDataSource implements KiptoRemoteDataSource {
  SupabaseRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<RemoteItem>> upsertItems(List<RemoteItem> items) async {
    if (items.isEmpty) return const [];
    final rows = await _client
        .from('items')
        .upsert(items.map((item) => item.toJson()).toList())
        .select();
    return rows.map(RemoteItem.fromJson).toList(growable: false);
  }

  @override
  Future<List<RemoteItem>> fetchItemsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    var query = _client.from('items').select();
    if (cursor != null) {
      query = query.gte(
        'server_updated_at',
        cursor.subtract(const Duration(seconds: 2)).toIso8601String(),
      );
    }
    final rows = await query
        .order('server_updated_at')
        .order('id')
        .range(offset, offset + limit - 1);
    return rows.map(RemoteItem.fromJson).toList(growable: false);
  }

  @override
  Future<List<RemoteReminder>> upsertReminders(
    List<RemoteReminder> reminders,
  ) async {
    if (reminders.isEmpty) return const [];
    final rows = await _client
        .from('reminders')
        .upsert(reminders.map((reminder) => reminder.toJson()).toList())
        .select();
    return rows.map(RemoteReminder.fromJson).toList(growable: false);
  }

  @override
  Future<List<RemoteReminder>> fetchRemindersChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    var query = _client.from('reminders').select();
    if (cursor != null) {
      query = query.gte(
        'server_updated_at',
        cursor.subtract(const Duration(seconds: 2)).toIso8601String(),
      );
    }
    final rows = await query
        .order('server_updated_at')
        .order('id')
        .range(offset, offset + limit - 1);
    return rows.map(RemoteReminder.fromJson).toList(growable: false);
  }

  @override
  Future<List<Source>> upsertSources(List<Source> sources) async {
    if (sources.isEmpty) return [];
    final rows = await _client
        .from('sources')
        .upsert(sources.map((s) => s.toJson()).toList())
        .select();
    return rows.map(Source.fromJson).toList();
  }

  @override
  Future<List<Source>> fetchSourcesChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    var query = _client.from('sources').select();
    if (cursor != null) {
      query = query.gte(
        'server_updated_at',
        cursor.subtract(const Duration(seconds: 2)).toIso8601String(),
      );
    }
    final rows = await query
        .order('server_updated_at')
        .order('id')
        .range(offset, offset + limit - 1);
    return rows.map(Source.fromJson).toList();
  }

  @override
  Future<List<Fact>> upsertFacts(List<Fact> rows) async {
    if (rows.isEmpty) return [];
    final returned = await _client
        .from('facts')
        .upsert(rows.map((r) => r.toJson()).toList())
        .select();
    return returned.map(Fact.fromJson).toList();
  }

  @override
  Future<List<Fact>> fetchFactsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    var query = _client.from('facts').select();
    if (cursor != null) {
      query = query.gte(
        'server_updated_at',
        cursor.subtract(const Duration(seconds: 2)).toIso8601String(),
      );
    }
    final rows = await query
        .order('server_updated_at')
        .order('id')
        .range(offset, offset + limit - 1);
    return rows.map(Fact.fromJson).toList();
  }

  @override
  Future<List<ItemAction>> upsertActions(List<ItemAction> rows) async {
    if (rows.isEmpty) return [];
    final returned = await _client
        .from('item_actions')
        .upsert(rows.map((r) => r.toJson()).toList())
        .select();
    return returned.map(ItemAction.fromJson).toList();
  }

  @override
  Future<List<ItemAction>> fetchActionsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) async {
    var query = _client.from('item_actions').select();
    if (cursor != null) {
      query = query.gte(
        'server_updated_at',
        cursor.subtract(const Duration(seconds: 2)).toIso8601String(),
      );
    }
    final rows = await query
        .order('server_updated_at')
        .order('id')
        .range(offset, offset + limit - 1);
    return rows.map(ItemAction.fromJson).toList();
  }

  @override
  Future<void> upsertDevice(RemoteDevice device) =>
      _client.from('devices').upsert(device.toJson());

  @override
  Future<RemoteInvalidationSubscription> subscribeToInvalidations(
    String userId,
  ) async {
    final controller = StreamController<void>.broadcast();
    final channel = _client.channel(
      'user:$userId:sync',
      opts: const RealtimeChannelConfig(private: true),
    )..onBroadcast(event: 'sync', callback: (_) => controller.add(null));
    channel.subscribe();
    return _SupabaseInvalidationSubscription(_client, channel, controller);
  }
}

final class _SupabaseInvalidationSubscription
    implements RemoteInvalidationSubscription {
  const _SupabaseInvalidationSubscription(
    this._client,
    this._channel,
    this._controller,
  );
  final SupabaseClient _client;
  final RealtimeChannel _channel;
  final StreamController<void> _controller;
  @override
  Stream<void> get invalidations => _controller.stream;
  @override
  Future<void> dispose() async {
    await _client.removeChannel(_channel);
    await _controller.close();
  }
}
