@echo off
echo Testing Configuration Changes
echo =============================
echo.
echo This script will help you test that config.json changes 
echo are properly reflected in the application.
echo.

cd /d "%~dp0"
cd ..

echo Running configuration test script...
dart scripts\test_config_changes.dart

echo.
echo After making changes, run the app with:
echo flutter run
echo.
echo To build APK:
echo flutter build apk --release
echo.
pause
