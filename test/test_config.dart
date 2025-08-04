// test/test_config.dart
// Configuração global para testes: mock NotificationService e documentação de warning de HttpClient.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences
  const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getAll':
        return <String, dynamic>{};
      case 'setString':
      case 'setBool':
      case 'setInt':
      case 'setDouble':
      case 'setStringList':
      case 'remove':
      case 'clear':
        return true;
      default:
        return null;
    }
  });
}
