# Kipto

Kipto (`keep + capture`) is an offline-first inbox for screenshots. A screenshot
and everything known about it are represented as one `SavedItem`, centered on
the user's pending intent rather than on the image file.

Phase 4 turns that technical foundation into a complete product experience.
Drift remains the only database read by the UI; Supabase is reached only through
`SyncService` and a remote data source. The four persistent tabs are Inbox,
Library, Search, and Settings, while SavedItem Detail opens above the shell.
First use stays inside the contextual permission/import flow until the durable
initial-import flag is complete; existing users keep their offline library even
when Photos access is later removed.

Phase 5 adds opt-in multimodal analysis without changing that local-first
boundary. Screenshot bytes travel only in a temporary authenticated function
request; validated analysis is committed to Drift first and then reaches
Postgres through the existing `SyncService`.

Phase 6 turns validated suggestions into explicit, user-driven device actions.
Calendar, Maps, browser, search, clipboard, tracking, favorites, and Kipto
reminders now run through one typed action layer. Reminder rows remain
synchronized domain state; local notifications are a bounded, rebuildable
projection owned independently by each device.

Phase 7 adds recoverable Apple/Google identities and multi-device restoration.
Metadata stays Drift-first, while a separate foreground queue generates small
JPEG previews on-device and stores them in a private, owner-scoped Supabase
Storage bucket. Original screenshots always remain in Photos.

## Phase 4 product model

- **Inbox** is organized by action and urgency, with exclusive Needs action,
  Expiring soon, Coming up, Ready to analyze, and Recent sections. Done,
  archived, and soft-deleted items are excluded.
- **Library** is the complete non-deleted collection. Category, status,
  analysis-state, and favorite filters plus newest, oldest, expiry, and updated
  sorting execute through repository/DAO queries.
- **Search** is a debounced local search over title, summary, subtype, intent,
  category, and indexable entity JSON. It remains usable offline.
- **Detail** keeps the screenshot visually important without allowing long
  captures to dominate the page. It supports fullscreen zoom, title/category
  edits, synchronized user notes, favorites, done/archive/restore, snooze
  presets, reminders, and soft-delete. Every edit writes Drift first and enters
  the existing sync queue.
- **Analysis states** are controlled UI states: unprocessed, processing,
  processed, needs review, and failed. Real imports remain unprocessed and never
  receive invented titles, summaries, intent, or categories in the UI.
- **SavedItemImage** is the presentation boundary for local originals, cached
  or lazily downloaded private previews, and unavailable-image placeholders,
  without coupling feature screens to `photo_manager` or Supabase Storage.
- **Appearance** supports persisted System, Light, and Dark modes. Material 3
  tokens centralize spacing, radii, thumbnail sizes, typography, and component
  shapes.

Snooze changes the SavedItem workflow state and `snoozedUntil`. A reminder is a
separate persisted entity that can be edited, completed, or deleted. Phase 6
projects pending reminders into local operating-system notifications without
making notifications the source of truth.

User notes use the controlled `userNote` key inside the existing synchronized
`entities` map. Presentation excludes that reserved value from detected
information, while search and `entities_json` sync continue to cover it. No
schema migration is required.

The development seed is now explicit: normal debug launches do not insert fake
items. Tests can still invoke `DevelopmentSeed.run()`. The first real import
removes only the known deterministic Phase 1 seed IDs.

## Phase 5 multimodal analysis

The analysis path is deliberately separate from metadata sync:

```text
Photos / MediaStore
        ↓
aspect-fit JPEG prepared on device
        ↓
authenticated Supabase Edge Function
        ↓
OpenAI Responses API (image input, store=false)
        ↓
strict Structured Output + server runtime validation
        ↓
Flutter domain validation
        ↓
one Drift transaction + analysis_queue removal + sync_queue enqueue
        ↓
existing SyncService → Supabase Postgres
```

