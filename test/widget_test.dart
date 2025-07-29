
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/app_module.dart';
import 'package:gestao_de_estagio/app_widget.dart';
import 'package:gestao_de_estagio/core/guards/auth_guard.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/get_auth_state_changes_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'widget_test.mocks.dart';
import 'package:gestao_de_estagio/core/services/notification_service.dart';
import 'mocks/mock_notification_service.dart';
import 'package:gestao_de_estagio/core/animations.dart';

@GenerateMocks([AuthGuard, GetAuthStateChangesUsecase])
void main() {
  setUpAll(() {
    NotificationService.instance = MockNotificationService();
  });
  late MockGetAuthStateChangesUsecase mockGetAuthStateChangesUsecase;

  // Grupo para testes que precisam do Modular e Supabase
  group('AppWidget and Modular Tests', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      // Garante que o Supabase seja inicializado apenas uma vez
      try {
        await Supabase.initialize(
          url: 'https://fake.com',
          anonKey: 'fake-key',
        );
      } catch (e) {
        // Ignora o erro se já estiver inicializado
      }

      mockGetAuthStateChangesUsecase = MockGetAuthStateChangesUsecase();
      when(mockGetAuthStateChangesUsecase.call())
          .thenAnswer((_) => Stream.value(null));

      // Inicializa o módulo principal para os testes deste grupo
      Modular.init(AppModule());

      // Substitui dependências por mocks
      final sharedPreferences = await SharedPreferences.getInstance();
      Modular.replaceInstance<SharedPreferences>(sharedPreferences);

      final authGuard = MockAuthGuard();
      when(authGuard.canActivate(any, any)).thenAnswer((_) async => true);
      Modular.replaceInstance<AuthGuard>(authGuard);

      Modular.replaceInstance<GetAuthStateChangesUsecase>(
          mockGetAuthStateChangesUsecase);
    });

    tearDownAll(() {
      Modular.destroy();
    });

    testWidgets('AppWidget smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const AppWidget());
      await tester.pump();

      // Verifica se o MaterialApp (dentro do AppWidget) foi renderizado
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  // Grupo para testes de widgets de animação (não precisam do Modular)
  group('Animation Widgets Tests', () {
    testWidgets('Animation widgets should not cause overflow',
        (WidgetTester tester) async {
      // Test /* StudentAnimation removido */
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StudentAnimation(width: 120, height: 120),
                  SizedBox(height: 20),
                  Text('Test content'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Should not throw overflow errors
      expect(find.byType(StudentAnimation), findsOneWidget);

      // Test /* SupervisorAnimation removido */
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SupervisorAnimation(width: 120, height: 120),
                  SizedBox(height: 20),
                  Text('Test content'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SupervisorAnimation), findsOneWidget);

      // Test /* PasswordResetAnimation removido */
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PasswordResetAnimation(width: 200, height: 200),
                  SizedBox(height: 20),
                  Text('Test content'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PasswordResetAnimation), findsOneWidget);
    });

    testWidgets('Animation widgets should handle different screen sizes',
        (WidgetTester tester) async {
      // Test on small screen
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StudentAnimation(width: 120, height: 120),
                  SizedBox(height: 20),
                  Text('Test content on small screen'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(StudentAnimation), findsOneWidget);

      // Test on large screen
      tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SupervisorAnimation(width: 120, height: 120),
                  SizedBox(height: 20),
                  Text('Test content on large screen'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SupervisorAnimation), findsOneWidget);

      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
