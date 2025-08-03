import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final String appName;
  final String applicationId;
  final String webviewUrl;

  AppConfig({
    required this.appName,
    required this.applicationId,
    required this.webviewUrl,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] ?? 'Default App',
      applicationId: json['applicationId'] ?? 'com.default.app',
      webviewUrl: json['webviewUrl'] ?? 'https://www.google.com',
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
        appName: 'Default App',
        applicationId: 'com.default.app',
        webviewUrl: 'https://www.google.com',
      );
    }
  }
}
