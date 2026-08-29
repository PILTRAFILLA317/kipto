# Kipto architecture — Phase 1

## Purpose

Kipto is a screenshot inbox organized around intent. The user does not manage a
screenshot record and a separate metadata record: both are one `SavedItem`.
Phase 1 is deliberately local-only and prepares the data boundary for future
Photos/MediaStore access, Supabase sync, compressed previews, multimodal
analysis, notifications, Calendar, Maps, and billing without pretending those
integrations exist today.

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

## Drift schema v1

`saved_items` uses a string UUID primary key and indexes for `status`,
`category`, `captured_at`, `updated_at`, and `deleted_at`. It never stores image
BLOBs. The screenshot original remains outside SQLite.

`reminders` uses a string UUID primary key and a foreign key to
`saved_items.id`. It persists local reminder intent only; Phase 1 does not
schedule operating-system notifications.

`sync_queue` records an entity type, entity UUID, create/update/delete
operation, creation time, attempts, last attempt, and last error. It has no
timer, worker, network client, or fake server. It is only the durable queue
primitive a future `SyncService` will consume.

`schemaVersion` is 1. `MigrationStrategy` creates the initial schema, enables
foreign keys before opening, and contains the conventional upgrade boundary for
explicit sequential migrations when the version increases.

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

## Not implemented in Phase 1

There is no Supabase client, authentication, AI/OCR, gallery access or
permissions, file upload/download, networking, background processing,
notifications, Calendar, Maps, tracking, WebView, RevenueCat, embeddings, or
backend. Available external actions are display-only and labeled accordingly.

## Next phase

The next phase can add device screenshot discovery behind a platform/media
boundary and write discovered items into Drift. Cloud synchronization should be
added later as `Drift ↔ SyncService ↔ Supabase`, preserving Drift as the state
read by presentation.
