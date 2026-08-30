# Kipto architecture — Phase 5

## Purpose

Kipto is a screenshot inbox organized around intent. The user does not manage a
screenshot record and a separate metadata record: both are one `SavedItem`.
Phases 3–4 preserve read-only Photos/MediaStore access, anonymous Supabase
authentication, offline-first metadata synchronization, and the complete
product query/presentation layer. Phase 5 adds authenticated multimodal
analysis while preserving Drift as the application's only source of truth.
Cloud previews, notifications, Calendar, Maps, and billing still do not exist.

## Dependency flow

```text
Flutter presentation
        ↓
Riverpod providers
        ↓
Repository interfaces
        ↓
Drift repositories / DAOs
        ↓
SQLite (kipto.sqlite)

Drift ↔ SyncService ↔ RemoteDataSource ↔ Supabase
```

`PhotoLibraryRepository` is a parallel platform boundary consumed by the
application layer, never directly by widgets:

```text
Flutter presentation
        ↓
Riverpod controller
        ↓
ScreenshotImportService
        ↓                         ↓
PhotoLibraryRepository      ScreenshotItemsRepository
        ↓                         ↓
photo_manager               Drift / SQLite
```

AI follows its own bounded request path and rejoins the existing local-first
write path only after two independent runtime validations:

```text
local photo asset → AnalysisImagePreparationService
                  → ScreenshotAnalysisClient
                  → authenticated Edge Function
                  → OpenAI Responses API
                  → AnalysisResultMapper
                  → ApplyScreenshotAnalysis
                  → Drift transaction ↔ sync_queue
                  → existing SyncService
```

The Edge Function never writes a SavedItem. Its service-role client is scoped
to atomic quota reservation and aggregate usage recording only.

Presentation watches repository streams and renders `AsyncValue` loading,
error, empty, and data states. Widgets never issue Drift queries. Repository
interfaces are independent from Flutter and can be replaced in tests or wrapped
by a future synchronization layer.

The persistent database is opened by `drift_flutter` as `kipto.sqlite` in the
platform application documents directory. Native work runs through Drift's
background connection so normal database work does not block the UI isolate.
`AppDatabase` accepts a `QueryExecutor`, allowing tests to use
`NativeDatabase.memory()` and closes through Riverpod disposal in the app.

## SavedItem model

`SavedItem` is the central synchronized aggregate. Synchronizable fields are:

- `id`, `ownerId`, `title`, `summary`, `category`, `subtype`, `intent`,
  `status`, and `favorite`;
- `capturedAt`, `eventAt`, `expiresAt`, and `snoozedUntil`;
- `location`, `entities`, and `availableActions`;
- `cloudPreviewPath`, `imageHash`, `analysisStatus`, `analysisVersion`, and
  `confidence`;
- `createdAt`, `updatedAt`, and `deletedAt`.

Device-local fields are:

- `localAssetId`;
- `originalAvailable`;
- `previewCachePath`;
- `syncStatus`;
- `lastSyncedAt`.

These local fields describe device availability and synchronization state. A
future cloud row must not be treated as the source of truth for whether the
original screenshot is available on this particular device.

Flexible detected values are stored in the typed `entities` JSON map. Suggested
actions are a controlled `SavedItemActionType` list, also encoded as JSON. JSON
conversion is centralized, malformed JSON falls back safely, and unknown future
action values do not crash old clients. Categories, statuses, analysis states,
sync states, reminder kinds, queue entity types, and operations use explicit
enum converters with conservative fallbacks.

Phase 5 reserves `__kiptoAnalysis` inside `entities` for synchronized analysis
provenance: model, prompt version, analyzed time, title/category source,
recognized source app, relevance, uncertainty, keywords, and structured
location. Presentation excludes this key from detected entities. Using the
existing cloud-parity JSON boundary avoids duplicate Drift/Postgres columns,
while explicit `titleSource` and `categorySource` values protect user edits.

SQLite stores date/time values as ISO-8601 text with explicit offsets. Domain
writes normalize dates to UTC and UI formatting converts them to device-local
time.

## Drift schema v4

`saved_items` uses a string UUID primary key and indexes for `status`,
`category`, `captured_at`, `updated_at`, and `deleted_at`. It never stores image
BLOBs. A unique SQLite index on nullable `local_asset_id` prevents importing the
same device asset twice while still allowing cloud/demo items with no local ID.
The screenshot original remains outside SQLite.