`analyze-screenshot` uses `OPENAI_MODEL`, defaulting to `gpt-5.6-luna`, with
low reasoning effort and no tools, browsing, file search, OCR pre-pass, or model
fallback. Its schema and prompt are independently versioned as schema `1` and
prompt `1.0.0`. The result contains a controlled category and intent, subtype,
title, summary, recognized source app, action requirement, controlled action
suggestions, event/expiry dates, location, allowlisted entities, relevance,
confidence, uncertain fields, and short search keywords.

On-device preparation requests an aspect-fit JPEG at 1280 px width and up to
4096 px height, then retries at 1080/900 px with lower quality when needed. The
whole long screenshot remains visible rather than being cropped. Flutter will
not send more than 4 MB; the function independently validates request size,
base64, MIME (`jpeg`, `png`, or `webp`), and magic bytes. Neither the function
nor Postgres persists the screenshot or OpenAI response.

AI analysis is off by default and the choice is persisted per device. Enabling
it makes newly imported screenshots auto-enqueue while Kipto is active; it does
not silently enqueue historical screenshots. Inbox and Settings show the real
historical count before **Analyze**, followed by completed/total progress and
Pause/Resume controls. `analysis_queue` is a local SQLite v4 table independent
from `sync_queue`, deduplicates by SavedItem, survives restarts, recovers an
interrupted `processing` job, and runs one request at a time. Retryable network,
timeout, 429, and server failures get at most three attempts with backoff and
`Retry-After` support. Processing stops in background and resumes in foreground.

Application policy, never the model, decides lifecycle state. Confidence
`>= 0.70` becomes `processed`; lower valid output becomes `needsReview`.
`requiresAction` becomes `needsAction` only when at least one suggestion passes
its prerequisite, while archived, done, and snoozed states are preserved.
Calendar and package actions require confidence `>= 0.80`. Analysis only
suggests actions and never creates reminders or invokes Calendar, Maps, links,
tracking, notifications, or deletion.

Analysis provenance (`model`, prompt version, analyzed time, relevance,
uncertain fields, search keywords, and title/category source) lives under the
reserved `entities_json["__kiptoAnalysis"]` key. This gives it immediate cloud
parity through the existing synchronized JSON without new SavedItem columns.
Manual title/category edits set their source to `user`; re-analysis preserves
them. User notes and image dimensions are preserved as well.

Server-side cost protection uses `analysis_usage_daily`, which contains only
daily aggregate request/success/error and token counts. App roles receive no
table or RPC access. A service-role-only, security-definer RPC atomically
reserves the configurable `ANALYSIS_DAILY_LIMIT` (default 2000) before OpenAI is
called; Flutter cannot choose or bypass the limit. Function logs contain only a
request ID, short user hash, model, latency, token counts, status, and safe error
code—never image bytes, extracted content, prompts, or secrets.

## Phase 6 device actions and reminders

Presentation sends every action through `SavedItemActionExecutor`. The executor
revalidates its prerequisites, calls a narrow device/application service, and
returns a typed result: success, launched, cancelled, unavailable, invalid data,
permission denied, or failure. Widgets do not invoke platform plugins directly.
Only Calendar, Create Reminder, and Save persist a per-action completion; none
of them marks the whole SavedItem Done. Completed actions live in the existing
synchronized `entities_json["__kiptoCompletedActions"]` map. Client pull and a
Postgres trigger merge each action key using its newest valid timestamp, so two
offline devices do not erase unrelated completions.

Calendar uses a small native platform adapter instead of an outdated calendar
plugin. iOS presents `EKEventEditViewController`, returning saved versus
cancelled and requiring no calendar access prompt on iOS 17+. The supported
iOS 15–16 fallback requests the legacy minimum EventKit access only after the
user starts Add to Calendar. Android opens `ACTION_INSERT` with a prefilled
`CalendarContract.Events` draft and requests neither `READ_CALENDAR` nor
`WRITE_CALENDAR`. Android calendar apps do not provide a portable saved/cancelled
result for that intent, so Kipto records that the editor opened but does not
claim the Calendar action completed.

