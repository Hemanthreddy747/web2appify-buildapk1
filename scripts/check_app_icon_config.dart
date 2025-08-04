import 'dart:convert';
import 'dart:io';

void main() async {
  print('App Icon Name Configuration Analysis');
  print('===================================\n');

  // Check current config
  final configFile = File('assets/config.json');
  String configAppName = 'buildapk1';

  if (await configFile.exists()) {
    try {
      final content = await configFile.readAsString();
      final config = json.decode(content);
      configAppName = config['appName'] ?? 'buildapk1';
    } catch (e) {
      print('Error reading config.json: $e');
    }
  }

  // Check Android manifest
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  String manifestLabel = 'Unknown';

  if (await manifestFile.exists()) {
    final manifestContent = await manifestFile.readAsString();

    if (manifestContent.contains('android:label="@string/app_name"')) {
      manifestLabel = '@string/app_name (dynamic)';
    } else {
      final labelMatch = RegExp(
        r'android:label="([^"]*)"',
      ).firstMatch(manifestContent);
      manifestLabel = labelMatch?.group(1) ?? 'Not found';
    }
  }

  // Check strings.xml
  final stringsFile = File('android/app/src/main/res/values/strings.xml');
  String stringsAppName = 'Not found';

  if (await stringsFile.exists()) {
    final stringsContent = await stringsFile.readAsString();
    final appNameMatch = RegExp(
      r'<string name="app_name">([^<]*)</string>',
    ).firstMatch(stringsContent);
    stringsAppName = appNameMatch?.group(1) ?? 'Not found';
  }

  print('📱 CURRENT CONFIGURATION STATUS:');
  print('┌─────────────────────────────────────────────────────────────┐');
  print('│ Config File (config.json):                                 │');
  print('│   App Name: "$configAppName"                                │');
  print('│                                                             │');
  print('│ Android Manifest:                                           │');
  print('│   Label: $manifestLabel                                     │');
  print('│                                                             │');
  print('│ Android Strings (strings.xml):                             │');
  print('│   App Name: "$stringsAppName"                               │');
  print('└─────────────────────────────────────────────────────────────┘');

  print('\n🔍 ANALYSIS:');

  bool isConfigured =
      manifestLabel.contains('@string/app_name') &&
      stringsFile.existsSync() &&
      stringsAppName == configAppName;

  if (isConfigured) {
    print('✅ PROPERLY CONFIGURED');
    print('   - App icon will show: "$configAppName"');
    print('   - Config changes will be reflected in app icon name');
  } else {
    print('❌ NEEDS CONFIGURATION');
    print('   - App icon will show: "$manifestLabel" (hardcoded)');
    print('   - Config changes will NOT affect app icon name');
    print('\n🔧 TO FIX:');
    print('   1. Run: dart scripts\\update_app_name.dart');
    print('   2. Or run: build_apk_with_config.bat');
    print('   3. This will sync app icon name with config.json');
  }

  print('\n📋 TESTING INSTRUCTIONS:');
  print('1. Change "appName" in assets/config.json');
  print('2. Run: build_apk_with_config.bat');
  print('3. Install the APK');
  print('4. Check if app icon shows the new name');

  print('\n📝 EXAMPLE TEST:');
  print('   Change config.json:');
  print('   {');
  print('     "appName": "My Test App",');
  print('     ...');
  print('   }');
  print('   Result: App icon will show "My Test App"');
}
