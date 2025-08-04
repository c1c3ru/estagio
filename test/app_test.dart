import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/app_widget.dart';

void main() {
  testWidgets('App inicializa sem crash', (WidgetTester tester) async {
    await tester.pumpWidget(const AppWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
