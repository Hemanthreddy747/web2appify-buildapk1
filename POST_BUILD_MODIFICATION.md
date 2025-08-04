# Post-Build APK Configuration Modification

This system allows you to modify the configuration of your Web2Appify app after building the APK. You can decompile the APK, edit the configuration files, and then recompile and sign the APK with the new settings.

## Files Overview

### Configuration Files

- `assets/config.json` - Main application configuration (enhanced with 30+ configurable options)
- `assets/build_config.json` - Advanced build and runtime configuration
- `scripts/post_build_config.dart` - Dart utility for configuration manipulation
- `post_build_modifier.bat` - Windows batch script for complete workflow
- `post_build_modifier.ps1` - PowerShell script with advanced features

### Enhanced Configuration Options

The `config.json` now supports extensive customization:

```json
{
  "appName": "Web2Appify1",
  "applicationId": "com.web2appify.app",
  "webviewUrl": "https://www.billingselling.com",
  "appVersion": "1.0.0",
  "buildNumber": "1",
  "allowClearCache": true,
  "allowDownloads": true,
  "allowLocation": true,
  "allowCamera": true,
  "allowMicrophone": true,
  "userAgent": "",
  "splashScreenDelay": 3000,
  "orientation": "portrait",
  "statusBarColor": "#FFFFFF",
  "navigationBarColor": "#000000",
  "loadingMessage": "Loading...",
  "errorMessage": "Failed to load content",
  "offlineMessage": "No internet connection",
  "pullToRefresh": true,
  "zoomEnabled": false,
  "showProgressBar": true,
  "customCss": "",
  "customJs": "",
  "deepLinkingEnabled": false,
  "backButtonAction": "goBack",
  "exitDialogEnabled": true,
  "exitDialogTitle": "Exit App",
  "exitDialogMessage": "Do you want to exit the app?",
  "configVersion": "1.0",
  "lastModified": "2025-08-03",
  "modificationComment": "Initial configuration"
}
```

## Prerequisites

Before using the post-build modification tools, ensure you have:

1. **Java Development Kit (JDK)** - Required for jarsigner and keytool
2. **Android SDK Build Tools** - Required for zipalign
3. **APKTool** - Required for decompiling and recompiling APKs
4. **Dart SDK** - Required for running Dart scripts

### Installing APKTool

1. Download apktool from: https://ibotpeaches.github.io/Apktool/
2. Place `apktool.jar` and `apktool.bat` (Windows) in your PATH
3. Verify installation: `apktool version`

### Installing Android SDK Build Tools

1. Install Android Studio or Android SDK Command Line Tools
2. Add `<sdk>/build-tools/<version>/` to your PATH
3. Verify zipalign: `zipalign`

## Usage Methods

### Method 1: Interactive Menu (Recommended for beginners)

**Windows Batch:**

```cmd
post_build_modifier.bat
```

**PowerShell:**

```powershell
.\post_build_modifier.ps1
```

Follow the interactive menu to:

1. Decompile your APK
2. Modify configuration
3. Recompile APK
4. Sign the final APK

### Method 2: Command Line (Advanced users)

**PowerShell with parameters:**

```powershell
.\post_build_modifier.ps1 -ApkPath "path\to\your\app.apk" -AppName "New App Name" -AppUrl "https://newurl.com" -AppId "com.new.package" -AutoMode
```

**Dart script:**

```cmd
cd scripts
dart post_build_config.dart backup
dart post_build_config.dart validate
dart post_build_config.dart modify
```

### Method 3: Manual Process

1. **Decompile APK:**

   ```cmd
   apktool d your-app.apk -o decompiled
   ```

2. **Edit Configuration:**

   - Navigate to `decompiled/assets/`
   - Edit `config.json` with your desired settings
   - Optionally edit `build_config.json`

3. **Recompile APK:**

   ```cmd
   apktool b decompiled -o app-unsigned.apk
   ```

4. **Sign APK:**

   ```cmd
   # Generate keystore (one time)
   keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000

   # Sign APK
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore app-unsigned.apk my-key-alias

   # Align APK
   zipalign -v 4 app-unsigned.apk app-final.apk
   ```

## Configuration Modification Examples

### Change App Name and URL

```json
{
  "appName": "My Custom App",
  "webviewUrl": "https://mycustomsite.com"
}
```

### Enable Additional Features

```json
{
  "allowCamera": true,
  "allowMicrophone": true,
  "allowLocation": true,
  "pullToRefresh": true,
  "zoomEnabled": true
}
```

### Customize Appearance

```json
{
  "statusBarColor": "#2196F3",
  "navigationBarColor": "#1976D2",
  "loadingMessage": "Please wait...",
  "splashScreenDelay": 5000
}
```

### Add Custom CSS/JavaScript

```json
{
  "customCss": "body { background: #f0f0f0; }",
  "customJs": "console.log('App loaded');"
}
```

## Advanced Configuration with build_config.json

The `build_config.json` file provides additional configuration options:

- **Build Settings:** SDK versions, package info
- **WebView Settings:** User agent, JavaScript settings
- **App Settings:** Theme, colors, display options
- **Permissions:** Runtime permissions control
- **Features:** Enable/disable app features
- **Security:** Obfuscation, certificate pinning
- **Metadata:** Version tracking, modification history

## Best Practices

1. **Always backup** your original APK before modification
2. **Validate configuration** after making changes
3. **Test thoroughly** on target devices after modification
4. **Keep track** of modifications using the metadata fields
5. **Use version control** for your configuration files

## Troubleshooting

### Common Issues

**APKTool not found:**

- Ensure apktool is in your PATH
- Try using full path to apktool

**Signing failed:**

- Verify Java is installed and in PATH
- Check keystore password
- Ensure keystore file exists

**Recompilation failed:**

- Check decompiled files are intact
- Verify JSON syntax in config files
- Try cleaning and rebuilding

**APK won't install:**

- Enable "Unknown sources" in Android settings
- Check if app is already installed (uninstall first)
- Verify APK is properly signed

### Getting Help

1. Run validation: `dart scripts/post_build_config.dart validate`
2. Check logs in the decompiled directory
3. Verify all dependencies are properly installed
4. Test with a simple configuration change first

## Security Considerations

- Keep your keystore files secure
- Don't commit keystore passwords to version control
- Use strong passwords for production keystores
- Consider using Android App Bundle for production

## Automation

You can integrate this process into your CI/CD pipeline:

```powershell
# Automated build with custom config
.\post_build_modifier.ps1 -ApkPath "build/app.apk" -AppName "$env:APP_NAME" -AppUrl "$env:APP_URL" -AutoMode
```

This system provides maximum flexibility for customizing your Web2Appify applications after build time, making it easy to create multiple variants from a single APK.
