# Kipto architecture — Life Admin foundation

## Boundary

Kipto is a Flutter application with a deliberately small neutral domain. This
phase preserves reusable infrastructure while removing the former product
surface. No input pipeline or Life Admin interpretation exists yet.

```text
Flutter UI
    ↓
Riverpod providers
    ↓
Repositories
    ↓
Drift / SQLite (source of truth)
    ↕
SyncService ↔ RemoteDataSource ↔ Supabase
```

## Local domain

`Item` has an ID, optional owner, title, summary, `active` / `resolved` /
`archived` status, lifecycle timestamps, and sync metadata. It intentionally
does not contain source, category, deadline, inferred facts, confidence, or AI
fields.

`Reminder` belongs to an `Item` and contains its UUID, owner, scheduled instant,
completion/tombstone timestamps, and sync metadata. Notification mappings are a
device-local projection and never synchronize.

The Drift v7 migration intentionally drops the previous pre-release product
data and recreates `items`, `reminders`, `sync_queue`, `cloud_sync_states`, and
`notification_mappings` deterministically. This makes upgrade from v6 work
without manual app deletion.

## Sync and accounts

Repository writes are transactional: they update Drift, mark the row dirty, and
append a sync-queue entry before network work. The foreground sync service
pushes Items before Reminders, then pulls both with a `server_updated_at`
cursor overlap. Conflicts use simple last-write-wins on `client_updated_at`.

Supabase owns authentication, the remote sync store, aggregate future-analysis
quota accounting, and authenticated Edge Functions. RLS checks
`(select auth.uid()) = user_id`; an anonymous Auth user uses the authenticated
database role and can only reach its own rows. Realtime only invalidates normal
pulls—it never writes local rows directly.

Anonymous libraries can be linked to Apple or Google without changing their
Supabase UUID. Restoring signs in to an existing library; it does not link or
merge identities. Permanent sign-out stops sync, clears device-local data and
notifications, then signs out. It does not delete cloud data.

## Device integrations

Reminders are reconciled into at most 50 timezone-aware local notifications.
The local mapping table allows repeatable cancellation and re-scheduling across
startup and resume. A small native Calendar adapter remains available for a
future explicit Add-to-Calendar flow, but no current UI invokes it.

## Deferred

Source ingestion, file storage, document parsing, Share Sheet support, Life
Admin analysis, final item views, actions, billing, and collaboration are
future phases. Storage has no application bucket in this phase.
