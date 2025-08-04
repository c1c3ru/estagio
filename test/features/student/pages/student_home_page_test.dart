import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gestao_de_estagio/features/student/pages/student_home_page.dart';
import 'package:gestao_de_estagio/features/shared/bloc/time_log_bloc.dart';
import 'package:gestao_de_estagio/features/student/bloc/student_bloc.dart';
import 'package:gestao_de_estagio/features/student/bloc/student_state.dart';

import 'student_home_page_test.mocks.dart';

@GenerateMocks([TimeLogBloc, StudentBloc])
void main() {
  late MockTimeLogBloc mockTimeLogBloc;
  late MockStudentBloc mockStudentBloc;

  setUp(() {
    mockTimeLogBloc = MockTimeLogBloc();
    mockStudentBloc = MockStudentBloc();

    when(mockTimeLogBloc.state).thenReturn(TimeLogInitial());
    when(mockStudentBloc.state).thenReturn(const StudentInitial());
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
    testWidgets('deve renderizar sem erros', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('deve exibir widgets básicos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
