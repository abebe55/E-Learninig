@echo off
setlocal
cd /d "%~dp0\.."

echo [1/5] Checking Flutter installation...
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter is not on PATH. Install Flutter or add flutter\bin to PATH.
  exit /b 1
)
flutter doctor -v
if errorlevel 1 (
  echo WARNING: flutter doctor reported issues. Continuing to dependency resolution.
)

echo [2/5] Resolving packages...
flutter pub get
if errorlevel 1 exit /b 1

echo [3/5] Analyzing Dart source...
flutter analyze
if errorlevel 1 echo WARNING: Analyzer reported issues. Review them, but continuing to tests and build.

echo [4/5] Running tests...
flutter test
if errorlevel 1 exit /b 1

echo [5/5] Building release APK...
flutter build apk --release -v
if errorlevel 1 exit /b 1

echo.
echo SUCCESS: APK created at:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk
if not exist "build\app\outputs\flutter-apk\app-release.apk" (
  echo ERROR: Build returned success but APK was not found.
  exit /b 1
)
for %%F in ("build\app\outputs\flutter-apk\app-release.apk") do echo APK size: %%~zF bytes
endlocal
