# LearnFlow — Student Flutter App

A Flutter Android prototype for the student-facing portion of the LearnFlow e-learning assignment. It intentionally excludes instructor and administrator dashboards.

## Included student flows

- Splash / branding
- Local demo login, registration, guest access, and logout
- Home dashboard and course search/category filters
- Course details with chapters and lessons
- Video playback, Previous/Next navigation, and lesson completion
- Video downloads, progress status, and local playback when downloaded
- Profile and local settings

## UI rules

- Pale blue-gray page background, white cards, restrained blue accents
- Buttons use a white background with bold blue text and **no visible outline/border**
- Input fields retain a subtle border to make form fields clear
- Selected category chips use pale blue without an outline

See `docs/DESIGN_MATCH_CHECKLIST.md` for the reference-based design decisions and final verification checklist.

## Requirements

Install Flutter (Dart SDK included), Java 17, Android SDK Platform 36, Android SDK Build-Tools, NDK `28.2.13676358`, and a compatible CMake installation through Android Studio's SDK Manager.

Do not copy `android/local.properties` from another PC. Flutter should generate it or it should contain the correct local Flutter and Android SDK paths for the current computer.

## Build on Windows PowerShell

From this directory:

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter clean
flutter build apk --release -v
```

Expected APK:

`build\app\outputs\flutter-apk\app-release.apk`

Alternatively, run `scripts\build_apk_windows.bat`.

## Important limitations

- Authentication is a local demo, not real secure account authentication. Do not use a real password.
- Google sign-in and password reset are not connected to a provider/backend.
- Course metadata is bundled in `assets/data/courses.json`.
- Video lessons use sample external video URLs; availability, authorization and download behavior must be tested. A video is offline only after a successful download.
- The release build currently uses debug signing for demonstration. Configure a private release keystore before production distribution.
- The UI has been aligned in source to the supplied reference, including the no-outline button requirement, but pixel-perfect visual matching and successful APK compilation must be verified on a real build/device.
