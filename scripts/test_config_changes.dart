import 'dart:convert';
import 'dart:io';

// Test script to verify config changes reflect in the app
void main() async {
  print('Testing Configuration Changes...\n');

  print('DEFAULT VALUES (when config.json is missing or fields are empty):');
  print('  App Name: "buildapk1"');
  print('  Application ID: "com.buildapk1.app1"');
  print('  URL: "https://www.web2appify.com"\n');

  final configFile = File('assets/config.json');

  if (!await configFile.exists()) {
    print('config.json not found! Creating with default values...');
    final defaultConfig = {
      'appName': 'buildapk1',
      'applicationId': 'com.buildapk1.app1',
      'webviewUrl': 'https://www.web2appify.com',
      'splashScreenDelay': 3000,
      'statusBarColor': '#FFFFFF',
      'navigationBarColor': '#000000',
      'loadingMessage': 'Loading...',
      'pullToRefresh': true,
      'zoomEnabled': false,
      'exitDialogEnabled': true,
    };

    final encoder = JsonEncoder.withIndent('  ');
    await configFile.writeAsString(encoder.convert(defaultConfig));
    print('Created config.json with default values.\n');
  }

  // Read current config
  final currentContent = await configFile.readAsString();
  final currentConfig = json.decode(currentContent);

  print('Current Configuration:');
  print('App Name: ${currentConfig['appName'] ?? 'buildapk1 (default)'}');
  print(
    'Application ID: ${currentConfig['applicationId'] ?? 'com.buildapk1.app1 (default)'}',
  );
  print(
    'URL: ${currentConfig['webviewUrl'] ?? 'https://www.web2appify.com (default)'}',
  );
  print(
    'Status Bar Color: ${currentConfig['statusBarColor'] ?? '#FFFFFF (default)'}',
  );
  print(
    'Loading Message: ${currentConfig['loadingMessage'] ?? 'Loading... (default)'}',
  );
  print(
    'Splash Delay: ${currentConfig['splashScreenDelay'] ?? '3000 (default)'}ms',
  );
  print(
    'Pull to Refresh: ${currentConfig['pullToRefresh'] ?? 'true (default)'}',
  );
  print('Zoom Enabled: ${currentConfig['zoomEnabled'] ?? 'false (default)'}');
  print(
    'Exit Dialog: ${currentConfig['exitDialogEnabled'] ?? 'true (default)'}',
  );

  // Create test variations
  final testConfigs = [
    {
      'name': 'Red Theme Test',
      'changes': {
        'appName': 'Red Theme App',
        'statusBarColor': '#F44336',
        'navigationBarColor': '#D32F2F',
        'loadingMessage': 'Loading Red Theme...',
        'splashScreenDelay': 2000,
      },
    },
    {
      'name': 'Blue Theme Test',
      'changes': {
        'appName': 'Blue Theme App',
        'statusBarColor': '#2196F3',
        'navigationBarColor': '#1976D2',
        'loadingMessage': 'Loading Blue Theme...',
        'splashScreenDelay': 4000,
      },
    },
    {
      'name': 'Feature Test',
      'changes': {
        'appName': 'Feature Test App',
        'pullToRefresh': false,
        'zoomEnabled': true,
        'exitDialogEnabled': false,
        'showProgressBar': false,
        'customCss':
            'body { background: linear-gradient(45deg, #ff6b6b, #4ecdc4); }',
        'customJs': 'console.log("Custom JS loaded from config!");',
      },
    },
  ];

  print('\n--- Available Test Configurations ---');
  for (int i = 0; i < testConfigs.length; i++) {
    print('${i + 1}. ${testConfigs[i]['name']}');
  }
  print('0. Restore original configuration');

  stdout.write('\nSelect test configuration (0-${testConfigs.length}): ');
  final input = stdin.readLineSync();
  final choice = int.tryParse(input ?? '');

  if (choice == null || choice < 0 || choice > testConfigs.length) {
    print('Invalid choice!');
    return;
  }

  if (choice == 0) {
    // Restore original
    print('Restoring original configuration...');
    return;
  }

  // Apply test configuration
  final testConfig = testConfigs[choice - 1];
  final changes = testConfig['changes'] as Map<String, dynamic>;

  print('\nApplying ${testConfig['name']}...');

  // Create backup
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  await configFile.copy('assets/config.json.backup.$timestamp');
  print('Backup created: config.json.backup.$timestamp');

  // Apply changes
  final newConfig = Map<String, dynamic>.from(currentConfig);
  changes.forEach((key, value) {
    newConfig[key] = value;
    print('  $key: $value');
  });

  // Update metadata
  newConfig['lastModified'] = DateTime.now().toIso8601String();
  newConfig['modificationComment'] =
      'Test configuration: ${testConfig['name']}';

  // Write new config
  final encoder = JsonEncoder.withIndent('  ');
  await configFile.writeAsString(encoder.convert(newConfig));

  print('\nConfiguration updated successfully!');
  print('Changes that will be visible in the app:');
  print('  - App title will change to: ${newConfig['appName']}');
  print('  - Status bar color: ${newConfig['statusBarColor']}');
  print('  - Loading message: ${newConfig['loadingMessage']}');
  print('  - Splash screen duration: ${newConfig['splashScreenDelay']}ms');
  if (changes.containsKey('pullToRefresh')) {
    print(
      '  - Pull to refresh: ${newConfig['pullToRefresh'] ? 'Enabled' : 'Disabled'}',
    );
  }
  if (changes.containsKey('zoomEnabled')) {
    print('  - Zoom: ${newConfig['zoomEnabled'] ? 'Enabled' : 'Disabled'}');
  }
  if (changes.containsKey('exitDialogEnabled')) {
    print(
      '  - Exit dialog: ${newConfig['exitDialogEnabled'] ? 'Enabled' : 'Disabled'}',
    );
  }
  if (changes.containsKey('customCss')) {
    print('  - Custom CSS will be injected');
  }
  if (changes.containsKey('customJs')) {
    print('  - Custom JavaScript will be executed');
  }

  print('\nNow rebuild and run your app to see the changes!');
  print('Run: flutter run');
}
