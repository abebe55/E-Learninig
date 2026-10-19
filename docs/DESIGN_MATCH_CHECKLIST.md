# LearnFlow student UI design checklist

Reference: user-supplied LearnFlow student app design collage. Scope: student-facing app only.

## Styling decisions

- Main canvas: very pale blue-gray (`#F5F8FC`).
- Primary blue: `#2878F0`; main text: `#172B4D`; muted text: `#718096`.
- Buttons: white fill, bold blue label, no visible border/outline. A very subtle shadow is allowed for separation from the pale page background.
- Input fields: white fill with a light-gray outline; focused fields may show a blue focus ring. The no-border request applies to buttons, not text fields.
- Cards: white with a subtle light-gray edge and rounded corners.
- Category chips: selected chip uses pale blue and blue text, with no outline.
- Bottom navigation: white background, blue selected icon/label, muted inactive items.
- Use compact typography and generous spacing similar to the reference image.

## Student screens included in the app

- Splash / brand screen
- Login and registration states
- Home dashboard
- Explore course catalog with search and category chips
- Course details and expandable chapter/lesson list
- Video player with description/notes tabs, playback controls and Previous/Next
- Downloads screen
- Profile screen
- Settings screen

## Validation still required on the developer's PC

This source package has not been compiled in this environment because Flutter and Dart SDKs are unavailable. Before submission:

1. Run `flutter pub get`.
2. Run `flutter analyze` and fix all errors.
3. Run `flutter test` and fix all failures.
4. Run `flutter build apk --release -v`.
5. Install the APK on a real Android phone and compare every screen with the reference at the target device size.
6. Test a video download, enable airplane mode, and play the downloaded file.

A static source review cannot certify pixel-perfect rendering across devices; screenshots from a real build are needed for the final visual comparison.
