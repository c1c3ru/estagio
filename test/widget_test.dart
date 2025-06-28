// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
import 'package:gestao_de_estagio/features/shared/animations/lottie_animations.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([AuthGuard, GetAuthStateChangesUsecase])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockGetAuthStateChangesUsecase mockGetAuthStateChangesUsecase;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://fake.com',
      anonKey: 'fake-key',
    );

    mockGetAuthStateChangesUsecase = MockGetAuthStateChangesUsecase();
    when(mockGetAuthStateChangesUsecase.call())
        .thenAnswer((_) => Stream.value(null));

    final sharedPreferences = await SharedPreferences.getInstance();
    Modular.init(AppModule());
    Modular.replaceInstance<SharedPreferences>(sharedPreferences);
    final authGuard = MockAuthGuard();
    when(authGuard.canActivate(any, any)).thenAnswer((_) async => true);
    Modular.replaceInstance<AuthGuard>(authGuard);
    Modular.replaceInstance<GetAuthStateChangesUsecase>(
        mockGetAuthStateChangesUsecase);
  });

  tearDown(() {
    Modular.destroy();
  });

  testWidgets('AppWidget smoke test', (WidgetTester tester) async {
    await tester
        .pumpWidget(ModularApp(module: AppModule(), child: const AppWidget()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Animation widgets should not cause overflow',
      (WidgetTester tester) async {
    // Test StudentAnimation
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const StudentAnimation(size: 120),
                const SizedBox(height: 20),
                const Text('Test content'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should not throw overflow errors
    expect(find.byType(StudentAnimation), findsOneWidget);

    // Test SupervisorAnimation
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SupervisorAnimation(size: 120),
                const SizedBox(height: 20),
                const Text('Test content'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SupervisorAnimation), findsOneWidget);

    // Test PasswordResetAnimation
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const PasswordResetAnimation(size: 200),
                const SizedBox(height: 20),
                const Text('Test content'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PasswordResetAnimation), findsOneWidget);
  });

  testWidgets('Animation widgets should handle different screen sizes',
      (WidgetTester tester) async {
    // Test on small screen
    tester.binding.window.physicalSizeTestValue = const Size(320, 568);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const StudentAnimation(size: 120),
                const SizedBox(height: 20),
                const Text('Test content on small screen'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudentAnimation), findsOneWidget);

    // Test on large screen
    tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SupervisorAnimation(size: 120),
                const SizedBox(height: 20),
                const Text('Test content on large screen'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SupervisorAnimation), findsOneWidget);

    // Reset window size
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });
}
