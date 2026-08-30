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
- **SavedItemImage** is the presentation boundary for local originals and
  unavailable-image placeholders. A future cloud-preview source can be added
  there without coupling screens to `photo_manager`.
- **Appearance** supports persisted System, Light, and Dark modes. Material 3
  tokens centralize spacing, radii, thumbnail sizes, typography, and component
  shapes.

Snooze changes the SavedItem workflow state and `snoozedUntil`. A reminder is a
separate persisted entity that can be completed or deleted; Phase 4 does not
schedule operating-system notifications. Suggested Calendar, Maps, tracking,
and link actions provide honest “available soon” feedback and never report an
external operation as completed.

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

## Supabase setup (Phases 3 and 5)

1. Create or link a Supabase project and enable Anonymous Sign-Ins under Auth.
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
are valid authenticated Kipto users. Cloud sync transfers metadata only. Image
bytes exist only inside the direct function/OpenAI request and are discarded.

Anonymous sessions are persisted by `supabase_flutter`. They sync reliably on
the current installation but cannot yet be restored on another device. A later
phase will add identity linking.

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
