# Kipto

Kipto (`keep + capture`) is an offline-first inbox for screenshots. A screenshot
and everything known about it are represented as one `SavedItem`, centered on
the user's pending intent rather than on the image file.

Phase 1 runs fully offline with Flutter, Riverpod, go_router, Drift, and SQLite.
It includes a seeded Inbox, Library, local Search, Settings, item detail actions,
reminders, soft delete, and the persistence boundary needed for future sync.

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
