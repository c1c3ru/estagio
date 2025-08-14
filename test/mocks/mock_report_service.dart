import 'package:gestao_de_estagio/core/services/report_service.dart';
import 'package:mockito/mockito.dart';

class MockReportService extends Mock implements ReportService {
  @override
  Future<ReportData> generateTimeLogReport({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    required String studentName,
  }) async {
    if (studentId == 'invalid-student-id') {
      throw Exception('Invalid student ID');
    }
    return ReportData(
      id: 'mock_time_log',
      title: 'Relatório de Horas - $studentName',
      description: 'Mock',
      type: ReportType.studentTimeLog,
      data: {
        'studentId': studentId,
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'summary': {
          'totalHours': 0.0,
          'totalDays': 0,
          'averageHoursPerDay': 0.0,
        },
        'timeLogs': [],
      },
      generatedAt: DateTime.now(),
      generatedBy: 'test',
    );
  }

  @override
  Future<String?> exportToCSV(ReportData report) async {
    return '/mock/path/report.csv';
  }

  @override
  Future<String?> exportToJSON(ReportData report) async =>
      '/mock/path/report.json';

  @override
  Future<ReportData> generateStudentPerformanceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return ReportData(
      id: 'mock_perf',
      title: 'Performance',
      description: 'Mock',
      type: ReportType.performanceMetrics,
      data: {
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String()
        },
        'metrics': {
          'averageHoursPerStudent': 0.0,
        },
      },
      generatedAt: DateTime.now(),
      generatedBy: 'test',
    );
  }

  @override
  Future<ReportData> generateContractReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return ReportData(
      id: 'mock_contract',
      title: 'Contratos',
      description: 'Mock',
      type: ReportType.contractStatus,
      data: {
        'contracts': [],
        'statusDistribution': {},
      },
      generatedAt: DateTime.now(),
      generatedBy: 'test',
    );
  }

  @override
  Future<void> shareReportLegacy(String filePath, {String? subject}) async {}
}
