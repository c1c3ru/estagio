import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/core/theme/theme_service.dart';
import 'test_app_module.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  // Skip Firebase initialization entirely for tests to prevent platform channel errors
  // Firebase is mocked in TestAppModule

  // Initialize theme service without Firebase
  await ThemeService().initialize();

  runApp(ModularApp(
    module: TestAppModule(),
    child: const TestMyApp(),
  ));
}

class TestMyApp extends StatelessWidget {
  const TestMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Estágio - Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Test App Running'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
