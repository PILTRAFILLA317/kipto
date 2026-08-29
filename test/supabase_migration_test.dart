import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/20260829000100_phase_3_cloud_sync.sql',
  ).readAsStringSync();

  test('cloud migration enables owner-only RLS and least-privilege grants', () {
    for (final table in ['saved_items', 'reminders', 'devices']) {
      expect(
        migration,
        contains('alter table public.$table enable row level security;'),
      );
      expect(
        migration,
        contains('revoke all on table public.$table from anon'),
      );
      expect(migration, contains('(select auth.uid()) = user_id'));
    }
    expect(migration, isNot(contains('using (true)')));
    expect(migration, isNot(contains('to anon')));
  });

  test(
    'migration contains cursor, tombstone, LWW, and private broadcast pieces',
    () {
      expect(migration, contains('server_updated_at timestamptz'));
      expect(migration, contains('deleted_at timestamptz'));
      expect(
        migration,
        contains('new.client_updated_at < old.client_updated_at'),
      );
      expect(migration, contains('realtime.broadcast_changes'));
      expect(migration, contains("'user:' || owner_id::text || ':sync'"));
      expect(migration, contains('(select realtime.topic())'));
    },
  );

  test('device-only and binary fields are absent from cloud schema', () {
    expect(migration, isNot(contains('local_asset_id')));
    expect(migration, isNot(contains('original_available')));
    expect(migration, isNot(contains('preview_cache_path')));
    expect(migration, isNot(contains('bytea')));
  });
}