Maps uses external URLs/intents, not a map SDK or API key. A controlled query is
built from structured location data or the SavedItem location. iOS opens Apple
Maps, Android opens a `geo:` intent, and both fall back
to a Google Maps HTTPS search. Opening Maps means only that the system accepted
the destination; it does not complete the user's real-world task.

All browser-bound URLs pass `SafeUriPolicy`: only HTTP(S), a non-empty host, no
userinfo, no whitespace, and a conservative `www.` → HTTPS normalization are
accepted. `javascript:`, `data:`, `file:`, malformed, and credential-bearing
URLs are rejected. Web Search builds a bounded encoded query. Tracking prefers
a validated explicit URL and otherwise searches by carrier plus tracking code,
or by code alone. Copy Code reads only controlled coupon, tracking, and order
entity keys before writing through Flutter's clipboard API. Save favorites the
existing SavedItem in the same local-first synchronized write; it never creates
a duplicate row.

Create Reminder persists the reminder and its synchronized completion before
notification permission or scheduling. The first explicit reminder intent may
request notification permission; startup never does. Denial therefore leaves a
valid reminder and offers system notification settings instead of losing user
data. Settings always queries the operating system's current permission state;
there is no authoritative `notificationsEnabled` flag in Drift or Supabase.

`flutter_local_notifications` schedules timezone-aware local notifications.
`flutter_timezone` provides the current IANA identifier and `timezone` converts
the UTC reminder instant into that location. Reconciliation runs on startup,
resume, reminder create/edit/complete/delete, SavedItem deletion, and after a
remote reminder pull. It compares pending rows with local mappings, cancels
stale notifications, reschedules changes or timezone moves, and keeps only the
next 50 future reminders. This bounded policy stays below iOS's small pending
notification limit and avoids recreating expired reminders.

`notification_mappings` is a device-only SQLite v5 table mapping reminder UUIDs
to stable integer notification IDs, scheduled instants, and timezone names. It
is deliberately absent from Supabase. Each device independently projects pulled
reminders into its own notifications; there is no push notification, remote
notification ID, background daemon, or exact-alarm permission. Android uses
`inexactAllowWhileIdle`, the standard reminder channel, the scheduled receiver,
and boot/package-replace rescheduling receivers, so delivery may have normal
platform timing margin.

Notification payloads contain only SavedItem and Reminder IDs. A foreground,
background, or cold-start tap validates the SavedItem against Drift and routes
to Detail; missing or deleted items fall back safely to Inbox. Scheduled
notifications work without network access once installed by the OS.

## Phase 7 cloud previews and recoverable accounts

Kipto now separates the local original from its portable visual preview. A
`PhotoManagerCloudPreviewGenerator` requests an aspect-fit JPEG at up to 900 px
wide, 8000 px high, and 8 megapixels, normally at quality 80. Very tall captures
are scaled as a whole and never silently cropped. If an unusually large result
exceeds 1.5 MB it is regenerated at quality 68. Generation happens only for a
SavedItem that needs backup; gallery scans remain metadata-only.

`preview_transfer_jobs` is the persistent SQLite v6 file queue, independent
from `sync_queue`. It records upload/delete operation, queued/uploading/retry/
paused state, attempts, next attempt, safe error code, and creation time. Two
uploads run concurrently while Kipto is foregrounded. Network failures use
bounded retry; missing originals stop permanently. Upload is idempotent at
`{auth.uid()}/{savedItemId}/preview-v1.jpg`. Storage succeeds first, then one
Drift transaction writes `cloudPreviewPath` and enqueues normal metadata sync.

