# Kipto

Kipto (`keep + capture`) is an offline-first inbox for screenshots. A screenshot
and everything known about it are represented as one `SavedItem`, centered on
the user's pending intent rather than on the image file.

Phase 2 runs fully offline with Flutter, Riverpod, go_router, Drift, SQLite, and
`photo_manager`. It requests image-only photo access in context, discovers real
screenshots, imports metadata in pages, and resolves thumbnails lazily. Inbox,
Library, local Search, Settings, item detail actions, reminders, and soft delete
continue to use the same local persistence boundary.

The development seed is now explicit: normal debug launches do not insert fake
items. Tests can still invoke `DevelopmentSeed.run()`. The first real import
removes only the known deterministic Phase 1 seed IDs.

## Run locally

```sh
flutter pub get
dart run build_runner build
flutter run
```

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
