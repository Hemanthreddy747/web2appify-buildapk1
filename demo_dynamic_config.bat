@echo off
echo Dynamic Configuration Demo
echo ==========================
echo.
echo This demo shows how the app uses:
echo - Values from config.json when available
echo - Default values when config.json is missing or incomplete
echo.
echo Default Values:
echo   App Name: "buildapk1"
echo   Application ID: "com.buildapk1.app1"  
echo   URL: "https://www.web2appify.com"
echo.

cd /d "%~dp0"

echo Running dynamic configuration demo...
dart scripts\demo_dynamic_config.dart

echo.
echo To test the dynamic behavior:
echo 1. Rename config.json to config.json.backup
echo 2. Run: flutter run
echo 3. App will use default values
echo 4. Rename config.json.backup back to config.json
echo 5. Run: flutter run
echo 6. App will use your custom values
echo.
pause
