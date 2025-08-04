import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gestao_de_estagio/features/student/pages/student_home_page.dart';
import 'package:gestao_de_estagio/features/shared/bloc/time_log_bloc.dart';
import 'package:gestao_de_estagio/features/student/bloc/student_bloc.dart';

import 'student_home_page_test.mocks.dart';

@GenerateMocks([TimeLogBloc, StudentBloc])
void main() {
  late MockTimeLogBloc mockTimeLogBloc;
  late MockStudentBloc mockStudentBloc;

  setUp(() {
    mockTimeLogBloc = MockTimeLogBloc();
    mockStudentBloc = MockStudentBloc();
    
    when(mockTimeLogBloc.state).thenReturn(TimeLogInitial());
    when(mockStudentBloc.state).thenReturn(StudentInitial());
    when(mockTimeLogBloc.stream).thenAnswer((_) => const Stream.empty());
    when(mockStudentBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TimeLogBloc>.value(value: mockTimeLogBloc),
          BlocProvider<StudentBloc>.value(value: mockStudentBloc),
        ],
        child: const StudentHomePage(),
      ),
    );
  }

  group('StudentHomePage', () {
    testWidgets('deve exibir AppBar com título correto', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Início'), findsOneWidget);
    });

    testWidgets('deve exibir botões de clock-in e clock-out', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Check-out'), findsOneWidget);
    });

    testWidgets('deve disparar evento ao tocar em clock-in', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check-in'));
      await tester.pumpAndSettle();

      verify(mockTimeLogBloc.add(any)).called(1);
    });
  });
}