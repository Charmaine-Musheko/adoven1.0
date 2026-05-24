# adoven

A new Flutter project.

## Configuration

The app reads Supabase and backend API settings from Dart defines.

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key \
  --dart-define=API_BASE_URL=https://your-digitalocean-app.ondigitalocean.app/api
```

For password reset emails, add this redirect URL in Supabase Auth settings:

```text
adoven://reset-password
```

For Supabase Auth URL configuration, use:

```text
Site URL: adoven://auth/callback
Additional Redirect URLs: adoven://**
```

The app uses `supabase_flutter`, which listens for auth deep links internally
when `detectSessionInUri` is enabled. That is the package default in this app.

If your data API is hosted on DigitalOcean, expose JSON endpoints under the
same paths used by the app, such as `/api/token`, `/api/report`, `/api/admin`,
and `/api/alert`, then pass that app URL through `API_BASE_URL`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
