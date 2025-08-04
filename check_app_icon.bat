@echo off
echo App Icon Name Configuration Check
echo =================================

cd /d "%~dp0"

dart scripts\check_app_icon_config.dart

echo.
echo To fix the app icon name issue:
echo 1. Run: build_apk_with_config.bat
echo 2. Or run: dart scripts\update_app_name.dart
echo.
pause
