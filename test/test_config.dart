// test/test_config.dart
// Configuração global para testes: mock NotificationService e documentação de warning de HttpClient.

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/core/services/notification_service.dart';
import 'mocks/mock_notification_service.dart';

// Este projeto pode exibir o warning "all HTTP requests will return status code 400" nos testes.
// Isso é esperado e não impacta o resultado, pois todos os serviços externos estão mockados.

import 'package:flutter/services.dart';

void setupTestEnvironment() {
  // Mock do canal de SharedPreferences para evitar MissingPluginException
  const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') return <String, dynamic>{};
    if (methodCall.method == 'setString') return true;
    if (methodCall.method == 'setBool') return true;
    if (methodCall.method == 'setInt') return true;
    if (methodCall.method == 'setDouble') return true;
    if (methodCall.method == 'setStringList') return true;
    if (methodCall.method == 'remove') return true;
    if (methodCall.method == 'clear') return true;
    return null;
  });
  setUpAll(() {
    NotificationService.instance = MockNotificationService();
    NotificationService.instance = MockNotificationService();
  });
}
