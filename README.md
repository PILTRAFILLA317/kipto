# Kipto

Kipto (`keep + capture`) is an offline-first inbox for screenshots. A screenshot
and everything known about it are represented as one `SavedItem`, centered on
the user's pending intent rather than on the image file.

Phase 3 keeps the Phase 2 offline-first Flutter experience and adds anonymous
Supabase Auth plus metadata synchronization. Drift remains the only database
read by the UI; Supabase is reached only through `SyncService` and a remote data
source. The app requests image-only photo access in context, discovers real
screenshots, imports metadata in pages, and resolves thumbnails lazily. Inbox,
Library, local Search, Settings, item detail actions, reminders, and soft delete
continue to use the same local persistence boundary.

The development seed is now explicit: normal debug launches do not insert fake
items. Tests can still invoke `DevelopmentSeed.run()`. The first real import
removes only the known deterministic Phase 1 seed IDs.

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

Demo data is inserted idempotently in debug builds only. Release builds never
seed demo content.

## Verify

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

When Drift tables or DAOs change, regenerate checked-in code with:

```sh
dart run build_runner build
```

See [Architecture](docs/architecture.md) for the persistence model, dependency
rules, local/cloud field boundary, and planned extension points.

## Supabase setup (Phase 3)

1. Create or link a Supabase project and enable Anonymous Sign-Ins under Auth.
2. Apply the versioned migration with `supabase db push`.
3. Put only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` in
   `config/dev.json`.
4. Start Flutter with `--dart-define-from-file=config/dev.json`.

The migration creates `saved_items`, `reminders`, and `devices`, strict
owner-only RLS/grants, incremental server timestamps, and private per-user
Realtime Broadcast invalidations. It creates no Storage bucket or Edge
Function. Cloud sync transfers metadata only—never screenshot or thumbnail
bytes.

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