The `kipto-previews` bucket is private. Storage RLS permits SELECT, INSERT,
UPDATE, and DELETE only when the first object-path segment equals `auth.uid()`.
The client always derives that segment from the current session, never from UI
input. `cloudPreviewPath` is an object path—not a public or signed URL—and no
original image is ever sent to Storage.

`SavedItemImage` resolves images in this order: local Photos thumbnail, valid
downloaded preview cache, lazy private download, placeholder. Downloads are
deduplicated by object path and limited to three concurrent requests. Validated
JPEG/WebP files live in application support, not Photos or Drift BLOBs. The
cache uses stable item/path-derived names, last-accessed eviction, a 200 MB
limit, and explicit local-only clearing. Previously cached previews remain
available offline.

Cloud Backup offers **Optimized previews** (recommended) and **Metadata only**.
Switching to metadata-only stops new image uploads but does not delete existing
cloud previews. **Remove cloud screenshot previews** is a separate confirmed,
batched and retryable cleanup that keeps metadata and Photos intact. Bulk backup
shows Drift-derived eligible/uploaded/waiting/failed counts and requires the
user to start it; it never fans out thousands of simultaneous operations.

First launch no longer creates an anonymous identity before the choice to
restore. **Get started** creates the anonymous user; **Sign in to restore** uses
Apple or Google OAuth with PKCE. Protecting an existing anonymous library uses
Supabase manual identity linking and asserts that the user UUID remains the
same. Restoring signs into the existing user instead of linking it to a
disposable anonymous user. Initial sync restores SavedItems and reminders;
previews remain lazy, originals are never claimed as restored, and AI opt-in,
Photos permission, notification permission, and appearance remain device-local.

Permanent-account sign-out stops sync/file/analysis runners, cancels Kipto's
local notification projection, clears account-scoped Drift rows and downloaded
preview cache, then signs out. Cloud rows, cloud previews, and Photos are not
deleted. Anonymous users are not offered destructive sign-out.

## Run locally

Copy the safe example configuration, fill it with the project URL and
publishable key (never a secret or service-role key), then run:

```sh
cp config/dev.example.json config/dev.json
flutter pub get
dart run build_runner build
flutter run --dart-define-from-file=config/dev.json
```

Without `config/dev.json`, debug and test launches stay in local-only mode and
Settings shows that cloud sync is not configured.

Normal launches never insert demo content. Tests and explicit development tools
can still seed deterministic processed examples.

## Verify

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Edge Function verification uses Deno 2:

```sh
deno fmt --check supabase/functions/analyze-screenshot
deno lint --config supabase/functions/analyze-screenshot/deno.json \
  supabase/functions/analyze-screenshot
deno check --config supabase/functions/analyze-screenshot/deno.json \
  supabase/functions/analyze-screenshot/index.ts
deno test --config supabase/functions/analyze-screenshot/deno.json \
  --allow-env supabase/functions/analyze-screenshot/analysis_test.ts
```

When Drift tables or DAOs change, regenerate checked-in code with:

```sh
dart run build_runner build
```

See [Architecture](docs/architecture.md) for the persistence model, dependency
rules, local/cloud field boundary, and planned extension points.

## Supabase setup (Phases 3, 5, 6, and 7)

1. Create or link a Supabase project and enable Anonymous Sign-Ins under Auth.
   Enable Manual Linking and the Apple/Google providers used by the app.
