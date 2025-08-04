import 'dart:convert';
import 'dart:io';

// Script to update Android app name from config.json before building APK
void main() async {
  print('Updating Android App Name from Config...\n');

  try {
    // Read config.json
    final configFile = File('assets/config.json');
    String appName = 'buildapk1'; // Default fallback

    if (await configFile.exists()) {
      final configContent = await configFile.readAsString();
      final config = json.decode(configContent);
      appName = config['appName'] ?? 'buildapk1';
      print('Found app name in config: "$appName"');
    } else {
      print('config.json not found, using default: "$appName"');
    }

    // Update strings.xml
    final stringsFile = File('android/app/src/main/res/values/strings.xml');

    if (!await stringsFile.exists()) {
      print('strings.xml not found, creating it...');
      await stringsFile.parent.create(recursive: true);
    }

    final stringsContent =
        '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$appName</string>
</resources>''';

    await stringsFile.writeAsString(stringsContent);
    print('Updated strings.xml with app name: "$appName"');

    // Also update pubspec.yaml name if needed
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      final pubspecContent = await pubspecFile.readAsString();
      final updatedPubspec = pubspecContent.replaceFirst(
        RegExp(r'^name:\s+.*$', multiLine: true),
        'name: ${appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_')}',
      );
      await pubspecFile.writeAsString(updatedPubspec);
      print('Updated pubspec.yaml name');
    }

    print('\n✅ App name successfully updated to: "$appName"');
    print('Now when you build APK, the icon will show: "$appName"');
  } catch (e) {
    print('❌ Error updating app name: $e');
    exit(1);
  }
}
