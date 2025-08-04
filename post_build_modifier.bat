@echo off
setlocal EnableDelayedExpansion

echo Web2Appify Post-Build Configuration Tool
echo ========================================

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "ASSETS_DIR=%PROJECT_DIR%\assets"
set "DECOMPILE_DIR=%PROJECT_DIR%\decompiled"
set "OUTPUT_DIR=%PROJECT_DIR%\output"

:MENU
echo.
echo 1. Decompile APK
echo 2. Modify Configuration
echo 3. Recompile APK
echo 4. Sign APK
echo 5. Complete Process (All steps)
echo 6. Backup Configuration
echo 7. Validate Configuration
echo 8. Exit
echo.
set /p choice="Select an option (1-8): "

if "%choice%"=="1" goto DECOMPILE
if "%choice%"=="2" goto MODIFY_CONFIG
if "%choice%"=="3" goto RECOMPILE
if "%choice%"=="4" goto SIGN_APK
if "%choice%"=="5" goto COMPLETE_PROCESS
if "%choice%"=="6" goto BACKUP_CONFIG
if "%choice%"=="7" goto VALIDATE_CONFIG
if "%choice%"=="8" goto EXIT
goto MENU

:DECOMPILE
echo.
echo Decompiling APK...
set /p apk_path="Enter APK file path: "
if not exist "%apk_path%" (
    echo APK file not found!
    goto MENU
)

if not exist "%DECOMPILE_DIR%" mkdir "%DECOMPILE_DIR%"

echo Using apktool to decompile...
apktool d "%apk_path%" -o "%DECOMPILE_DIR%"

if %ERRORLEVEL% EQU 0 (
    echo APK decompiled successfully to %DECOMPILE_DIR%
) else (
    echo Failed to decompile APK
)
goto MENU

:MODIFY_CONFIG
echo.
echo Modifying Configuration...
cd /d "%DECOMPILE_DIR%"

echo Current configuration files:
if exist "assets\config.json" (
    echo - config.json found
    type "assets\config.json"
) else (
    echo - config.json not found
)

echo.
set /p app_name="Enter new app name (or press Enter to skip): "
set /p app_url="Enter new webview URL (or press Enter to skip): "
set /p app_id="Enter new application ID (or press Enter to skip): "

if not "%app_name%"=="" (
    echo Updating app name to: %app_name%
)
if not "%app_url%"=="" (
    echo Updating webview URL to: %app_url%
)
if not "%app_id%"=="" (
    echo Updating application ID to: %app_id%
)

:: Use PowerShell to modify JSON
powershell -Command "& { $json = Get-Content 'assets\config.json' | ConvertFrom-Json; if ('%app_name%' -ne '') { $json.appName = '%app_name%' }; if ('%app_url%' -ne '') { $json.webviewUrl = '%app_url%' }; if ('%app_id%' -ne '') { $json.applicationId = '%app_id%' }; $json.lastModified = Get-Date -Format 'yyyy-MM-dd'; $json.modificationComment = 'Modified via post-build script'; $json | ConvertTo-Json -Depth 10 | Set-Content 'assets\config.json' }"

echo Configuration updated successfully!
goto MENU

:RECOMPILE
echo.
echo Recompiling APK...
if not exist "%DECOMPILE_DIR%" (
    echo Decompiled directory not found! Please decompile an APK first.
    goto MENU
)

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo Using apktool to recompile...
apktool b "%DECOMPILE_DIR%" -o "%OUTPUT_DIR%\app-unsigned.apk"

if %ERRORLEVEL% EQU 0 (
    echo APK recompiled successfully to %OUTPUT_DIR%\app-unsigned.apk
) else (
    echo Failed to recompile APK
)
goto MENU

:SIGN_APK
echo.
echo Signing APK...
if not exist "%OUTPUT_DIR%\app-unsigned.apk" (
    echo Unsigned APK not found! Please recompile first.
    goto MENU
)

echo Generating keystore if not exists...
if not exist "%OUTPUT_DIR%\my-release-key.keystore" (
    keytool -genkey -v -keystore "%OUTPUT_DIR%\my-release-key.keystore" -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
)

echo Signing APK...
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "%OUTPUT_DIR%\my-release-key.keystore" "%OUTPUT_DIR%\app-unsigned.apk" my-key-alias

echo Zipaligning APK...
zipalign -v 4 "%OUTPUT_DIR%\app-unsigned.apk" "%OUTPUT_DIR%\app-final.apk"

if %ERRORLEVEL% EQU 0 (
    echo APK signed and aligned successfully: %OUTPUT_DIR%\app-final.apk
) else (
    echo Failed to sign APK
)
goto MENU

:COMPLETE_PROCESS
echo.
echo Running complete process...
set /p apk_path="Enter APK file path: "
if not exist "%apk_path%" (
    echo APK file not found!
    goto MENU
)

call :DECOMPILE_SILENT "%apk_path%"
call :MODIFY_CONFIG_SILENT
call :RECOMPILE_SILENT
call :SIGN_APK_SILENT

echo Complete process finished!
goto MENU

:BACKUP_CONFIG
echo.
echo Backing up configuration...
cd /d "%PROJECT_DIR%"
dart "scripts\post_build_config.dart" backup
goto MENU

:VALIDATE_CONFIG
echo.
echo Validating configuration...
cd /d "%PROJECT_DIR%"
dart "scripts\post_build_config.dart" validate
goto MENU

:DECOMPILE_SILENT
if not exist "%DECOMPILE_DIR%" mkdir "%DECOMPILE_DIR%"
apktool d "%~1" -o "%DECOMPILE_DIR%" >nul 2>&1
exit /b

:MODIFY_CONFIG_SILENT
:: Silent modification with default values
cd /d "%DECOMPILE_DIR%"
powershell -Command "& { $json = Get-Content 'assets\config.json' | ConvertFrom-Json; $json.lastModified = Get-Date -Format 'yyyy-MM-dd'; $json.modificationComment = 'Auto-modified via complete process'; $json | ConvertTo-Json -Depth 10 | Set-Content 'assets\config.json' }" >nul 2>&1
exit /b

:RECOMPILE_SILENT
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
apktool b "%DECOMPILE_DIR%" -o "%OUTPUT_DIR%\app-unsigned.apk" >nul 2>&1
exit /b

:SIGN_APK_SILENT
if not exist "%OUTPUT_DIR%\my-release-key.keystore" (
    echo mypassword | keytool -genkey -v -keystore "%OUTPUT_DIR%\my-release-key.keystore" -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Web2Appify, OU=Development, O=Web2Appify, L=City, S=State, C=US" -storepass mypassword -keypass mypassword >nul 2>&1
)
echo mypassword | jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "%OUTPUT_DIR%\my-release-key.keystore" -storepass mypassword "%OUTPUT_DIR%\app-unsigned.apk" my-key-alias >nul 2>&1
zipalign -v 4 "%OUTPUT_DIR%\app-unsigned.apk" "%OUTPUT_DIR%\app-final.apk" >nul 2>&1
exit /b

:EXIT
echo Goodbye!
exit /b