`screenshot_import_states` contains one installation-local row. It persists
whether initial import completed, last scan/success/reconciliation timestamps,
last accessible screenshot count, selected import scope, and scanner version.
This avoids treating in-memory controller state as durable scanner state.

`reminders` uses a string UUID primary key and a foreign key to
`saved_items.id`. It persists local reminder intent only; Phase 1 does not
schedule operating-system notifications.

`sync_queue` records an entity type, entity UUID, create/update/delete
operation, creation time, attempts, last attempt, and last error. It has no
timer, worker, network client, or fake server. It is only the durable queue
primitive a future `SyncService` will consume.

`analysis_queue` is a separate, device-local table keyed by SavedItem ID. It
stores only `queued`, `processing`, `retryScheduled`, or `paused` plus priority,
attempts, retry/start/enqueue timestamps, and a controlled last error code. It
never stores image or base64 data. A foreign key cascades queue removal when its
SavedItem is removed locally.

`schemaVersion` is 4. The explicit v1 → v2 migration creates only the scanner
state table and unique local-asset index. Existing SavedItems, reminders,
favorites, statuses, and soft deletes are preserved. Foreign keys remain enabled
before opening.

The v2 → v3 migration adds `remoteServerUpdatedAt` to SavedItems,
`lastSyncedAt` and `remoteServerUpdatedAt` to reminders, plus the singleton
`cloud_sync_states` table. That table owns the random installation UUID,
authenticated owner, incremental server cursors, last attempt/success, and a
sanitized last error. Existing screenshots, asset IDs, reminders, and scanner
state survive the migration.

The v3 → v4 migration creates `analysis_queue` and its due-work index with
`CREATE ... IF NOT EXISTS`; it does not rewrite or delete SavedItems.
Interrupted `processing` rows return to `queued` when the runner initializes.

## Cloud synchronization

Startup initializes Supabase only when both dart-defines are valid, waits for
SDK session recovery, reuses or refreshes a recovered session, and creates an
anonymous user only when no recoverable identity exists. Pre-auth local data is
claimed transactionally; deterministic demo IDs are excluded.

Every synchronizable repository mutation writes Drift, marks the entity dirty,
and appends `sync_queue` in one transaction. Local changes debounce a best-effort
sync. Startup, resumed, manual retry, and private Realtime invalidations also
trigger the same service. Concurrent requests are serialized and may request
one follow-up pass.

Push coalesces queue rows by entity and sends final SavedItems before reminders
in batches of 100. Deletes are tombstones. Pull pages by
`server_updated_at` with a two-second overlap and preserves `localAssetId`,
`originalAvailable`, and `previewCachePath`. Conflicts use pragmatic
last-write-wins on `client_updated_at`; device clock skew is a known MVP
limitation. The conflict strategy is isolated behind remote models/mappers so
it can be replaced later.

Supabase contains `saved_items`, `reminders`, `devices`, and the private
`analysis_usage_daily` aggregate. RLS and grants
restrict every operation to `auth.uid() = user_id`; anonymous Auth users use the
authenticated Postgres role. Database triggers emit private
`user:<userId>:sync` Broadcast events. Payloads never mutate Drift directly:
they only invalidate and schedule the normal pull/merge path.

## Multimodal analysis

AI is explicit per-device opt-in and disabled by default. Historical items are
only enqueued after the user sees the count and chooses Analyze. New imports are
automatically enqueued after opt-in. The persistent runner is independent from
widgets, processes one item at a time in foreground, leaves the current request
alone when paused/backgrounded, and starts no subsequent request until resumed.
Retryable failures use at most three attempts, bounded backoff, and server
`Retry-After`; permanent or exhausted failures set the SavedItem to `failed`.

`PhotoManagerAnalysisImagePreparationService` requests aspect-fit JPEGs at
1280/1080/900 px widths, with a 4096 px maximum box for long captures and a 4 MB
client ceiling. It never calls Storage or persists a backend copy. The server
accepts JPEG, PNG, and WebP after request-size, base64, MIME, decoded-size, and
magic-byte checks.

The authenticated `analyze-screenshot` function calls only
`POST /v1/responses`. The model is `OPENAI_MODEL` or `gpt-5.6-luna`, reasoning
effort is `low`, `store=false`, image detail is high, and no tools are present.
A strict JSON Schema controls the 11 categories, 11 intents, 9 action values,
relevance, confidence, dates, location, entities, uncertainty, and keywords.
The function validates the decoded output again before returning only the
domain result and version/model metadata; Flutter validates it a third time.

