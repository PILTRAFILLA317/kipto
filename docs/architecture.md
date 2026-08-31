# Kipto architecture — Phase 7

## Purpose

Kipto is a screenshot inbox organized around intent. The user does not manage a
screenshot record and a separate metadata record: both are one `SavedItem`.
Phases 3–4 preserve read-only Photos/MediaStore access, anonymous Supabase
authentication, offline-first metadata synchronization, and the complete
product query/presentation layer. Phase 5 adds authenticated multimodal
analysis while preserving Drift as the application's only source of truth.
Phase 6 adds explicit device actions and a local-notification projection for
synchronized reminders. Phase 7 adds private optimized previews, recoverable
Apple/Google identities, safe logout, and multi-device restoration. Push
notifications, background daemons, original-image backup, and billing still do
not exist.

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

Actions cross a separate application boundary. Presentation coordinates only
user input and feedback; it never calls a platform integration directly:

```text
Card / Detail action
        ↓
SavedItemActionFlow (confirmation or data edit)
        ↓
SavedItemActionExecutor (revalidation + typed result)
        ↓
Calendar / Maps / URL / Search / Clipboard / Tracking service
        or ReminderActionService / SavedItemsRepository
        ↓
native system UI or local-first Drift write
```

Reminder notifications are deliberately one-way projections of local Drift
state, not another domain store:

```text
reminders + saved_items (source of truth)
        ↓
ReminderNotificationScheduler.reconcile()
        ↓
notification_mappings (device-local identity projection)
        ↓
flutter_local_notifications → operating system
```

Presentation watches repository streams and renders `AsyncValue` loading,
error, empty, and data states. Widgets never issue Drift queries. Repository
interfaces are independent from Flutter and can be replaced in tests; local
writes are synchronized by the existing service behind those boundaries.

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

Phase 6 similarly reserves `__kiptoCompletedActions` for the small subset of
actions whose completion is meaningful: Add to Calendar, Create Reminder, and
Save. Values are UTC ISO-8601 timestamps keyed by controlled action storage
value. Presentation excludes the map from detected information. Opening Maps,
a browser, or tracking is intentionally not persisted as task completion.

SQLite stores date/time values as ISO-8601 text with explicit offsets. Domain
writes normalize dates to UTC and UI formatting converts them to device-local
time.

## Drift schema v6

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
`saved_items.id`. It is synchronized domain state and the only source of truth
for reminder intent, including scheduled time, completion, and soft deletion.

`sync_queue` records an entity type, entity UUID, create/update/delete
operation, creation time, attempts, last attempt, and last error. It has no
timer or network client of its own. It is the durable primitive consumed by the
existing foreground `SyncService`.

`analysis_queue` is a separate, device-local table keyed by SavedItem ID. It
stores only `queued`, `processing`, `retryScheduled`, or `paused` plus priority,
attempts, retry/start/enqueue timestamps, and a controlled last error code. It
never stores image or base64 data. A foreign key cascades queue removal when its
SavedItem is removed locally.

`notification_mappings` is device-local and maps a reminder UUID to a unique
integer notification ID, the scheduled UTC instant, and the IANA timezone used
to program it. The foreign key cascades when a reminder is physically removed.
The table is rebuildable from active reminder rows and is never synchronized.

`schemaVersion` is 6. The explicit v1 → v2 migration creates only the scanner
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

The v4 → v5 migration creates `notification_mappings` and its unique integer-ID
index with `CREATE ... IF NOT EXISTS`. Existing SavedItems, reminders, analysis
work, sync state, local asset links, and tombstones are not rewritten or
deleted.

The v5 → v6 migration creates `preview_transfer_jobs`. It is a file-specific,
device-local queue keyed by SavedItem ID with upload/delete operation, bounded
retry state, attempt count, next attempt, safe error code, and creation time.
It stores no bytes. Its foreign key cascades only on physical SavedItem removal;
normal tombstones remain available long enough to complete Storage cleanup.

## Cloud previews

Cloud previews and metadata have separate failure domains:

```text
Photos original → on-device aspect-fit JPEG → preview_transfer_jobs
                                          → private Supabase Storage
                                          → Drift.cloudPreviewPath
                                          → sync_queue → Postgres
```

