# LearnFlow — Flutter E-Learning App

A complete e-learning mobile application built with Flutter for the Abyssinia Software Technology practical assignment.

## Demo credentials

| Field    | Value            |
|----------|------------------|
| Email    | `any@email.com`  |
| Password | any 6+ characters |

Or tap **Guest** to skip login entirely.

## Features

- **Auth** — Register, login (local storage), guest access, logout
- **Course catalog** — 4 courses with chapters and lessons, loaded from `assets/data/courses.json`
- **Video playback** — Chewie player with full controls, speed selector (0.5× – 2×), fullscreen
- **Offline downloads** — Download lessons for offline playback with live progress (% and MB)
- **Progress tracking** — Mark lessons complete, per-course progress bars, learning hours
- **Downloads screen** — Downloading / Completed tabs with storage usage indicator
- **Profile** — Edit name, view stats, navigate to settings
- **Settings** — Notification preferences, Wi-Fi-only downloads toggle

## Project structure

```
lib/
├── app/
│   └── app_theme.dart          # Colors, text styles, widget themes
├── models/
│   ├── course_model.dart
│   ├── chapter_model.dart
│   └── lesson_model.dart
├── screens/
│   ├── tabs/
│   │   ├── home_tab.dart       # Dashboard with continue-learning card
│   │   ├── explore_tab.dart    # Search + category filter
│   │   ├── downloads_tab.dart  # Active + completed downloads
│   │   └── profile_tab.dart    # User stats and actions
│   ├── auth_screen.dart        # Login / register
│   ├── course_detail_screen.dart
│   ├── main_shell.dart         # Bottom nav shell
│   ├── settings_screen.dart
│   ├── splash_screen.dart
│   └── video_player_screen.dart
├── services/
│   └── learnflow_store.dart    # ChangeNotifier: auth, downloads, progress
└── widgets/
    ├── course_art.dart         # Course thumbnail image picker
    └── course_card.dart        # Reusable course list/grid card
```

## Setup and build

**Requirements**

- Flutter 3.x (Dart SDK included)
- Android Studio with:
  - Android SDK Platform 36
  - NDK 28.2.13676358
  - Java 17

**Steps**

```powershell
flutter doctor -v          # verify environment
flutter pub get            # fetch dependencies
flutter build apk --release
```

APK output: `build\app\outputs\flutter-apk\app-release.apk`

## Known limitations

- Authentication is **local only** — no backend. Passwords are not verified on login (prototype behavior).
- Video URLs use publicly available sample MP4 files from [test-videos.co.uk](https://test-videos.co.uk). Internet is required for streaming; download first for offline viewing.
- Release build uses debug signing. Configure a keystore before production distribution.
- Google sign-in button is present in the UI but not connected (requires Firebase/OAuth setup).
