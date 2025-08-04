# Configuration Impact Guide

This document shows exactly how each configuration value in `config.json` affects the application behavior.

## Visual Changes (Immediately Visible)

### App Identity

- **`appName`**: Changes the app title in the title bar and splash screen
- **`webviewUrl`**: Changes the website loaded in the webview

### Colors & Appearance

- **`statusBarColor`**: Changes the color of the Android status bar (top bar with time/battery)
- **`navigationBarColor`**: Changes the color of the Android navigation bar (bottom bar with back/home buttons)

### Loading & Splash Screen

- **`splashScreenDelay`**: Controls how long the splash screen shows (in milliseconds)
- **`loadingMessage`**: Text shown while webview is loading
- **`showProgressBar`**: Shows/hides the loading animation

## Functional Changes (Behavior)

### WebView Features

- **`pullToRefresh`**: Enables/disables pull-down-to-refresh gesture
- **`zoomEnabled`**: Allows/prevents pinch-to-zoom in webview
- **`userAgent`**: Changes the browser user agent string sent to websites

### Navigation & Back Button

- **`backButtonAction`**:
  - `"goBack"`: Android back button navigates back in webview history
  - Other values: Android back button shows exit dialog
- **`exitDialogEnabled`**: Shows/hides exit confirmation dialog
- **`exitDialogTitle`**: Title text of exit dialog
- **`exitDialogMessage`**: Message text of exit dialog

### Error Handling

- **`errorMessage`**: Text shown when webview fails to load
- **`offlineMessage`**: Text shown when there's no internet connection

### Custom Code Injection

- **`customCss`**: CSS styles injected into every webpage
- **`customJs`**: JavaScript code executed on every webpage

### Device Orientation

- **`orientation`**:
  - `"portrait"`: Locks app to portrait mode
  - `"landscape"`: Locks app to landscape mode
  - Other values: Allows both orientations

### Permissions (Future Use)

- **`allowCamera`**: Enable/disable camera access
- **`allowMicrophone`**: Enable/disable microphone access
- **`allowLocation`**: Enable/disable GPS location access
- **`allowDownloads`**: Enable/disable file downloads
- **`allowClearCache`**: Enable/disable cache clearing

## Testing Changes

### Method 1: Use Test Script

```cmd
test_config.bat
```

### Method 2: Manual Testing

1. Edit `assets/config.json`
2. Run: `flutter run`
3. Observe changes in the app

### Method 3: APK Testing

1. Edit `assets/config.json`
2. Build: `flutter build apk --release`
3. Install and test the APK

## Example Configurations

### Minimal Configuration

```json
{
  "appName": "My App",
  "webviewUrl": "https://www.example.com"
}
```

### Gaming App Configuration

```json
{
  "appName": "Game Portal",
  "webviewUrl": "https://www.gamesite.com",
  "orientation": "landscape",
  "statusBarColor": "#000000",
  "navigationBarColor": "#000000",
  "zoomEnabled": false,
  "pullToRefresh": false,
  "exitDialogEnabled": true,
  "splashScreenDelay": 1000
}
```

### News App Configuration

```json
{
  "appName": "News Reader",
  "webviewUrl": "https://www.newssite.com",
  "orientation": "portrait",
  "statusBarColor": "#1976D2",
  "navigationBarColor": "#1565C0",
  "pullToRefresh": true,
  "zoomEnabled": true,
  "loadingMessage": "Loading latest news...",
  "splashScreenDelay": 2500
}
```

### E-commerce App Configuration

```json
{
  "appName": "Shop Now",
  "webviewUrl": "https://www.store.com",
  "statusBarColor": "#4CAF50",
  "navigationBarColor": "#388E3C",
  "pullToRefresh": true,
  "allowDownloads": true,
  "exitDialogTitle": "Leave Store",
  "exitDialogMessage": "Are you sure you want to leave the store?",
  "customCss": ".promo-banner { background: #ff6b6b !important; }"
}
```

## Verification Checklist

After changing configuration, verify these work:

- [ ] App name appears correctly in splash screen
- [ ] Status bar color matches your setting
- [ ] Navigation bar color matches your setting
- [ ] Splash screen duration feels right
- [ ] Loading message appears when loading pages
- [ ] Pull-to-refresh works (if enabled) or doesn't work (if disabled)
- [ ] Zoom works (if enabled) or doesn't work (if disabled)
- [ ] Back button behavior matches your setting
- [ ] Exit dialog appears with correct title and message (if enabled)
- [ ] Custom CSS styles are applied to web pages
- [ ] Custom JavaScript executes on web pages

## Common Issues

### Changes Not Appearing

1. **Hot reload doesn't work for config changes** - Stop and restart the app
2. **Old config cached** - Run `flutter clean` then `flutter run`
3. **JSON syntax error** - Validate JSON format

### Colors Not Working

1. **Invalid color format** - Use hex format like "#FF0000" (with #)
2. **Permissions** - Some Android versions restrict status bar changes

### WebView Issues

1. **Custom CSS/JS not working** - Check browser console for errors
2. **URL not loading** - Verify internet connection and URL validity

## Build & Distribution

When you modify config.json and want to distribute:

1. **For development**: `flutter run`
2. **For testing**: `flutter build apk --debug`
3. **For production**: `flutter build apk --release`

The configuration is embedded in the APK, so recipients will see your customized app without needing the source code.
