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

    Modular.init(AppModule());
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
    await tester.pumpWidget(const AppWidget());
    await tester.pump(); // First pump to trigger the initial state
    await tester.pump(); // Second pump to handle state change from stream
    expect(find.byType(AppWidget), findsOneWidget);
  });
}
