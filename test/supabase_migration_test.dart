import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/20260829000100_phase_3_cloud_sync.sql',
  ).readAsStringSync();
  final analysisMigration = File(
    'supabase/migrations/20260830000100_phase_5_ai_analysis.sql',
  ).readAsStringSync();
  final actionCompletionMigration = File(
    'supabase/migrations/20260830000200_phase_6_action_completion_merge.sql',
  ).readAsStringSync();
  final previewMigration = File(
    'supabase/migrations/20260830000300_phase_7_private_previews.sql',
  ).readAsStringSync();
  final supabaseConfig = File('supabase/config.toml').readAsStringSync();
  final analysisFunction = File(
    'supabase/functions/analyze-screenshot/index.ts',
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

  test('analysis usage is aggregate-only and unavailable to app roles', () {
    expect(analysisMigration, contains('analysis_usage_daily'));
    expect(analysisMigration, contains('request_count integer'));
    expect(analysisMigration, contains('input_tokens bigint'));
    expect(analysisMigration, contains('output_tokens bigint'));
    expect(
      analysisMigration,
      contains(
        'revoke all on table public.analysis_usage_daily from public, anon, authenticated;',
      ),
    );
    expect(analysisMigration, isNot(contains('image_base64')));
    expect(analysisMigration, isNot(contains('analysis_json')));
  });

  test('analysis quota reservation is atomic and server-controlled', () {
    expect(analysisMigration, contains('kipto_consume_analysis_quota'));
    expect(
      analysisMigration,
      contains('on conflict (user_id, usage_date) do update'),
    );
    expect(analysisMigration, contains('request_count < p_limit'));
    expect(analysisMigration, contains('to service_role;'));
    expect(analysisMigration, contains('from public, anon, authenticated;'));
  });

  test('analysis function keeps JWT verification and user authentication', () {
    expect(
      supabaseConfig,
      contains('[functions.analyze-screenshot]\nverify_jwt = true'),
    );
    expect(analysisFunction, contains("withSupabase({ auth: 'user' }"));
    expect(analysisFunction, isNot(contains("auth: 'none'")));
  });

  test('completed actions merge by action key and newest valid timestamp', () {
    expect(
      actionCompletionMigration,
      contains("old.entities_json -> '__kiptoCompletedActions'"),
    );
    expect(
      actionCompletionMigration,
      contains("new.entities_json -> '__kiptoCompletedActions'"),
    );
    expect(actionCompletionMigration, contains('jsonb_each_text(old_actions)'));
    expect(
      actionCompletionMigration,
      contains('old_completed > new_completed'),
    );
    expect(
      actionCompletionMigration,
      contains("('addCalendar', 'createReminder', 'save')"),
    );
    expect(
      actionCompletionMigration,
      contains('new.client_updated_at < old.client_updated_at'),
    );
    expect(
      actionCompletionMigration,
      contains('drop trigger if exists saved_items_set_server_updated_at'),
    );
    expect(
      actionCompletionMigration,
      contains('before update on public.saved_items'),
    );
  });

  test('notification projection stays out of the cloud schema', () {
    final cloudSchema =
        '$migration\n$analysisMigration\n$actionCompletionMigration';
    expect(cloudSchema, isNot(contains('notification_mappings')));
    expect(cloudSchema, isNot(contains('notification_id')));
    expect(cloudSchema, isNot(contains('notifications_enabled')));
  });

  test('preview bucket is private and paths are scoped to auth uid', () {
    expect(previewMigration, contains("'kipto-previews'"));
    expect(previewMigration, contains('public = false'));
    expect(previewMigration, contains("array['image/jpeg', 'image/webp']"));
    expect(RegExp(r'create policy').allMatches(previewMigration), hasLength(4));
    expect(
      previewMigration,
      contains("(storage.foldername(name))[1] = (select auth.uid())::text"),
    );
    expect(previewMigration, isNot(contains('using (true)')));
    expect(previewMigration, isNot(contains('create public')));
  });
}
