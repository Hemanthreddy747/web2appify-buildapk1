@echo off
echo Updating App Name and Building APK
echo ==================================

cd /d "%~dp0"

echo Step 1: Updating app name from config.json...
dart scripts\update_app_name.dart

if %ERRORLEVEL% NEQ 0 (
    echo Failed to update app name!
    pause
    exit /b 1
)

echo.
echo Step 2: Cleaning Flutter build cache...
flutter clean

echo.
echo Step 3: Getting Flutter dependencies...
flutter pub get

echo.
echo Step 4: Building APK with updated app name...
flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ APK built successfully!
    echo The app icon will now show the name from config.json
    echo.
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo ❌ Failed to build APK
)

echo.
pause
