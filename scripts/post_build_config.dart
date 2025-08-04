#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

class PostBuildConfigModifier {
  static const String configPath = 'assets/config.json';
  static const String buildConfigPath = 'assets/build_config.json';

  /// Modify configuration after APK is decompiled
  static Future<void> modifyConfig({
    String? appName,
    String? applicationId,
    String? webviewUrl,
    String? appVersion,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      // Load existing config
      final configFile = File(configPath);
      Map<String, dynamic> config = {};

      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        config = json.decode(content);
      }

      // Update fields
      if (appName != null) config['appName'] = appName;
      if (applicationId != null) config['applicationId'] = applicationId;
      if (webviewUrl != null) config['webviewUrl'] = webviewUrl;
      if (appVersion != null) config['appVersion'] = appVersion;

      // Add custom fields
      if (customFields != null) {
        config.addAll(customFields);
      }

      // Update metadata
      config['lastModified'] = DateTime.now().toIso8601String();
      config['modificationComment'] = 'Modified after build';

      // Write back to file
      final encoder = JsonEncoder.withIndent('  ');
      await configFile.writeAsString(encoder.convert(config));

      print('Configuration updated successfully');
    } catch (e) {
      print('Error modifying config: $e');
    }
  }

  /// Modify build configuration
  static Future<void> modifyBuildConfig({
    String? packageName,
    String? url,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? features,
  }) async {
    try {
      final buildConfigFile = File(buildConfigPath);
      Map<String, dynamic> buildConfig = {};

      if (await buildConfigFile.exists()) {
        final content = await buildConfigFile.readAsString();
        buildConfig = json.decode(content);
      }

      // Update build config
      if (packageName != null) {
        buildConfig['buildConfig'] ??= {};
        buildConfig['buildConfig']['packageName'] = packageName;
      }

      if (url != null) {
        buildConfig['webviewSettings'] ??= {};
        buildConfig['webviewSettings']['url'] = url;
      }

      if (permissions != null) {
        buildConfig['permissions'] ??= {};
        buildConfig['permissions'].addAll(permissions);
      }

      if (features != null) {
        buildConfig['features'] ??= {};
        buildConfig['features'].addAll(features);
      }

      // Update metadata
      buildConfig['metadata'] ??= {};
      buildConfig['metadata']['lastModified'] = DateTime.now()
          .toIso8601String();
      buildConfig['metadata']['modifiedBy'] = 'postBuildScript';

      // Write back to file
      final encoder = JsonEncoder.withIndent('  ');
      await buildConfigFile.writeAsString(encoder.convert(buildConfig));

      print('Build configuration updated successfully');
    } catch (e) {
      print('Error modifying build config: $e');
    }
  }

  /// Backup current configuration
  static Future<void> backupConfig() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Backup main config
      final configFile = File(configPath);
      if (await configFile.exists()) {
        await configFile.copy('${configPath}.backup.$timestamp');
      }

      // Backup build config
      final buildConfigFile = File(buildConfigPath);
      if (await buildConfigFile.exists()) {
        await buildConfigFile.copy('${buildConfigPath}.backup.$timestamp');
      }

      print('Configuration backed up with timestamp: $timestamp');
    } catch (e) {
      print('Error backing up config: $e');
    }
  }

  /// Validate configuration format
  static Future<bool> validateConfig() async {
    try {
      // Validate main config
      final configFile = File(configPath);
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        json.decode(content); // Will throw if invalid JSON
      }

      // Validate build config
      final buildConfigFile = File(buildConfigPath);
      if (await buildConfigFile.exists()) {
        final content = await buildConfigFile.readAsString();
        json.decode(content); // Will throw if invalid JSON
      }

      print('Configuration validation passed');
      return true;
    } catch (e) {
      print('Configuration validation failed: $e');
      return false;
    }
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart update_config.dart <command> [options]');
    print('Commands:');
    print('  backup - Backup current configuration');
    print('  validate - Validate configuration format');
    print('  modify - Modify configuration (use with --help for options)');
    return;
  }

  switch (args[0]) {
    case 'backup':
      await PostBuildConfigModifier.backupConfig();
      break;
    case 'validate':
      await PostBuildConfigModifier.validateConfig();
      break;
    case 'modify':
      // Example modification
      await PostBuildConfigModifier.modifyConfig(
        appName: 'Modified App',
        webviewUrl: 'https://www.example.com',
        customFields: {
          'modified': true,
          'modificationTime': DateTime.now().toIso8601String(),
        },
      );
      break;
    default:
      print('Unknown command: ${args[0]}');
  }
}
