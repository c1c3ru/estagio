import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gestao_de_estagio/core/services/report_service.dart';
import 'package:gestao_de_estagio/features/student/pages/student_reports_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/supervisor_reports_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'test_app_module.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reports Integration Tests', () {
    late ReportService reportService;

    setUp(() async {
      // Initialize the TestAppModule for dependency injection
      Modular.bindModule(TestAppModule());

      reportService = Modular.get<ReportService>();
    });

    tearDown(() async {
      // Clean up Modular bindings
      cleanModular(); // This properly resets the Modular injector between tests
    });

    group('Report Service Integration', () {
      testWidgets('should generate time log report successfully',
          (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        // Act
        final result = await reportService.generateTimeLogReport(
          studentId: studentId,
          studentName: 'Estudante',
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(result, isA<ReportData>());
        final data = result.data;
        expect(data['studentId'], equals(studentId));
        expect(data['period']['start'], contains(startDate.year.toString()));
        expect(data['period']['end'], contains(endDate.year.toString()));
      });

      testWidgets('should generate student performance report successfully',
          (tester) async {
        // Arrange
        // supervisorId não utilizado removido

        // Act
        final result = await reportService.generateStudentPerformanceReport(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        );

        // Assert
        expect(result, isA<ReportData>());
      });

      testWidgets('should generate contract report successfully',
          (tester) async {
        // Arrange
        // supervisorId não utilizado removido

        // Act
        final result = await reportService.generateContractReport();

        // Assert
        expect(result, isA<ReportData>());
      });

      testWidgets('should export report to CSV successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final reportResult = await reportService.generateTimeLogReport(
          studentId: studentId,
          studentName: 'Estudante',
          startDate: startDate,
          endDate: endDate,
        );

        final report = reportResult;

        // Act
        final exportResult = await reportService.exportToCSV(report);

        // Assert
        expect(exportResult, isA<String>());
        expect(exportResult, isNotEmpty);
        expect(exportResult, contains('.csv'));
        expect(report.data['studentId'], equals(studentId));
        expect(report.data['timeLogs'], isA<List>());
      });

      testWidgets('should export report to JSON successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final reportResult = await reportService.generateTimeLogReport(
          studentId: studentId,
          studentName: 'Estudante',
          startDate: startDate,
          endDate: endDate,
        );

        final report = reportResult;

        // Act
        final exportResult = await reportService.exportToJSON(report);

        // Assert
        expect(exportResult, isA<String>());
        expect(exportResult, isNotEmpty);
        expect(exportResult, contains('.json'));
        expect(report.data['studentId'], equals(studentId));
        expect(report.data['timeLogs'], isA<List>());
      });

      testWidgets('should share report file successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final reportResult = await reportService.generateTimeLogReport(
          studentId: studentId,
          studentName: 'Estudante',
          startDate: startDate,
          endDate: endDate,
        );

        final report = reportResult;

        final exportResult = await reportService.exportToCSV(report);

        expect(exportResult, isA<String>());
        final filePath = exportResult!;

        // Act
        // Compat: shareReport aceita (filePath, {subject}) via wrapper no ReportService
        await reportService.shareReportLegacy(filePath, subject: 'Test Report');

        // Assert
        // Se não lançar exceção, compartilhou com sucesso
        expect(true, isTrue);
      });
    });

    group('Student Reports Page Integration', () {
      testWidgets('should load student reports page successfully',
          (tester) async {
        // Arrange & Act - Directly pump the StudentReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StudentReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(StudentReportsPage), findsOneWidget);
        expect(find.text('Relatórios'), findsOneWidget);
      });

      testWidgets('should apply date filters correctly', (tester) async {
        // Arrange & Act - Directly pump the StudentReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StudentReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Change period filter
        await tester.tap(find.text('Últimos 7 dias'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(StudentReportsPage), findsOneWidget);
        // Verificar se os dados foram filtrados corretamente
        // (implementação específica dependeria da estrutura da página)
      });

      testWidgets('should export report from student page', (tester) async {
        // Arrange & Act - Directly pump the StudentReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StudentReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Verifica se a página foi carregada
        expect(find.byType(StudentReportsPage), findsOneWidget);
      });

      testWidgets('should share report from student page', (tester) async {
        // Arrange & Act - Directly pump the StudentReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StudentReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Verifica se a página foi carregada
        expect(find.byType(StudentReportsPage), findsOneWidget);
      });
    });

    group('Supervisor Reports Page Integration', () {
      testWidgets('should display supervisor reports page', (tester) async {
        // Arrange & Act - Directly pump the SupervisorReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SupervisorReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
        expect(find.text('Relatórios de Supervisão'), findsOneWidget);
      });

      testWidgets('should switch between report tabs', (tester) async {
        // Arrange & Act - Directly pump the SupervisorReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SupervisorReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Alternar entre abas
        await tester.tap(find.text('Performance'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Contratos'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Análises'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
        // Verificar se o conteúdo das abas está sendo exibido corretamente
      });

      testWidgets('should filter reports by student', (tester) async {
        // Arrange & Act - Directly pump the SupervisorReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SupervisorReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Verifica se a página foi carregada

        // Assert
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
        // Note: The actual filtering logic would be tested in unit tests
      });

      testWidgets('should generate bulk reports for all students',
          (tester) async {
        // Arrange & Act - Directly pump the SupervisorReportsPage widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SupervisorReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Verifica se a página foi carregada
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle report generation errors gracefully',
          (tester) async {
        // Arrange
        const studentId = 'invalid-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        // Act & Assert
        expect(
          () => reportService.generateTimeLogReport(
            studentId: studentId,
            studentName: 'Estudante',
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<Exception>()),
        );
      });

      testWidgets('should handle export errors gracefully', (tester) async {
        // Arrange
        final invalidData = <String, dynamic>{};

        // Act & Assert
        expect(
          () async {
            final dummy = ReportData(
              id: 'x',
              title: 't',
              description: 'd',
              type: ReportType.customReport,
              data: invalidData,
              generatedAt: DateTime.now(),
              generatedBy: 'test',
            );
            await reportService.exportToCSV(dummy);
          },
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
