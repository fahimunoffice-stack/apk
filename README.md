# Softism Bot Manager (Flutter)

Bangla-first Flutter app to manage Messenger automation + live chat + orders, connected to an existing Supabase backend.

## Requirements

- Flutter **3.38.0** (Dart 3.10)
- Android Studio / Xcode toolchains as needed

## Configure

This repo ships with Supabase URL + anon key configured in `lib/config/supabase_config.dart`.

## Run

```bash
flutter create .
flutter pub get
flutter run
```

## MVP included

- Auth (email/password) + store bootstrap (create store if missing)
- Onboarding module selector (saved locally) → dynamic bottom nav tabs
- Chat inbox + chat detail + realtime messages
- Send text via `messenger-send`
- Send media via `messenger-send-media` (upload to `product-images` bucket)
- Bot rules CRUD (`messenger_auto_replies`)
- Orders list + detail + status update
- Settings: store info + FB page list/add (basic)

