# Kipto architecture — Phase 2

## Purpose

Kipto is a screenshot inbox organized around intent. The user does not manage a
screenshot record and a separate metadata record: both are one `SavedItem`.
Phase 2 remains deliberately local-only and adds read-only Photos/MediaStore
access behind a repository boundary. Supabase sync, cloud previews, multimodal
analysis, notifications, Calendar, Maps, and billing still do not exist.

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

Future: Drift ↔ SyncService ↔ Supabase
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

SQLite stores date/time values as ISO-8601 text with explicit offsets. Domain
writes normalize dates to UTC and UI formatting converts them to device-local
time.

## Drift schema v2

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

`schemaVersion` is 2. The explicit v1 → v2 migration creates only the scanner
state table and unique local-asset index. Existing SavedItems, reminders,
favorites, statuses, and soft deletes are preserved. Foreign keys remain enabled
before opening.

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

Phase 1 search intentionally uses a repository-level local text scan over
active SQLite rows. It covers title, summary, subtype, intent, category, and
JSON entity text. The UI contract can later switch to an FTS5 DAO without
changing screens.

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
9. Cloud sync will be added behind repositories and a sync layer.
10. A SavedItem can exist when the screenshot original is unavailable locally.
11. Photo access is read-only.
12. Gallery scans operate on metadata, not full image bytes.
13. `localAssetId` is device-local and is never assumed portable.
14. A missing original asset never deletes its SavedItem.
15. Imported screenshots remain `analysisStatus=unprocessed` until a later AI
    phase exists.

## Not implemented in Phase 1

There is no Supabase client, authentication, AI/OCR, file upload/download,
networking, cloud preview generation, background processing, notifications,
Calendar, Maps, tracking, WebView, RevenueCat, embeddings, or backend. Available
external actions are display-only and labeled accordingly. Gallery observation
is foreground-only; no WorkManager, BGTaskScheduler, service, or closed-app
polling is used.

## Next phase

Cloud synchronization can be added later as `Drift ↔ SyncService ↔ Supabase`,
preserving Drift as the state read by presentation. This phase does not advance
into that work.
