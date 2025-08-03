# Configuration Guide

## How to customize your app

Edit the `assets/config.json` file to change your app settings:

```json
{
  "appName": "Your App Name",
  "applicationId": "com.yourcompany.yourapp",
  "webviewUrl": "https://your-website.com"
}
```

### Configuration Options:

- **appName**: The display name of your application
- **applicationId**: The unique identifier for your app (used for app stores)
- **webviewUrl**: The website URL to load in the webview

### Examples:

For a business website:

```json
{
  "appName": "My Business",
  "applicationId": "com.mybusiness.app",
  "webviewUrl": "https://www.mybusiness.com"
}
```

For a blog:

```json
{
  "appName": "My Blog",
  "applicationId": "com.myblog.reader",
  "webviewUrl": "https://myblog.wordpress.com"
}
```

After making changes, rebuild your app to see the updates.
