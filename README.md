# UniFocus

UniFocus is a Flutter app with a modular architecture that includes:

- Firebase Cloud Messaging (foreground/background/terminated handling)
- Foreground local notifications
- Google OAuth using `google_sign_in`
- Gmail metadata fetching example via REST API
- Reactive local persistence using Hive
- MVVM-style state via `Provider` + service layer + DI via `GetIt`

## Folder Structure

```text
lib/
  di/
	service_locator.dart
  models/
	notification_model.dart
  services/
	auth_service.dart
	database_service.dart
	firebase_service.dart
  viewmodels/
	auth_view_model.dart
	notification_view_model.dart
  screens/
  main.dart
```

## Setup

1. Configure Firebase for Android and iOS:
   - Add `android/app/google-services.json`
   - Add `ios/Runner/GoogleService-Info.plist`
2. Enable Cloud Messaging in Firebase Console.
3. Configure Google Sign-In OAuth consent and client IDs.
4. Add Gmail API to the same Google Cloud project.

## Run

```bash
flutter pub get
flutter run
```
