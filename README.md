# Tranquility

Tranquility is a digital-wellbeing app built with Flutter and native Kotlin. It helps you cut down on distracting apps: when you open an app you have chosen to restrict, Tranquility shows a pause screen with your usage for that app and asks you to confirm before you continue.

## Features

- Choose which installed apps to restrict
- Full-screen intervention when a restricted app opens, showing open count and usage time
- Hold-to-continue confirmation, or a hard block for apps that have reached their limit
- Breathing and focus screens
- Usage statistics and recent interactions
- Settings stored locally with Hive and SharedPreferences
- Android detection through an Accessibility Service and Usage Stats access (Kotlin)
- iOS setup screen and a deep-link service for the iOS flow

## Technologies

Flutter (Dart 3), Riverpod, go_router, Hive, SharedPreferences, flutter_secure_storage, Kotlin (Android services).

## Getting started

Requirements: Flutter SDK 3.x, Android Studio or the Android SDK, and an Android device or emulator.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

On Android the app asks for Accessibility and Usage Access permissions. Both are needed to detect which app is in the foreground.

## Known limitations

- Foreground-app detection is implemented for Android. The iOS flow is a setup screen only and has not been verified on a device.
- There are no automated tests yet.

## Future improvements

- Unit and widget tests
- Per-app time limits and scheduled focus sessions
