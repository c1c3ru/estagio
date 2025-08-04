import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/main.dart' as app;

void main() {
  testWidgets('App inicializa sem crash', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('Sistema de Estágio'), findsOneWidget);
  });
}
