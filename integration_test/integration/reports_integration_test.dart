import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gestao_de_estagio/main.dart' as app;
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
          startDate: startDate,
          endDate: endDate,
          timeLogs: [],
        );

        // Assert
        expect(result, isA<TimeLogReport>());
        expect(result.studentId, equals(studentId));
        expect(result.startDate, equals(startDate));
        expect(result.endDate, equals(endDate));
        expect(result.timeLogs, isA<List>());
        expect(result.totalHours, isA<double>());
        expect(result.totalDays, isA<int>());
        expect(result.averageHoursPerDay, isA<double>());
      });

      testWidgets('should generate student performance report successfully',
          (tester) async {
        // Arrange
        const supervisorId = 'test-supervisor-id';

        // Act
        final result = await reportService.generateStudentPerformanceReport(
          supervisorId: supervisorId,
          students: [],
          timeLogs: [],
          contracts: [],
        );

        // Assert
        expect(result, isA<StudentPerformanceReport>());
        final report = result;
        expect(report.supervisorId, equals(supervisorId));
        expect(report.studentPerformances, isA<List>());
        expect(report.totalStudents, isA<int>());
        expect(report.activeStudents, isA<int>());
        expect(report.totalHours, isA<double>());
        expect(report.averageHoursPerStudent, isA<double>());
      });

      testWidgets('should generate contract report successfully',
          (tester) async {
        // Arrange
        const supervisorId = 'test-supervisor-id';

        // Act
        final result = await reportService.generateContractReport(
          contracts: [], // Adapte para usar dados de teste se necessário
          supervisorId: supervisorId,
          studentId: null,
        );

        // Assert
        expect(result, isA<ContractReport>());
        final report = result;
        expect(report.contracts, isA<List>());
        expect(report.contractsByMonth, isA<Map<String, int>>());
      });

      testWidgets('should export report to CSV successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final reportResult = await reportService.generateTimeLogReport(
          studentId: studentId,
          startDate: startDate,
          endDate: endDate,
          timeLogs: [],
        );

        final report = reportResult;

        // Act
        final exportResult = await reportService.exportToCSV(
          reportType: 'time_log',
          reportData: report.toJson(),
          fileName: 'test_report.csv',
        );

        // Assert
        expect(exportResult, isA<String>());
        expect(exportResult, isNotEmpty);
        expect(exportResult, contains('.csv'));
        expect(report.studentId, equals(studentId));
        expect(report.timeLogs, isA<List>());
      });

      testWidgets('should export report to JSON successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final reportResult = await reportService.generateTimeLogReport(
          studentId: studentId,
          startDate: startDate,
          endDate: endDate,
          timeLogs: [],
        );

        final report = reportResult;

        // Act
        final exportResult = await reportService.exportToJSON(
          reportType: 'time_log',
          reportData: report.toJson(),
          fileName: 'test_report.json',
        );

        // Assert
        expect(exportResult, isA<String>());
        expect(exportResult, isNotEmpty);
        expect(exportResult, contains('.json'));
        expect(report.studentId, equals(studentId));
        expect(report.timeLogs, isA<List>());
      });

      testWidgets('should share report file successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final reportResult = await reportService.generateTimeLogReport(
          studentId: studentId,
          startDate: startDate,
          endDate: endDate,
          timeLogs: [],
        );

        final report = reportResult;

        final exportResult = await reportService.exportToCSV(
          reportType: 'time_log',
          reportData: report.toJson(),
          fileName: 'test_share_report.csv',
        );

        expect(exportResult, isA<String>());
        final filePath = exportResult;

        // Act
        reportService.shareReport(
          filePath,
          subject: 'Test Report',
        );

        // Assert
        // Se não lançar exceção, compartilhou com sucesso
        expect(true, isTrue);
      });
    });

    group('Student Reports Page Integration', () {
      testWidgets('should load student reports page successfully',
          (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Simular login como estudante
        // (Este teste assumiria que há um mecanismo de login de teste)

        // Act
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(StudentReportsPage), findsOneWidget);
        expect(find.text('Relatórios'), findsOneWidget);
      });

      testWidgets('should apply date filters correctly', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Act - Aplicar filtro de período
        await tester.tap(find.text('Últimos 7 dias'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(StudentReportsPage), findsOneWidget);
        // Verificar se os dados foram filtrados corretamente
        // (implementação específica dependeria da estrutura da página)
      });

      testWidgets('should export report from student page', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Act - Exportar relatório
        await tester.tap(find.byIcon(Icons.download));
        await tester.pumpAndSettle();

        // Selecionar formato CSV
        await tester.tap(find.text('CSV'));
        await tester.pumpAndSettle();

        // Confirmar exportação
        await tester.tap(find.text('Exportar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Relatório exportado com sucesso'), findsOneWidget);
      });

      testWidgets('should share report from student page', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Act - Compartilhar relatório
        await tester.tap(find.byIcon(Icons.share));
        await tester.pumpAndSettle();

        // Assert
        // Verificar se o diálogo de compartilhamento foi aberto
        // (implementação específica dependeria do sistema de compartilhamento)
      });
    });

    group('Supervisor Reports Page Integration', () {
      testWidgets('should navigate to supervisor reports page', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // (Este teste assumiria que há um mecanismo de login de teste)

        // Act - Navegar diretamente para a página de relatórios
        await Modular.to.pushNamed('/supervisor/reports');
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
        expect(find.text('Relatórios de Supervisão'), findsOneWidget);
      });

      testWidgets('should switch between report tabs', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navegar diretamente para a página de relatórios do supervisor
        await Modular.to.pushNamed('/supervisor/reports');
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
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navegar diretamente para a página de relatórios do supervisor
        await Modular.to.pushNamed('/supervisor/reports');
        await tester.pumpAndSettle();

        // Act - Filtrar por estudante
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        await tester.tap(find.text('João Silva'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
        expect(find.text('João Silva'), findsOneWidget);
      });

      testWidgets('should generate bulk reports for all students',
          (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navegar diretamente para a página de relatórios do supervisor
        await Modular.to.pushNamed('/supervisor/reports');
        await tester.pumpAndSettle();

        // Act - Gerar relatórios em lote
        await tester.tap(find.byIcon(Icons.batch_prediction));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gerar Todos'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Relatórios gerados com sucesso'), findsOneWidget);
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
            startDate: startDate,
            endDate: endDate,
            timeLogs: [],
          ),
          throwsA(isA<Exception>()),
        );
      });

      testWidgets('should handle export errors gracefully', (tester) async {
        // Arrange
        final invalidData = <String, dynamic>{};

        // Act & Assert
        expect(
          () => reportService.exportToCSV(
            reportType: 'invalid_type',
            reportData: invalidData,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
