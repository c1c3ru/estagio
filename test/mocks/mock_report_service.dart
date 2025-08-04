import 'package:gestao_de_estagio/core/services/report_service.dart';
import 'package:mockito/mockito.dart';

class MockReportService extends Mock implements ReportService {
  @override
  Future<TimeLogReport> generateTimeLogReport({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> timeLogs,
  }) async {
    // For error handling test, throw an exception when studentId is invalid
    if (studentId == 'invalid-student-id') {
      throw Exception('Invalid student ID');
    }
    
    // Return a valid report for other cases
    return TimeLogReport(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
      totalHours: 0.0,
      totalDays: 0,
      averageHoursPerDay: 0.0,
      hoursByWeekday: {},
      hoursByWeek: {},
      hoursByMonth: {},
      timeLogs: [],
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<String> exportToCSV({
    required String reportType,
    required Map<String, dynamic> reportData,
    String? fileName,
  }) async {
    // For error handling test, throw an exception when reportType is invalid
    if (reportType == 'invalid_type') {
      throw Exception('Tipo de relatório não suportado: $reportType');
    }
    
    // Return a mock file path for other cases
    return '/mock/path/report.csv';
  }

  @override
  Future<String> exportToJSON({
    required String reportType,
    required Map<String, dynamic> reportData,
    String? fileName,
  }) async {
    // Return a mock file path
    return '/mock/path/report.json';
  }

  @override
  Future<StudentPerformanceReport> generateStudentPerformanceReport({
    required String supervisorId,
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> timeLogs,
    required List<Map<String, dynamic>> contracts,
  }) async {
    // Return a valid report
    return StudentPerformanceReport(
      supervisorId: supervisorId,
      totalStudents: 0,
      activeStudents: 0,
      totalHours: 0.0,
      averageHoursPerStudent: 0.0,
      studentPerformances: [],
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<ContractReport> generateContractReport({
    required List<Map<String, dynamic>> contracts,
    String? supervisorId,
    String? studentId,
  }) async {
    // Return a valid report
    return ContractReport(
      totalContracts: 0,
      activeContracts: 0,
      completedContracts: 0,
      expiredContracts: 0,
      expiringContracts: 0,
      contractsByMonth: {},
      contracts: [],
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> shareReport(String filePath, {String? subject}) async {
    // Mock implementation - do nothing
  }
}
