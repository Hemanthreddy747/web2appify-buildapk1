import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final String appName;
  final String applicationId;
  final String webviewUrl;
  final String appVersion;
  final String buildNumber;
  final bool allowClearCache;
  final bool allowDownloads;
  final bool allowLocation;
  final bool allowCamera;
  final bool allowMicrophone;
  final String userAgent;
  final int splashScreenDelay;
  final String orientation;
  final String statusBarColor;
  final String navigationBarColor;
  final String loadingMessage;
  final String errorMessage;
  final String offlineMessage;
  final bool pullToRefresh;
  final bool zoomEnabled;
  final bool showProgressBar;
  final String customCss;
  final String customJs;
  final bool deepLinkingEnabled;
  final String backButtonAction;
  final bool exitDialogEnabled;
  final String exitDialogTitle;
  final String exitDialogMessage;
  final String configVersion;
  final String lastModified;
  final String modificationComment;

  AppConfig({
    required this.appName,
    required this.applicationId,
    required this.webviewUrl,
    required this.appVersion,
    required this.buildNumber,
    required this.allowClearCache,
    required this.allowDownloads,
    required this.allowLocation,
    required this.allowCamera,
    required this.allowMicrophone,
    required this.userAgent,
    required this.splashScreenDelay,
    required this.orientation,
    required this.statusBarColor,
    required this.navigationBarColor,
    required this.loadingMessage,
    required this.errorMessage,
    required this.offlineMessage,
    required this.pullToRefresh,
    required this.zoomEnabled,
    required this.showProgressBar,
    required this.customCss,
    required this.customJs,
    required this.deepLinkingEnabled,
    required this.backButtonAction,
    required this.exitDialogEnabled,
    required this.exitDialogTitle,
    required this.exitDialogMessage,
    required this.configVersion,
    required this.lastModified,
    required this.modificationComment,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] ?? 'buildapk1',
      applicationId: json['applicationId'] ?? 'com.buildapk1.app',
      webviewUrl: json['webviewUrl'] ?? 'https://www.web2appify.com',
      appVersion: json['appVersion'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? '1',
      allowClearCache: json['allowClearCache'] ?? true,
      allowDownloads: json['allowDownloads'] ?? true,
      allowLocation: json['allowLocation'] ?? false,
      allowCamera: json['allowCamera'] ?? false,
      allowMicrophone: json['allowMicrophone'] ?? false,
      userAgent: json['userAgent'] ?? '',
      splashScreenDelay: json['splashScreenDelay'] ?? 3000,
      orientation: json['orientation'] ?? 'portrait',
      statusBarColor: json['statusBarColor'] ?? '#FFFFFF',
      navigationBarColor: json['navigationBarColor'] ?? '#000000',
      loadingMessage: json['loadingMessage'] ?? 'Loading...',
      errorMessage:
          json['errorMessage'] ??
          'Network error. Please check your internet connection and try again.',
      offlineMessage: json['offlineMessage'] ?? 'No internet connection',
      pullToRefresh: json['pullToRefresh'] ?? true,
      zoomEnabled: json['zoomEnabled'] ?? false,
      showProgressBar: json['showProgressBar'] ?? true,
      customCss: json['customCss'] ?? '',
      customJs: json['customJs'] ?? '',
      deepLinkingEnabled: json['deepLinkingEnabled'] ?? false,
      backButtonAction: json['backButtonAction'] ?? 'goBack',
      exitDialogEnabled: json['exitDialogEnabled'] ?? true,
      exitDialogTitle: json['exitDialogTitle'] ?? 'Exit App',
      exitDialogMessage:
          json['exitDialogMessage'] ?? 'Do you want to exit the app?',
      configVersion: json['configVersion'] ?? '1.0',
      lastModified: json['lastModified'] ?? '',
      modificationComment: json['modificationComment'] ?? '',
    );
  }

  static Future<AppConfig> loadConfig() async {
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> data = json.decode(response);
      return AppConfig.fromJson(data);
    } catch (e) {
      // Return default config if file loading fails
      return AppConfig(
        appName: 'buildapk1',
        applicationId: 'com.buildapk1.app',
        webviewUrl: 'https://www.web2appify.com',
        appVersion: '1.0.0',
        buildNumber: '1',
        allowClearCache: true,
        allowDownloads: true,
        allowLocation: false,
        allowCamera: false,
        allowMicrophone: false,
        userAgent: '',
        splashScreenDelay: 3000,
        orientation: 'portrait',
        statusBarColor: '#FFFFFF',
        navigationBarColor: '#000000',
        loadingMessage: 'Loading...',
        errorMessage:
            'Network error. Please check your internet connection and try again.',
        offlineMessage: 'No internet connection',
        pullToRefresh: true,
        zoomEnabled: false,
        showProgressBar: true,
        customCss: '',
        customJs: '',
        deepLinkingEnabled: false,
        backButtonAction: 'goBack',
        exitDialogEnabled: true,
        exitDialogTitle: 'Exit App',
        exitDialogMessage: 'Do you want to exit the app?',
        configVersion: '1.0',
        lastModified: '',
        modificationComment: '',
      );
    }
  }
}

class BuildConfig {
  final Map<String, dynamic> buildConfig;
  final Map<String, dynamic> webviewSettings;
  final Map<String, dynamic> appSettings;
  final Map<String, dynamic> permissions;
  final Map<String, dynamic> features;
  final Map<String, dynamic> security;
  final Map<String, dynamic> metadata;

  BuildConfig({
    required this.buildConfig,
    required this.webviewSettings,
    required this.appSettings,
    required this.permissions,
    required this.features,
    required this.security,
    required this.metadata,
  });

  factory BuildConfig.fromJson(Map<String, dynamic> json) {
    return BuildConfig(
      buildConfig: json['buildConfig'] ?? {},
      webviewSettings: json['webviewSettings'] ?? {},
      appSettings: json['appSettings'] ?? {},
      permissions: json['permissions'] ?? {},
      features: json['features'] ?? {},
      security: json['security'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }

  static Future<BuildConfig> loadBuildConfig() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/build_config.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      return BuildConfig.fromJson(data);
    } catch (e) {
      return BuildConfig(
        buildConfig: {},
        webviewSettings: {},
        appSettings: {},
        permissions: {},
        features: {},
        security: {},
        metadata: {},
      );
    }
  }
}