`AnalysisAcceptancePolicy` filters action prerequisites and derives app state.
Confidence at or above 0.70 is `processed`; lower valid output is
`needsReview`, never a technical failure. `needsAction` requires both
`requiresAction` and at least one valid suggestion. Calendar/package suggestions
require 0.80 confidence. Archived, done, and snoozed status plus user-authored
title/category, notes, and existing reminders are never overwritten. No action
is executed automatically.

`ApplyScreenshotAnalysis` writes every SavedItem field, provenance, final
analysis status, sync status, sync operation, and queue removal in one SQLite
transaction. A trigger-induced test failure verifies rollback across all those
steps. Search sees title, summary, category, subtype, intent, entities, and
keywords through the existing local query.

Cost protection is server-owned. `analysis_usage_daily` stores daily aggregate
counts and token totals only. Authenticated/anonymous app roles have no grants
on the table or RPCs. The function's admin client uses service-role-only
security-definer RPCs to reserve `ANALYSIS_DAILY_LIMIT` atomically (default
2000) and record success/error/token aggregates. Logs contain safe identifiers
and metrics, never image/base64 or extracted content.

## Photo access and detection

`PhotoAccessStatus` translates `photo_manager` states into the domain:
`notDetermined`, `authorized`, `limited`, `denied`, and `restricted`. The system
dialog is only requested after the contextual Inbox CTA. Denied/restricted
states link to system settings. Limited is valid access and exposes platform
reselection through `presentLimited(type: RequestType.image)`.

On iOS, discovery asks PhotoKit for the native
`PHAssetCollectionSubtype.smartAlbumScreenshots` through `PMDarwinPathFilter`.
It never depends on the localized album title. On Android, the centralized
`ScreenshotDetectionStrategy` evaluates MediaStore bucket name and relative
path for common OEM locations and localized variants. If no screenshot bucket
is exposed, it falls back to a paginated all-images metadata scan using relative
path and display name. The fallback is deliberately metadata-only.

Android requests `READ_MEDIA_IMAGES`, Android 14 selected-photo access, and the
legacy read permission only through API 32. iOS declares only the photo-library
usage description (no add-only description). Neither platform requests video,
audio, media location, `MANAGE_MEDIA`, or write/delete access.

## Import and scanner

The import scopes are typed: recent 100 (default), assets captured in the last
30 days, and all accessible screenshots. `photo_manager` asset ranges are read
in 100-item pages. Drift performs batched inserts, preloads existing
`localAssetId` values per batch, and relies on the unique index as the final race
guard. Imported items use neutral metadata: title `Screenshot`, category
`other`, status `newItem`, no suggested actions, and
`analysisStatus=unprocessed` with analysis version 0.

The scanner runs at app initialization after permission inspection, on resumed,
after debounced foreground photo-library changes, and on manual refresh. It
checks a recent overlap window on every incremental scan. If the accessible
count changes in a way those candidates do not explain—for example, limited
access reveals an older asset—it falls back to a paginated metadata scan. A
single busy guard prevents concurrent import/scan/reconcile operations.

Reconciliation resolves local IDs without reading image bytes. Missing assets
set `originalAvailable=false`; the SavedItem is never deleted. If access returns
for the same ID, it becomes true again. Full availability reconciliation is
forced for manual/library-selection changes and otherwise rate-limited by the
persisted reconciliation timestamp.

Cards and Detail resolve sized thumbnail bytes lazily through the repository.
The scan never loads originals, decodes full images, generates manual previews,
or hashes image content. The larger Detail request uses PhotoKit aspect-fit
thumbnail options and never calls `originFile`.

## Repository behavior

`SavedItemsRepository` exposes active streams, category streams, item detail,
local search, create/update, status changes, favorite, done, archive, snooze,
restore, and soft delete. Mutations update `updatedAt`. Normal streams omit
soft-deleted rows; Inbox also omits done and archived rows. Inbox ordering gives
needs-action items priority, then near expiry, then recent capture time.

Search uses a debounced repository contract and SQL filtering over active rows.
It covers title, summary, subtype, intent, category, and JSON entity text. The
UI contract can later switch to an FTS5 DAO without changing screens.

Inbox candidates are bounded at the DAO and assigned once by the testable
`InboxPolicy`. Priority is needs-action/expired, future expiry within seven
days, upcoming events or snooze, unprocessed, then recent. Library filters and
sorting are represented by immutable `LibraryQuery` values and applied by the
DAO rather than rebuilt from `watchAll()` in widgets. Category/unprocessed
counts are exposed as their own stream.

