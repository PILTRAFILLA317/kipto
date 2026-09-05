# Kipto – Life Admin

## Product direction

Kipto will help people externalize small life obligations: bills, renewals,
appointments, documents, guarantees, reservations, and deadlines.

The eventual promise is: **Send it. Forget about it.**

## Current product surface

This repository is intentionally at the post-cleanup foundation stage. The app
has a minimal Inbox, Settings, recoverable accounts, local items/reminders, and
the supporting sync and notification infrastructure. It does not yet accept a
new source or infer what an item means.

## Design principles

1. Keep the user in control of every real-world action.
2. Treat Drift as the local source of truth.
3. Keep authentication recoverable without silently merging libraries.
4. Build only the domain required by the current phase.
5. Keep the interface calm, accessible, and honest about unavailable features.
