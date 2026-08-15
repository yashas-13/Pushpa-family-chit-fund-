# Pushpa Family Chit Mobile App

Cross-platform Flutter client for Android and iOS.

## Roles

- **Agent:** manages the chit, Lucky Dip, members, payment verification and reports.
- **Member:** sees only their own private records and the current payment destination needed for the monthly contribution.

## Backend

The app is designed for a serverless Supabase backend:

- Supabase Auth
- PostgreSQL + RLS
- Supabase Storage
- Supabase Realtime
- PostgreSQL RPCs for atomic business transitions
- Edge Functions only where server-side secrets or external services are required

## Local configuration

Never place a service-role key in the app.

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

## CI

GitHub Actions generates the Android/iOS platform folders, runs `flutter analyze` and `flutter test`, then builds a debug Android APK and unsigned iOS build.

The backend migrations live under `../supabase/migrations`.
