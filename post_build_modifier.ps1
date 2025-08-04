# Web2Appify Post-Build Configuration Tool
# PowerShell Version

param(
    [string]$ApkPath,
    [string]$AppName,
    [string]$AppUrl,
    [string]$AppId,
    [switch]$AutoMode,
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$AssetsDir = Join-Path $ProjectDir "assets"
$DecompileDir = Join-Path $ProjectDir "decompiled"
$OutputDir = Join-Path $ProjectDir "output"

function Show-Help {
    Write-Host "Web2Appify Post-Build Configuration Tool" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\post_build_modifier.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -ApkPath <path>    Path to the APK file to modify"
    Write-Host "  -AppName <name>    New app name"
    Write-Host "  -AppUrl <url>      New webview URL"
    Write-Host "  -AppId <id>        New application ID"
    Write-Host "  -AutoMode          Run in automatic mode"
    Write-Host "  -Help              Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\post_build_modifier.ps1 -ApkPath 'app.apk' -AppName 'My App' -AppUrl 'https://example.com'"
    Write-Host "  .\post_build_modifier.ps1 -AutoMode"
}

function Test-Dependencies {
    $missing = @()
    
    try { apktool.bat version | Out-Null } catch { $missing += "apktool" }
    try { keytool -help | Out-Null } catch { $missing += "keytool (Java)" }
    try { jarsigner -help | Out-Null } catch { $missing += "jarsigner (Java)" }
    try { zipalign | Out-Null } catch { $missing += "zipalign (Android SDK)" }
    
    if ($missing.Count -gt 0) {
        Write-Host "Missing dependencies: $($missing -join ', ')" -ForegroundColor Red
        Write-Host "Please install the missing tools before proceeding." -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Decompile-APK {
    param([string]$ApkPath)
    
    Write-Host "Decompiling APK: $ApkPath" -ForegroundColor Green
    
    if (-not (Test-Path $ApkPath)) {
        Write-Host "APK file not found: $ApkPath" -ForegroundColor Red
        return $false
    }
    
    if (Test-Path $DecompileDir) {
        Remove-Item $DecompileDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $DecompileDir -Force | Out-Null
    
    $result = Start-Process -FilePath "apktool.bat" -ArgumentList "d", "`"$ApkPath`"", "-o", "`"$DecompileDir`"" -Wait -PassThru -NoNewWindow
    
    if ($result.ExitCode -eq 0) {
        Write-Host "APK decompiled successfully" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Failed to decompile APK" -ForegroundColor Red
        return $false
    }
}

function Modify-Configuration {
    param(
        [string]$AppName,
        [string]$AppUrl,
        [string]$AppId
    )
    
    Write-Host "Modifying configuration..." -ForegroundColor Green
    
    $configPath = Join-Path $DecompileDir "assets\config.json"
    
    if (-not (Test-Path $configPath)) {
        Write-Host "Configuration file not found: $configPath" -ForegroundColor Red
        return $false
    }
    
    try {
        $config = Get-Content $configPath | ConvertFrom-Json
        
        if ($AppName) { $config.appName = $AppName }
        if ($AppUrl) { $config.webviewUrl = $AppUrl }
        if ($AppId) { $config.applicationId = $AppId }
        
        $config.lastModified = Get-Date -Format "yyyy-MM-dd"
        $config.modificationComment = "Modified via PowerShell post-build script"
        
        $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
        
        Write-Host "Configuration updated successfully" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to modify configuration: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Recompile-APK {
    Write-Host "Recompiling APK..." -ForegroundColor Green
    
    if (-not (Test-Path $DecompileDir)) {
        Write-Host "Decompiled directory not found" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    $outputApk = Join-Path $OutputDir "app-unsigned.apk"
    
    $result = Start-Process -FilePath "apktool.bat" -ArgumentList "b", "`"$DecompileDir`"", "-o", "`"$outputApk`"" -Wait -PassThru -NoNewWindow
    
    if ($result.ExitCode -eq 0) {
        Write-Host "APK recompiled successfully: $outputApk" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Failed to recompile APK" -ForegroundColor Red
        return $false
    }
}

function Sign-APK {
    Write-Host "Signing APK..." -ForegroundColor Green
    
    $unsignedApk = Join-Path $OutputDir "app-unsigned.apk"
    $finalApk = Join-Path $OutputDir "app-final.apk"
    $keystore = Join-Path $OutputDir "my-release-key.keystore"
    
    if (-not (Test-Path $unsignedApk)) {
        Write-Host "Unsigned APK not found" -ForegroundColor Red
        return $false
    }
    
    # Generate keystore if it doesn't exist
    if (-not (Test-Path $keystore)) {
        Write-Host "Generating keystore..." -ForegroundColor Yellow
        $keystoreArgs = @(
            "-genkey", "-v", "-keystore", "`"$keystore`"",
            "-alias", "my-key-alias", "-keyalg", "RSA", "-keysize", "2048",
            "-validity", "10000", "-storepass", "mypassword", "-keypass", "mypassword",
            "-dname", "CN=Web2Appify, OU=Development, O=Web2Appify, L=City, S=State, C=US"
        )
        Start-Process -FilePath "keytool" -ArgumentList $keystoreArgs -Wait -NoNewWindow | Out-Null
    }
    
    # Sign APK
    $signArgs = @(
        "-verbose", "-sigalg", "SHA1withRSA", "-digestalg", "SHA1",
        "-keystore", "`"$keystore`"", "-storepass", "mypassword",
        "`"$unsignedApk`"", "my-key-alias"
    )
    Start-Process -FilePath "jarsigner" -ArgumentList $signArgs -Wait -NoNewWindow | Out-Null
    
    # Zipalign APK
    $alignArgs = @("-v", "4", "`"$unsignedApk`"", "`"$finalApk`"")
    $result = Start-Process -FilePath "zipalign" -ArgumentList $alignArgs -Wait -PassThru -NoNewWindow
    
    if ($result.ExitCode -eq 0) {
        Write-Host "APK signed and aligned successfully: $finalApk" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Failed to sign APK" -ForegroundColor Red
        return $false
    }
}

function Backup-Configuration {
    Write-Host "Backing up configuration..." -ForegroundColor Green
    
    Push-Location $ProjectDir
    try {
        dart "scripts\post_build_config.dart" backup
    } finally {
        Pop-Location
    }
}

function Validate-Configuration {
    Write-Host "Validating configuration..." -ForegroundColor Green
    
    Push-Location $ProjectDir
    try {
        dart "scripts\post_build_config.dart" validate
    } finally {
        Pop-Location
    }
}

function Show-Menu {
    while ($true) {
        Write-Host ""
        Write-Host "Web2Appify Post-Build Configuration Tool" -ForegroundColor Cyan
        Write-Host "========================================="
        Write-Host ""
        Write-Host "1. Decompile APK"
        Write-Host "2. Modify Configuration"
        Write-Host "3. Recompile APK"
        Write-Host "4. Sign APK"
        Write-Host "5. Complete Process (All steps)"
        Write-Host "6. Backup Configuration"
        Write-Host "7. Validate Configuration"
        Write-Host "8. Exit"
        Write-Host ""
        
        $choice = Read-Host "Select an option (1-8)"
        
        switch ($choice) {
            "1" {
                $apkPath = Read-Host "Enter APK file path"
                Decompile-APK -ApkPath $apkPath
            }
            "2" {
                $appName = Read-Host "Enter new app name (or press Enter to skip)"
                $appUrl = Read-Host "Enter new webview URL (or press Enter to skip)"
                $appId = Read-Host "Enter new application ID (or press Enter to skip)"
                
                $appName = if ($appName) { $appName } else { $null }
                $appUrl = if ($appUrl) { $appUrl } else { $null }
                $appId = if ($appId) { $appId } else { $null }
                
                Modify-Configuration -AppName $appName -AppUrl $appUrl -AppId $appId
            }
            "3" { Recompile-APK }
            "4" { Sign-APK }
            "5" {
                $apkPath = Read-Host "Enter APK file path"
                if (Decompile-APK -ApkPath $apkPath) {
                    if (Modify-Configuration) {
                        if (Recompile-APK) {
                            Sign-APK
                        }
                    }
                }
            }
            "6" { Backup-Configuration }
            "7" { Validate-Configuration }
            "8" { return }
            default { Write-Host "Invalid option. Please try again." -ForegroundColor Red }
        }
    }
}

# Main execution
if ($Help) {
    Show-Help
    return
}

if (-not (Test-Dependencies)) {
    return
}

if ($AutoMode -and $ApkPath) {
    Write-Host "Running in automatic mode..." -ForegroundColor Cyan
    
    if (Decompile-APK -ApkPath $ApkPath) {
        if (Modify-Configuration -AppName $AppName -AppUrl $AppUrl -AppId $AppId) {
            if (Recompile-APK) {
                Sign-APK
            }
        }
    }
} elseif ($ApkPath) {
    # Command line mode
    if (Decompile-APK -ApkPath $ApkPath) {
        Modify-Configuration -AppName $AppName -AppUrl $AppUrl -AppId $AppId
    }
} else {
    # Interactive mode
    Show-Menu
}
