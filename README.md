# Unspammer

Unspammer is a Flutter app with a modular architecture that includes:

- Firebase Cloud Messaging (foreground/background/terminated handling)
- Foreground local notifications
- Microsot OAuth
- Outlook email fetching via REST API, full end to end encryption.
- Reactive local persistence using Hive
- MVVM-style state via `Provider` + service layer + DI via `GetIt`

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
