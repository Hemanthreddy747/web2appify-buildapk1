# PowerShell script to update app name and build APK
param(
    [switch]$BuildOnly,
    [switch]$UpdateOnly,
    [switch]$Help
)

if ($Help) {
    Write-Host "App Name Update and Build Script" -ForegroundColor Cyan
    Write-Host "================================="
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\build_apk_with_config.ps1        # Update app name and build APK"
    Write-Host "  .\build_apk_with_config.ps1 -UpdateOnly   # Only update app name"
    Write-Host "  .\build_apk_with_config.ps1 -BuildOnly    # Only build APK (no name update)"
    Write-Host "  .\build_apk_with_config.ps1 -Help         # Show this help"
    Write-Host ""
    Write-Host "This script ensures the app icon shows the name from config.json"
    return
}

Write-Host "App Name Update and Build Script" -ForegroundColor Cyan
Write-Host "================================="
Write-Host ""

$ErrorActionPreference = "Stop"

try {
    if (-not $BuildOnly) {
        Write-Host "Step 1: Updating app name from config.json..." -ForegroundColor Green
        dart "scripts\update_app_name.dart"
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to update app name"
        }
        
        Write-Host "App name updated successfully!" -ForegroundColor Green
    }
    
    if ($UpdateOnly) {
        Write-Host "Update complete. Use -BuildOnly to build APK with updated name." -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    Write-Host "Step 2: Cleaning Flutter build cache..." -ForegroundColor Green
    flutter clean
    
    Write-Host ""
    Write-Host "Step 3: Getting Flutter dependencies..." -ForegroundColor Green
    flutter pub get
    
    Write-Host ""
    Write-Host "Step 4: Building APK with updated app name..." -ForegroundColor Green
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ APK built successfully!" -ForegroundColor Green
        Write-Host "The app icon will now show the name from config.json" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    } else {
        throw "Failed to build APK"
    }
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
