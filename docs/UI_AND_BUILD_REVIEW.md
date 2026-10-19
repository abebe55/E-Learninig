# LearnFlow student UI and build notes

## Implemented in this source package

- Student-only mobile app; instructor and admin dashboards are intentionally excluded.
- Splash, login/register UI, guest entry, home, searchable Explore catalog, course details, chapter/lesson navigation, video player, downloads/offline playback, profile, progress summary, and settings.
- White primary/secondary buttons with bold blue labels and no visible outline. Input fields retain subtle outlines.
- Pale blue/white visual system and bundled course illustrations.
- Four local sample courses (36 lessons total), with course progress and completed lesson state saved locally.
- Video download manager using Dio and app-private storage; downloaded files are used by the video player when available.
- Android launcher icons updated to LearnFlow artwork at the standard density sizes.
- Android package namespace, application ID, and `MainActivity` package match: `com.abyssinia.learnflow`.
- Android cleartext traffic is disabled and the app's network permissions are limited to internet/network state.
- Explicit NDK `28.2.13676358` setting matches the NDK version reported by the plugin in the supplied build logs.
- Machine-specific `android/local.properties`, generated build caches, and previous build outputs are excluded.

## Known limitations

- Authentication is a local prototype only. It stores the active profile but does not verify credentials against a backend. Passwords are not saved. Google sign-in, password reset, and password changes require a real identity provider/backend.
- Course metadata and learning progress are local; no FastAPI/PostgreSQL integration is included in this student-only package.
- Video URLs in `assets/data/courses.json` are public sample media and may fail, change, or be large. Replace them with authorized stable media URLs for a real submission.
- Downloaded files and completion records are device-local. There is no cross-device sync.
- Some notes, notifications, and settings are UI-level prototype features.
- Android release builds currently use debug signing for assessment/testing. Configure a private release keystore before publishing.
- The artwork is locally bundled and the visual style follows the supplied reference, but it is not pixel-identical to every screenshot detail.

## Build verification

The code was checked for balanced Dart delimiters, referenced asset existence, valid course JSON, valid `pubspec.yaml`, valid Android manifest XML, and a clean ZIP archive. Flutter/Dart are not installed in the generation environment, so `flutter analyze`, `flutter test`, and `flutter build apk` could not be run here. Do not consider the app compiled until the following commands succeed on your Windows machine:

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter clean
flutter build apk --release -v
```

Expected APK: `build/app/outputs/flutter-apk/app-release.apk`.