The generator uses `photo_manager` directly, requests JPEG at quality 80 and a
maximum 900 px width, preserves aspect ratio, caps height at 8000 px and total
pixels at 8 million, and retries exceptional files at quality 68. It never
loads a preview during a gallery scan and never overwrites or uploads the
original. `cloudPreviewVersion` is 1 and the deterministic object path is
`{currentAuthUser}/{savedItemId}/preview-v1.jpg`.

The `kipto-previews` bucket is private. Four Storage policies scope SELECT,
INSERT, UPDATE, and DELETE to objects whose first path segment is the current
`auth.uid()`. `cloudPreviewPath` contains only that object path. Storage uploads
use upsert, while Drift remains the SavedItem source of truth. A successful
upload followed by a failed local write is reconciled by retrying the same path,
so it cannot create duplicate objects.

Foreground processing uses at most two concurrent uploads. Retryable failures
stop after three attempts until explicit retry; missing originals stop without
an infinite loop. Deletes are queued only after the SavedItem tombstone commits,
and bulk removal uses Storage batches of at most 100 paths.

Downloaded previews are validated as non-empty bounded JPEG/WebP files, written
under application support, named from SavedItem ID plus a stable object-path
hash, and evicted oldest-accessed-first above 200 MB. Requests are deduplicated
per path and limited to three concurrent downloads. `SavedItemImage` prioritizes
the local Photos thumbnail, then cached/downloaded cloud preview, then a
placeholder. The cache remains useful offline and is never written to Photos.

## Recoverable accounts and restore

First-run routing waits for Supabase's session recovery without creating a user.
With no session, the welcome screen offers restore via Apple/Google or **Get
started**, which then creates the anonymous identity. Existing anonymous
sessions bypass welcome unchanged.

Protecting a library calls OAuth `linkIdentity` on the current Supabase user and
checks that the UUID is unchanged. Restoring calls `signInWithOAuth` with no
disposable anonymous session. The PKCE callbacks are
`com.example.kipto://auth/callback?flow=protect` and
`com.example.kipto://auth/callback?flow=restore`; the flow marker returns a
completed link to Settings and a completed restore to Inbox. Callback errors
render a safe in-app message and do not switch identities. The placeholder
identifier must be replaced consistently before production. Manual Linking and
provider credentials are external Supabase/Apple/Google configuration. No
provider secret ships in the app.

A new-device permanent session runs the existing initial pull, restores
SavedItems and reminders into Drift, and reconciles notifications using the
device's local permission. Cloud-only SavedItems have `localAssetId=null` and
`originalAvailable=false`; their previews download only when visible. AI opt-in,
Photos permission, notification permission, and appearance do not restore.

Confirmed permanent sign-out stops realtime/sync, analysis, and preview work;
cancels managed local notifications; clears downloaded previews and all
account-scoped Drift rows; signs out; then returns to welcome. Cloud content and
Photos are untouched. Anonymous sign-out is blocked, and libraries are never
silently merged or switched in-place.

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

Completed actions are the one field with a key-wise merge layered over that
row-level policy. On pull, the mapper unions local and remote controlled action
keys and keeps the newest valid timestamp. Before a cloud update, the Phase 6
Postgres trigger performs the same merge against the stored row. This prevents
two devices that complete different actions offline from erasing each other's
map entries while preserving the existing remote model and `entities_json`
column.

Supabase contains `saved_items`, `reminders`, `devices`, and the private
`analysis_usage_daily` aggregate. RLS and grants
restrict every operation to `auth.uid() = user_id`; anonymous Auth users use the
authenticated Postgres role. Database triggers emit private
`user:<userId>:sync` Broadcast events. Payloads never mutate Drift directly:
they only invalidate and schedule the normal pull/merge path.

Supabase does not contain notification IDs, notification mappings, scheduled
projection metadata, or an authoritative notification-permission flag. A
reminder pulled from another device is written to Drift and then causes local
reconciliation on the receiving device.

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

## Device action execution

`SavedItemActionType` remains the controlled vocabulary. Presentation metadata
centralizes labels, icons, accessibility descriptions, completion labels, and
confirmation requirements. A category-aware policy chooses one primary action
and stable secondary ordering without inventing actions absent from the item.
Cards and Detail use the same policy.

`SavedItemActionFlow` collects only the user input an action needs: editable
Calendar draft, reminder preset/custom time, duplicate Calendar confirmation,
or code selection. `SavedItemActionExecutor` then revalidates the current
request and returns `ActionExecutionResult`; exceptions are converted into safe
typed failures. Debug logging contains SavedItem ID, controlled action type,
duration, and safe error code only—never URLs, copied codes, location text, or
notification content.