2. Apply the versioned migrations with `supabase db push`.
3. Put only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` in
   `config/dev.json`.
4. Configure the server-only secrets (substitute the real key locally; never
   commit it):

   ```sh
   supabase secrets set OPENAI_API_KEY=YOUR_KEY \
     OPENAI_MODEL=gpt-5.6-luna ANALYSIS_DAILY_LIMIT=2000
   ```

5. Deploy with `supabase functions deploy analyze-screenshot`.
6. Start Flutter with `--dart-define-from-file=config/dev.json`.

The cloud migrations create `saved_items`, `reminders`, `devices`, and the
aggregate-only `analysis_usage_daily` table, with strict grants and RLS. The
analysis function is authenticated with `verify_jwt=true`; anonymous Auth users
are valid authenticated Kipto users. SavedItem/reminder sync transfers metadata;
Phase 7's independent Storage queue may additionally persist an explicitly
optimized preview. The separate analysis image exists only inside the direct
function/OpenAI request and is discarded.
Phase 6 adds only the completed-action merge trigger because completion state
already travels inside `entities_json`; notification mappings and OS permission
state never enter the cloud schema.

Phase 7 also creates the private `kipto-previews` bucket and owner-only Storage
policies through SQL. Add both
`com.example.kipto://auth/callback?flow=protect` and
`com.example.kipto://auth/callback?flow=restore` to Supabase Auth redirect URLs
for local development. The callback returns a successful protection flow to
Settings and a successful restore flow to Inbox; provider errors show a safe
message without replacing the local library. The checked-in bundle/application
ID is still the Flutter placeholder `com.example.kipto`; choose the real stable
ID before production, update the redirect scheme in
Flutter/iOS/Android/Supabase, and then configure Apple and Google credentials.
Provider secrets, Apple keys, and Google client secrets belong only in
Supabase/provider dashboards and must never be added to Flutter configuration.

### Phase 7 provider configuration

The implementation deliberately uses Supabase browser OAuth/PKCE for both
protection (`linkIdentity`) and restore (`signInWithOAuth`), so Flutter needs no
Google or Apple token SDK and holds no provider secret.

1. Replace `com.example.kipto` with the final stable bundle/application ID in
   Xcode, Gradle, the OAuth redirect constant, iOS URL type, Android intent
   filter, and Supabase redirect allowlist.
2. In Supabase Auth, enable Anonymous Sign-Ins, Manual Linking, Google, and
   Apple. Allow `<final-id>://auth/callback?flow=protect` and
   `<final-id>://auth/callback?flow=restore` as redirect URLs.
3. In Google Cloud, create the OAuth consent screen and web OAuth client. Add
   `https://<project-ref>.supabase.co/auth/v1/callback` as an authorized redirect
   URI, then put that client ID/secret only in the Supabase Google provider.
4. In Apple Developer, enable Sign in with Apple for the final App ID, create a
   Services ID associated with it, allow the Supabase callback URL, and create
   the required key. Put Team ID, Services ID, Key ID, and private key only in
   the Supabase Apple provider. Add the Sign in with Apple capability to the
   production iOS target.
5. Apply migrations with `supabase db push`, then smoke-test link on an existing
   anonymous user and sign-in on a clean simulator. Verify the Supabase user UUID
   is unchanged after linking and that Storage contains only small JPEG previews
   under that UUID—not original screenshots.

## Test with real screenshots

1. Run Kipto on an iOS simulator/device or Android emulator/device containing
   screenshots.
2. Choose **Allow access** in Inbox and grant full or selected-photo access.
3. Import the recent 100, last 30 days, or all accessible screenshots.
4. Verify the Inbox thumbnail and open Detail for the larger representation.
5. Capture another screenshot, return to Kipto, or use **Scan for new
   screenshots** in Settings.

Limited access is supported on iOS 14+ and Android 14+. **Manage access** opens
the platform reselection UI. Kipto never writes, edits, moves, or deletes system
photos.

For prompt-quality evaluation, use synthetic/non-sensitive examples covering:
concert, restaurant video, product, order tracking, recipe, coupon, a chat that
says “call tomorrow”, Shazam/song, meme, reference information, an ambiguous
capture, and expired content. Check purpose—not merely source app—plus dates
relative to capture time, actions, confidence/review state, Search, restart
persistence, offline queueing, and user-title/category preservation. Normal
tests mock OpenAI; a real smoke test requires `OPENAI_API_KEY` and a device or
simulator with accessible screenshots.
