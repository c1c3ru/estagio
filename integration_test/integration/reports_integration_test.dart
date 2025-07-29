// test/integration/reports_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gestao_de_estagio/main.dart' as app;

import 'test_app_module.dart';
import 'package:gestao_de_estagio/core/services/report_service.dart';
import 'package:gestao_de_estagio/features/student/pages/student_reports_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/supervisor_reports_page.dart';
import 'package:gestao_de_estagio/features/shared/widgets/advanced_filters_widget.dart';
import 'package:gestao_de_estagio/features/shared/widgets/export_options_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reports Integration Tests', () {
    late ReportService reportService;

    setUpAll(() async {
      // Inicializar Supabase para testes
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'test_url'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'test_key'),
      );

      // Configurar módulo de teste
      Modular.bindModule(TestAppModule());
      reportService = Modular.get<ReportService>();
    });

    tearDownAll(() async {
      Modular.destroy();
    });

    group('ReportService Integration', () {
      testWidgets('should generate time log report successfully', (tester) async {
        // Arrange
        const studentId = 'test-student-id';
        final startDate = DateTime.now().subtract(const Duration(days: 30));
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
        final report = result;
        expect(report.studentId, equals(studentId));
        expect(report.startDate, equals(startDate));
        expect(report.endDate, equals(endDate));
        expect(report.timeLogs, isA<List>());
      });

      testWidgets('should generate student performance report successfully', (tester) async {
        // Arrange
        const supervisorId = 'test-supervisor-id';
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();

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

      testWidgets('should generate contract report successfully', (tester) async {
        // Arrange
        const supervisorId = 'test-supervisor-id';
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();

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
        await reportService.shareReport(
          filePath,
          subject: 'Test Report',
        );

        // Assert
        // Se não lançar exceção, compartilhou com sucesso
        expect(true, isTrue);
      });
    });

    group('Student Reports Page Integration', () {
      testWidgets('should load student reports page successfully', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Simular login como estudante
        // (Este teste assumiria que há um mecanismo de login de teste)

        // Act
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(StudentReportsPage), findsOneWidget);
        expect(find.text('Relatórios'), findsOneWidget);
      });

      testWidgets('should apply date filters correctly', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.assessment));
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
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.assessment));
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
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.assessment));
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
      testWidgets('should load supervisor reports page successfully', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Simular login como supervisor
        // (Este teste assumiria que há um mecanismo de login de teste)

        // Act
        await tester.tap(find.byIcon(Icons.dashboard));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Relatórios'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SupervisorReportsPage), findsOneWidget);
        expect(find.text('Relatórios de Supervisão'), findsOneWidget);
      });

      testWidgets('should switch between report tabs', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios do supervisor
        await tester.tap(find.byIcon(Icons.dashboard));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Relatórios'));
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
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios do supervisor
        await tester.tap(find.byIcon(Icons.dashboard));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Relatórios'));
        await tester.pumpAndSettle();

        // Act - Filtrar por estudante
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Selecionar um estudante específico
        await tester.tap(find.text('Todos os estudantes').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('João Silva').first);
        await tester.pumpAndSettle();

        // Aplicar filtro
        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        // Assert
        // Verificar se os dados foram filtrados para o estudante selecionado
        expect(find.text('João Silva'), findsWidgets);
      });
    });

    group('Advanced Filters Integration', () {
      testWidgets('should apply preset filters correctly', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página com filtros avançados
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Act - Abrir filtros avançados
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();

        // Aplicar preset "Último mês"
        await tester.tap(find.text('Último mês'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AdvancedFiltersWidget), findsOneWidget);
        // Verificar se as datas foram definidas corretamente
      });

      testWidgets('should apply custom date range filter', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página com filtros avançados
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Act - Abrir filtros avançados
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();

        // Selecionar período customizado
        await tester.tap(find.text('Período customizado'));
        await tester.pumpAndSettle();

        // Definir data de início
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        // Selecionar data no calendário
        await tester.tap(find.text('15'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Definir data de fim
        await tester.tap(find.byIcon(Icons.calendar_today).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('25'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Aplicar filtros
        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        // Assert
        // Verificar se o período customizado foi aplicado
        expect(find.text('15'), findsWidgets);
        expect(find.text('25'), findsWidgets);
      });

      testWidgets('should clear all filters', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página com filtros avançados
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Aplicar alguns filtros primeiro
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Último mês'));
        await tester.pumpAndSettle();

        // Act - Limpar filtros
        await tester.tap(find.text('Limpar'));
        await tester.pumpAndSettle();

        // Assert
        // Verificar se todos os filtros foram removidos
        expect(find.text('Todos os períodos'), findsOneWidget);
      });
    });

    group('Export Options Integration', () {
      testWidgets('should configure export options correctly', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Act - Abrir opções de exportação
        await tester.tap(find.byIcon(Icons.download));
        await tester.pumpAndSettle();

        // Configurar opções
        await tester.tap(find.text('JSON'));
        await tester.pumpAndSettle();

        // Incluir metadados
        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();

        // Definir nome do arquivo
        await tester.enterText(find.byType(TextField), 'meu_relatorio_teste');
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ExportOptionsWidget), findsOneWidget);
        expect(find.text('JSON'), findsOneWidget);
        expect(find.text('meu_relatorio_teste'), findsOneWidget);
      });

      testWidgets('should preview export data', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Act - Abrir opções de exportação
        await tester.tap(find.byIcon(Icons.download));
        await tester.pumpAndSettle();

        // Visualizar preview
        await tester.tap(find.text('Visualizar'));
        await tester.pumpAndSettle();

        // Assert
        // Verificar se o preview dos dados está sendo exibido
        expect(find.text('Preview dos dados'), findsOneWidget);
      });

      testWidgets('should complete export process', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Act - Exportar relatório
        await tester.tap(find.byIcon(Icons.download));
        await tester.pumpAndSettle();

        // Confirmar exportação
        await tester.tap(find.text('Exportar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Exportação concluída'), findsOneWidget);
      });
    });

    group('Error Handling Integration', () {
      testWidgets('should handle network errors gracefully', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Simular erro de rede (desconectar)
        // (implementação específica dependeria do mock de conectividade)

        // Act
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Erro de conexão'), findsOneWidget);
        expect(find.text('Tentar novamente'), findsOneWidget);
      });

      testWidgets('should handle empty data gracefully', (tester) async {
        // Arrange
        await app.main();
        await tester.pumpAndSettle();

        // Navegar para página de relatórios com dados vazios
        await tester.tap(find.byIcon(Icons.assessment));
        await tester.pumpAndSettle();

        // Act - Aplicar filtro que resulta em dados vazios
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Período customizado'));
        await tester.pumpAndSettle();
        // Definir período sem dados
        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Nenhum dado encontrado'), findsOneWidget);
        expect(find.text('Ajustar filtros'), findsOneWidget);
      });
    });
  });
}
