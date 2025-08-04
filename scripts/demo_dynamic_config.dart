import 'dart:convert';
import 'dart:io';

// Demo script to show dynamic configuration loading and internet checking
void main() async {
  print('Dynamic Configuration & Internet Checking Demo');
  print('================================================\n');

  // Show default values
  print(
    'DEFAULT VALUES (used when config.json is missing or has missing fields):',
  );
  print('  App Name: "buildapk1"');
  print('  Application ID: "com.buildapk1.app1"');
  print('  URL: "https://www.web2appify.com"');
  print('');

  // Check current config file
  final configFile = File('assets/config.json');

  if (await configFile.exists()) {
    print('CURRENT CONFIG FILE VALUES:');
    try {
      final content = await configFile.readAsString();
      final config = json.decode(content);
      print(
        '  App Name: "${config['appName'] ?? 'buildapk1'}" ${config['appName'] == null ? '(using default)' : '(from config)'}',
      );
      print(
        '  Application ID: "${config['applicationId'] ?? 'com.buildapk1.app1'}" ${config['applicationId'] == null ? '(using default)' : '(from config)'}',
      );
      print(
        '  URL: "${config['webviewUrl'] ?? 'https://www.web2appify.com'}" ${config['webviewUrl'] == null ? '(using default)' : '(from config)'}',
      );
    } catch (e) {
      print('  Error reading config file: $e');
      print('  Will use default values instead.');
    }
  } else {
    print('CONFIG FILE NOT FOUND:');
    print(
      '  Will use default values: buildapk1, com.buildapk1.app1, https://www.web2appify.com',
    );
  }

  print('');
  print('How it works:');
  print('1. App tries to load assets/config.json');
  print('2. If file exists and has values, uses those values');
  print('3. If file missing or field empty, uses default values');
  print('4. This ensures app always works even without config file');

  // Internet connectivity demo
  print('\n--- Internet Connectivity Features ---');
  print('✓ Real-time connectivity monitoring');
  print('✓ Automatic retry when connection restored');
  print('✓ Offline state detection');
  print('✓ Network quality checking');
  print('✓ Last visited URL persistence');
  print('✓ Graceful error handling');

  print('\nConnectivity Features:');
  print('• Detects WiFi/Mobile/No connection');
  print('• Shows offline screen when no internet');
  print('• Auto-reloads page when connection restored');
  print('• Remembers last visited URL');
  print('• Handles network errors gracefully');
  print('• Progress indicators during loading');

  // Demonstrate creating different configs
  print('\n--- Demo: Creating test configurations ---');

  final testConfigs = [
    {
      'name': 'Minimal Config (only app name)',
      'config': {'appName': 'My Custom App'},
    },
    {
      'name': 'Complete Custom Config',
      'config': {
        'appName': 'Shopping App',
        'applicationId': 'com.shopping.store',
        'webviewUrl': 'https://www.mystore.com',
        'offlineMessage': 'Please check your internet connection',
        'loadingMessage': 'Loading your store...',
        'errorMessage': 'Unable to load store',
      },
    },
    {'name': 'Empty Config (all defaults)', 'config': {}},
  ];

  for (int i = 0; i < testConfigs.length; i++) {
    final test = testConfigs[i];
    print('\n${i + 1}. ${test['name']}:');

    final config = Map<String, dynamic>.from(test['config'] as Map);
    print('   Config: ${json.encode(config)}');
    print('   Result:');
    print('     App Name: "${config['appName'] ?? 'buildapk1'}"');
    print(
      '     Application ID: "${config['applicationId'] ?? 'com.buildapk1.app1'}"',
    );
    print(
      '     URL: "${config['webviewUrl'] ?? 'https://www.web2appify.com'}"',
    );
    print(
      '     Offline Message: "${config['offlineMessage'] ?? 'No internet connection'}"',
    );
  }

  print('\n--- Testing Internet Connectivity ---');
  print('To test internet features:');
  print('1. Run the app with internet connection');
  print('2. Turn off WiFi/Mobile data');
  print('3. App will show offline screen');
  print('4. Turn connection back on');
  print('5. App will automatically reload');

  print('\nNetwork Error Handling:');
  print('• DNS resolution failures');
  print('• Timeout errors');
  print('• SSL certificate issues');
  print('• Server unavailable');
  print('• Slow network detection');

  print('\nTo test this:');
  print('1. Delete or rename assets/config.json');
  print('2. Run: flutter run');
  print(
    '3. App will use defaults: buildapk1, com.buildapk1.app1, https://www.web2appify.com',
  );
  print('4. Create config.json with your values');
  print('5. Run: flutter run');
  print('6. App will use your custom values');
  print('7. Test connectivity by turning off internet');
}