No action runs automatically after AI analysis, sync, import, notification
delivery, or background lifecycle changes. Integrations may launch offline when
the operating system supports them. Network-dependent external destinations can
fail honestly without rolling back existing local SavedItem state.

### Calendar

`CalendarEventDraftBuilder` derives title, start, one-hour default end,
all-day state, location, notes, and an optional validated URL. Missing event
dates require explicit manual entry. The user can edit date, time, all-day,
duration, location, and title before the platform editor opens.

iOS uses the narrow `app.kipto/calendar` platform channel and
`EKEventEditViewController`. On iOS 17+ the system editor is presented without
requesting full calendar access. The iOS 15–16 path requests the legacy EventKit
event access only after the user starts the action. The adapter reports saved,
cancelled, permission denied, or unavailable, so only a confirmed save records
the Calendar completion.

Android sends `ACTION_INSERT` to `CalendarContract.Events` with the draft as
extras. It neither reads calendars nor writes the provider directly, so the
manifest contains no `READ_CALENDAR` or `WRITE_CALENDAR`. Calendar apps do not
standardize a saved/cancelled activity result for this intent; Android therefore
reports only that the editor launched and does not persist a false completion.

Kipto cannot read Calendar to deduplicate events. A persisted Calendar
completion changes the CTA to its completed label; repeating it requires an
explicit warning and consent. Completing Calendar never changes SavedItem
status to Done.

### Maps, browser, tracking, clipboard, and Save

`MapsQueryBuilder` prefers structured place/address values, then the SavedItem
location. iOS launches Apple
Maps HTTPS, Android launches `geo:0,0?q=...`, and both fall back to a Google
Maps HTTPS search. Query parameters use `Uri` encoding. There is no Google Maps
SDK, API key, embedded map, or location permission.

`SafeUriPolicy` permits only HTTP(S) with a non-empty host and empty userinfo.
It rejects whitespace, overlong input, malformed values, credential-bearing
URLs, and dangerous schemes such as `javascript:`, `data:`, and `file:`. The
only normalization is a trimmed `www.` value promoted to HTTPS. Browser/search
actions always use an external application.

Search composes a de-duplicated, length-bounded query from controlled SavedItem
context. Tracking tries a validated explicit URL first, then an encoded carrier
plus tracking-code search, then a tracking-code-only search. Copy Code exposes
only controlled coupon, tracking, or order-number entity keys and lets the user
choose when multiple values exist. Save sets Favorite on the same SavedItem and
records its completion in one synchronized local transaction; it never creates
another SavedItem.

Opening Maps, a URL, search, or tracking means the system accepted the launch.
It does not mean the destination loaded or the user's real-world task finished,
so those actions never enter `__kiptoCompletedActions`.

## Reminder notification projection

`ReminderActionService` persists a future reminder before interacting with the
notification system, then records the Create Reminder completion. Suggested
times include later today, tomorrow, weekend, next week, before expiry, before
event, and a custom date/time picker. Edit changes the same row; completion and
deletion respectively set domain completion and the existing soft-delete
tombstone. Snooze remains an independent SavedItem workflow field and never
implicitly creates a notification.

Notification permission is requested only after explicit user intent: creating
the first reminder or pressing Enable in Settings. Initialization merely reads
the real platform state. A denial does not roll back the reminder; UI explains
that notifications are disabled and links to app notification settings. The
small SharedPreferences marker only distinguishes never-requested from denied;
the OS result remains authoritative.

`FlutterReminderNotificationGateway` initializes
`flutter_local_notifications` without prompting, creates the default-importance
Android `kipto_reminders` channel, and schedules with minimal title/body and an
ID-only payload. Android declares `POST_NOTIFICATIONS`, boot reception, the
scheduled notification receiver, and boot/package-replacement receiver. It does
not declare exact-alarm or full-screen-intent permissions. Scheduling uses
`inexactAllowWhileIdle`; platform power management may introduce delivery
margin. Already scheduled notifications need no network connection to fire.

`DeviceTimeZoneService` initializes the IANA timezone database, asks
`flutter_timezone` for the current identifier, and falls back conservatively to
UTC. Reminder instants remain UTC domain values; `zonedSchedule` receives the
equivalent local `TZDateTime`. A changed timezone invalidates the stored mapping
and reprograms the same instant for the new zone.

