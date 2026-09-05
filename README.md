# Kipto – Life Admin

Kipto is being rebuilt as a local-first Life Admin: a place to send something,
forget about it, and later be reminded of what matters.

## Implemented now

- Minimal Inbox foundation with no automatic capture or scanning.
- Neutral `Item` and `Reminder` lifecycle in local Drift storage.
- Drift remains the application source of truth; UI reads through Riverpod and
  repositories only.
- Optional Supabase authentication, owner-scoped metadata sync, foreground
  retry, device identity, soft deletes, pull/restore, and private Realtime
  invalidation.
- Anonymous users can protect the same library with Apple or Google; existing
  users can restore it through the PKCE callback flow.
- Device-local reminder notification reconciliation and a retained native
  Add-to-Calendar adapter.

## Planned, not implemented

Share Sheet input, universal import, PDFs, source handling, Life Admin
analysis, facts, final product screens, billing, family, email, and voice.

## Local setup

1. Copy `config/dev.example.json` to ignored `config/dev.json` if cloud sync is
   required. Use only the Supabase URL and publishable key.
2. Run `flutter pub get`.
3. Run `flutter run`.

Without valid cloud configuration, Kipto remains fully local. It never places a
service-role key or an OpenAI key in Flutter.