`SavedItemImage` is the only image component used by SavedItem cards and
Detail. It currently resolves local PhotoManager thumbnails or a first-class
placeholder, and owns fullscreen zoom. It is intentionally ready for a later
cached/remote preview source without changing feature screens.

User notes use the reserved `SavedItem.userNoteEntityKey` inside the existing
synchronized `entities` map. The domain exposes `userNote` separately and
removes it from `detectedEntities`, so presentation never confuses user-authored
content with detected metadata. Because `entities_json` already participates in
local-first writes and cloud mapping, notes require no schema change.

`RemindersRepository` supports per-item watches, creation, completion, soft
delete, and future pending reminders. `SyncQueueRepository` supports enqueue,
pending lists/streams, completion/removal, and attempt/error recording.

## Development data

`DevelopmentSeed` uses deterministic UUIDs and existence checks, so repeated
debug launches do not duplicate records. Dates are relative to the current
injected clock. The seed covers events, places, coupons, products, orders,
recipes, conversations, memes, media, generic information, all main statuses,
favorites, expiry/event/snooze dates, actions, and a reminder. It is guarded by
`kDebugMode`.

## Architectural invariants

1. Screenshot + metadata = one SavedItem for the user.
2. The UI never accesses a cloud database directly.
3. Drift is the database consumed by the UI.
4. A screenshot original is never stored as a BLOB.
5. Synchronizable IDs are UUID strings.
6. Deletes are soft-delete by default.
7. Categories and actions are controlled enums.
8. External integrations live outside presentation.
9. Cloud sync lives behind repositories and a sync layer.
10. A SavedItem can exist when the screenshot original is unavailable locally.
11. Photo access is read-only.
12. Gallery scans operate on metadata, not full image bytes.
13. `localAssetId` is device-local and is never assumed portable.
14. A missing original asset never deletes its SavedItem.
15. Imported screenshots remain `analysisStatus=unprocessed` until validated
    analysis is applied.
16. The UI never reads directly from Supabase.
17. Every synchronized write happens locally first.
18. Supabase never receives `localAssetId` or other device-local fields.
19. Screenshot bytes are never written to Supabase Postgres or Storage.
20. Normal deletes are synchronized tombstones.
21. Anonymous and permanent users share the same ownership model.
22. Realtime invalidates; its payload is never a second source of truth.
23. Sync failures never prevent local usage.
24. A cloud SavedItem can exist without a local image.
25. Demo seed data is never uploaded.
26. Inbox is organized by action/state, not primarily by category.
27. Categories belong mainly to Library.
28. Unprocessed screenshots never receive invented metadata.
29. User edits are always local-first.
30. SavedItem UI must work without its screenshot.
31. Image rendering is abstracted from PhotoManager.
32. Snooze and Reminder are separate concepts.
33. No external action is reported as completed unless it actually ran.
34. All user-visible status labels derive from controlled domain enums.
35. Product UI remains usable offline.
36. OpenAI is never called directly from Flutter.
37. Screenshot images are not persisted by Kipto's backend during analysis.
38. AI output must pass Structured Output and client-side validation.
39. AI proposes actions; it never executes them.
40. AI never directly chooses destructive actions.
41. SavedItem lifecycle status is derived by application policy, not blindly
    copied from AI.
42. User-edited metadata always takes precedence over later AI analysis.
43. Analysis transient state is local and does not define the cloud source of
    truth.
44. `analysis_queue` is persistent and independent from `sync_queue`.
45. Technical failure and semantic uncertainty are different states.
46. A low-confidence result becomes `needsReview`, not `failed`.
47. Existing archived, done, or snoozed user state is not overwritten by
    analysis.
48. Enabling AI analysis is explicit per device.
49. Bulk analysis is sequential and bounded, never unbounded concurrency.
50. AI usage limits are enforced server-side.

## Not implemented in Phase 5

There is no OCR pre-pass, image upload/download or cloud preview generation,
permanent login UI, background/closed-app analysis, notifications, Calendar,
Maps, tracking integration, WebView, RevenueCat, embeddings, or OpenAI Batch
path. Available external actions are display-only and labeled accordingly.
Gallery observation, sync triggers, and analysis are foreground-only; no
WorkManager, BGTaskScheduler, Android foreground service, or closed-app polling
is used.