Reconciliation is serialized, repeatable, and idempotent. It runs during
notification initialization, app resume, explicit permission changes, every
reminder create/edit/complete/delete, SavedItem soft deletion, and after sync
pulls reminders. It reads the next 50 pending future reminders, keeps matching
mappings, cancels stale/expired/out-of-window mappings, and schedules only
missing or changed candidates. A concurrent request sets a single follow-up
pass instead of creating competing schedulers. The bounded 50 policy respects
iOS's small pending-notification capacity and avoids resurrecting historical
reminders; reminders beyond the window are scheduled by a later reconciliation.

Each installation allocates its own stable integer IDs in
`notification_mappings`. These IDs and mappings never sync. The synchronized
Reminder row does, so another device pulls it into Drift and independently
creates its local projection if that device has permission. There is no push or
remote notification service.

Notification payloads encode only `savedItemId` and `reminderId`. Runtime taps
and cold-start launch details pass through `NotificationRouteResolver`, which
validates the item in Drift before routing with `go_router`. An active item opens
SavedItem Detail; a malformed payload or missing/soft-deleted item opens Inbox.
Device integration errors are caught during app lifecycle setup so they cannot
prevent the offline-first UI from opening.

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
Detail. It resolves a local PhotoManager thumbnail first, then a validated
cached or lazily downloaded private preview, then a first-class placeholder,
and owns fullscreen zoom. Feature screens never depend directly on
PhotoManager or Supabase Storage.

User notes use the reserved `SavedItem.userNoteEntityKey` inside the existing
synchronized `entities` map. The domain exposes `userNote` separately and
removes it from `detectedEntities`, so presentation never confuses user-authored
content with detected metadata. Because `entities_json` already participates in
local-first writes and cloud mapping, notes require no schema change.

`RemindersRepository` supports per-item watches, creation, editing, completion,
soft delete, and future pending reminders. Each mutation notifies the local
projection scheduler after commit. `SyncQueueRepository` supports enqueue,
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
19. Original screenshot bytes are never written to Supabase Postgres or Storage.
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
51. AI suggests actions; only the user executes them.
52. External URLs are validated before launch.
53. Calendar creation uses system confirmation UI.
54. Kipto does not require calendar read access for its MVP.
55. Maps uses external system apps/URLs, not a map SDK.
56. Reminder rows are the source of truth; notifications are a device-local
    projection.
57. Notification permission is requested only after explicit user intent.
58. A denied notification permission never prevents a Reminder from being
    saved.
59. Notification identifiers are device-local and never synchronized.
60. Notification reconciliation is idempotent.
61. Kipto schedules only a bounded set of upcoming local notifications.
62. Action success never automatically marks the entire SavedItem done.
63. Opening an external app is not equivalent to completing the underlying
    real-world task.
64. Device integrations never bypass Drift for synchronized state changes.
65. Original screenshots never enter Kipto cloud storage.
66. Cloud screenshot images are optimized previews only.
67. The preview bucket is private.
68. `cloudPreviewPath` stores an object path, never a signed URL.
69. Preview generation happens on-device.
70. Preview upload and metadata sync are separate queues.
71. SavedItemImage prioritizes local original over cloud preview.
72. Restoring Kipto restores the library, not the original photo library.
73. Protecting an anonymous library preserves the Supabase user UUID.
74. Restoring an existing library signs in; it does not link to a disposable
    anonymous user.
75. Account changes never silently merge libraries.
76. Provider secrets never ship in the Flutter application.
77. AI opt-in, Photos permission, and notification permission remain
    device-local.
78. Logging never includes screenshot bytes or OAuth tokens.

## Not implemented in Phase 7

There is no original screenshot backup, automatic Photos re-linking across
devices, account merge, fast account switching, identity unlink UI, email/
password, magic links, background file daemon, push notifications, remote
notification service, system Reminders integration, Calendar read/
deduplication, embedded Maps SDK, carrier API, WebView, RevenueCat, sharing,
web app, embeddings, or OpenAI Batch path. Gallery observation, sync, analysis,
preview transfer, and notification reconciliation remain foreground lifecycle
work; no WorkManager, BGTaskScheduler, Android foreground service, closed-app
polling, or exact-alarm permission is used.
