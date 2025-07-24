// lib/core/services/report_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/date_utils.dart';

/// Serviço responsável por gerar relatórios, estatísticas e exportar dados
class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  /// Gera relatório de horas trabalhadas por período
  Future<TimeLogReport> generateTimeLogReport({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> timeLogs,
  }) async {
    try {
      if (kDebugMode) {
        print('📊 ReportService: Gerando relatório de horas - Estudante: $studentId');
      }

      final filteredLogs = timeLogs.where((log) {
        final logDate = DateTime.parse(log['created_at']);
        return logDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               logDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      final totalHours = filteredLogs.fold<double>(
        0.0,
        (sum, log) => sum + (log['total_hours'] as double? ?? 0.0),
      );

      final totalDays = filteredLogs.length;
      final averageHoursPerDay = totalDays > 0 ? totalHours / totalDays : 0.0;

      // Agrupar por dia da semana
      final hoursByWeekday = <int, double>{};
      for (final log in filteredLogs) {
        final date = DateTime.parse(log['created_at']);
        final weekday = date.weekday;
        hoursByWeekday[weekday] = (hoursByWeekday[weekday] ?? 0.0) + 
                                 (log['total_hours'] as double? ?? 0.0);
      }

      // Agrupar por semana
      final hoursByWeek = <String, double>{};
      for (final log in filteredLogs) {
        final date = DateTime.parse(log['created_at']);
        final weekKey = '${date.year}-W${_getWeekOfYear(date)}';
        hoursByWeek[weekKey] = (hoursByWeek[weekKey] ?? 0.0) + 
                              (log['total_hours'] as double? ?? 0.0);
      }

      // Agrupar por mês
      final hoursByMonth = <String, double>{};
      for (final log in filteredLogs) {
        final date = DateTime.parse(log['created_at']);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        hoursByMonth[monthKey] = (hoursByMonth[monthKey] ?? 0.0) + 
                                (log['total_hours'] as double? ?? 0.0);
      }

      return TimeLogReport(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        totalHours: totalHours,
        totalDays: totalDays,
        averageHoursPerDay: averageHoursPerDay,
        hoursByWeekday: hoursByWeekday,
        hoursByWeek: hoursByWeek,
        hoursByMonth: hoursByMonth,
        timeLogs: filteredLogs,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReportService: Erro ao gerar relatório de horas: $e');
      }
      rethrow;
    }
  }

  /// Gera relatório de performance de estudantes para supervisores
  Future<StudentPerformanceReport> generateStudentPerformanceReport({
    required String supervisorId,
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> timeLogs,
    required List<Map<String, dynamic>> contracts,
  }) async {
    try {
      if (kDebugMode) {
        print('📊 ReportService: Gerando relatório de performance - Supervisor: $supervisorId');
      }

      final studentPerformances = <StudentPerformance>[];

      for (final student in students) {
        final studentId = student['id'] as String;
        final studentTimeLogs = timeLogs.where((log) => log['student_id'] == studentId).toList();
        final studentContracts = contracts.where((contract) => contract['student_id'] == studentId).toList();

        final totalHours = studentTimeLogs.fold<double>(
          0.0,
          (sum, log) => sum + (log['total_hours'] as double? ?? 0.0),
        );

        final averageHoursPerDay = studentTimeLogs.isNotEmpty 
            ? totalHours / studentTimeLogs.length 
            : 0.0;

        final lastActivity = studentTimeLogs.isNotEmpty
            ? DateTime.parse(studentTimeLogs.last['created_at'])
            : null;

        final activeContract = studentContracts.firstWhere(
          (contract) => contract['status'] == 'active',
          orElse: () => <String, dynamic>{},
        );

        final contractProgress = activeContract.isNotEmpty
            ? _calculateContractProgress(activeContract, totalHours)
            : 0.0;

        studentPerformances.add(StudentPerformance(
          studentId: studentId,
          studentName: student['name'] as String,
          totalHours: totalHours,
          averageHoursPerDay: averageHoursPerDay,
          totalDays: studentTimeLogs.length,
          lastActivity: lastActivity,
          contractProgress: contractProgress,
          isActive: lastActivity != null && 
                   DateTime.now().difference(lastActivity).inDays <= 7,
        ));
      }

      // Ordenar por total de horas (decrescente)
      studentPerformances.sort((a, b) => b.totalHours.compareTo(a.totalHours));

      final totalStudents = students.length;
      final activeStudents = studentPerformances.where((s) => s.isActive).length;
      final totalHoursAllStudents = studentPerformances.fold<double>(
        0.0,
        (sum, performance) => sum + performance.totalHours,
      );

      return StudentPerformanceReport(
        supervisorId: supervisorId,
        totalStudents: totalStudents,
        activeStudents: activeStudents,
        totalHours: totalHoursAllStudents,
        averageHoursPerStudent: totalStudents > 0 ? totalHoursAllStudents / totalStudents : 0.0,
        studentPerformances: studentPerformances,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReportService: Erro ao gerar relatório de performance: $e');
      }
      rethrow;
    }
  }

  /// Gera relatório de contratos
  Future<ContractReport> generateContractReport({
    required List<Map<String, dynamic>> contracts,
    String? supervisorId,
    String? studentId,
  }) async {
    try {
      if (kDebugMode) {
        print('📊 ReportService: Gerando relatório de contratos');
      }

      var filteredContracts = contracts;

      if (supervisorId != null) {
        filteredContracts = filteredContracts
            .where((contract) => contract['supervisor_id'] == supervisorId)
            .toList();
      }

      if (studentId != null) {
        filteredContracts = filteredContracts
            .where((contract) => contract['student_id'] == studentId)
            .toList();
      }

      final activeContracts = filteredContracts
          .where((contract) => contract['status'] == 'active')
          .length;

      final completedContracts = filteredContracts
          .where((contract) => contract['status'] == 'completed')
          .length;

      final expiredContracts = filteredContracts
          .where((contract) => contract['status'] == 'expired')
          .length;

      final expiringContracts = filteredContracts.where((contract) {
        if (contract['end_date'] == null) return false;
        final endDate = DateTime.parse(contract['end_date']);
        final daysUntilExpiry = endDate.difference(DateTime.now()).inDays;
        return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
      }).length;

      // Contratos por mês (criação)
      final contractsByMonth = <String, int>{};
      for (final contract in filteredContracts) {
        final date = DateTime.parse(contract['created_at']);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        contractsByMonth[monthKey] = (contractsByMonth[monthKey] ?? 0) + 1;
      }

      return ContractReport(
        totalContracts: filteredContracts.length,
        activeContracts: activeContracts,
        completedContracts: completedContracts,
        expiredContracts: expiredContracts,
        expiringContracts: expiringContracts,
        contractsByMonth: contractsByMonth,
        contracts: filteredContracts,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReportService: Erro ao gerar relatório de contratos: $e');
      }
      rethrow;
    }
  }

  /// Exporta relatório para CSV
  Future<String> exportToCSV({
    required String reportType,
    required Map<String, dynamic> reportData,
    String? fileName,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/${fileName ?? reportType}_$timestamp.csv');

      String csvContent = '';

      switch (reportType) {
        case 'time_log':
          csvContent = _generateTimeLogCSV(reportData);
          break;
        case 'student_performance':
          csvContent = _generateStudentPerformanceCSV(reportData);
          break;
        case 'contract':
          csvContent = _generateContractCSV(reportData);
          break;
        default:
          throw Exception('Tipo de relatório não suportado: $reportType');
      }

      await file.writeAsString(csvContent);

      if (kDebugMode) {
        print('✅ ReportService: Relatório exportado para: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReportService: Erro ao exportar CSV: $e');
      }
      rethrow;
    }
  }

  /// Exporta relatório para JSON
  Future<String> exportToJSON({
    required String reportType,
    required Map<String, dynamic> reportData,
    String? fileName,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/${fileName ?? reportType}_$timestamp.json');

      final jsonContent = const JsonEncoder.withIndent('  ').convert(reportData);
      await file.writeAsString(jsonContent);

      if (kDebugMode) {
        print('✅ ReportService: Relatório exportado para: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReportService: Erro ao exportar JSON: $e');
      }
      rethrow;
    }
  }

  /// Compartilha relatório
  Future<void> shareReport(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Relatório de Estágio',
      );

      if (kDebugMode) {
        print('✅ ReportService: Relatório compartilhado: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReportService: Erro ao compartilhar relatório: $e');
      }
      rethrow;
    }
  }

  /// Calcula progresso do contrato baseado nas horas trabalhadas
  double _calculateContractProgress(Map<String, dynamic> contract, double workedHours) {
    final requiredHours = contract['required_hours'] as double? ?? 0.0;
    if (requiredHours <= 0) return 0.0;
    return (workedHours / requiredHours * 100).clamp(0.0, 100.0);
  }

  /// Obtém número da semana no ano
  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    
    if (date.isBefore(firstMonday)) {
      return 1;
    }
    
    return ((date.difference(firstMonday).inDays) / 7).floor() + 2;
  }

  /// Gera conteúdo CSV para relatório de horas
  String _generateTimeLogCSV(Map<String, dynamic> reportData) {
    final buffer = StringBuffer();
    buffer.writeln('Data,Entrada,Saída,Total de Horas,Descrição,Status');

    final timeLogs = reportData['timeLogs'] as List<Map<String, dynamic>>;
    for (final log in timeLogs) {
      final date = DateTime.parse(log['created_at']).toLocal();
      final clockIn = log['clock_in_time'] != null 
          ? DateTime.parse(log['clock_in_time']).toLocal() 
          : null;
      final clockOut = log['clock_out_time'] != null 
          ? DateTime.parse(log['clock_out_time']).toLocal() 
          : null;

      buffer.writeln([
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        clockIn != null ? '${clockIn.hour.toString().padLeft(2, '0')}:${clockIn.minute.toString().padLeft(2, '0')}' : '',
        clockOut != null ? '${clockOut.hour.toString().padLeft(2, '0')}:${clockOut.minute.toString().padLeft(2, '0')}' : '',
        log['total_hours']?.toString() ?? '0',
        '"${log['description'] ?? ''}"',
        log['status'] ?? '',
      ].join(','));
    }

    return buffer.toString();
  }

  /// Gera conteúdo CSV para relatório de performance de estudantes
  String _generateStudentPerformanceCSV(Map<String, dynamic> reportData) {
    final buffer = StringBuffer();
    buffer.writeln('Nome do Estudante,Total de Horas,Média de Horas/Dia,Total de Dias,Última Atividade,Progresso do Contrato (%),Status');

    final performances = reportData['studentPerformances'] as List<StudentPerformance>;
    for (final performance in performances) {
      buffer.writeln([
        '"${performance.studentName}"',
        performance.totalHours.toStringAsFixed(2),
        performance.averageHoursPerDay.toStringAsFixed(2),
        performance.totalDays.toString(),
        performance.lastActivity?.toLocal().toString().split(' ')[0] ?? '',
        performance.contractProgress.toStringAsFixed(1),
        performance.isActive ? 'Ativo' : 'Inativo',
      ].join(','));
    }

    return buffer.toString();
  }

  /// Gera conteúdo CSV para relatório de contratos
  String _generateContractCSV(Map<String, dynamic> reportData) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Estudante,Supervisor,Data de Início,Data de Fim,Horas Requeridas,Status,Criado em');

    final contracts = reportData['contracts'] as List<Map<String, dynamic>>;
    for (final contract in contracts) {
      final startDate = contract['start_date'] != null 
          ? DateTime.parse(contract['start_date']).toLocal() 
          : null;
      final endDate = contract['end_date'] != null 
          ? DateTime.parse(contract['end_date']).toLocal() 
          : null;
      final createdAt = DateTime.parse(contract['created_at']).toLocal();

      buffer.writeln([
        contract['id']?.toString() ?? '',
        '"${contract['student_name'] ?? ''}"',
        '"${contract['supervisor_name'] ?? ''}"',
        startDate?.toString().split(' ')[0] ?? '',
        endDate?.toString().split(' ')[0] ?? '',
        contract['required_hours']?.toString() ?? '',
        contract['status'] ?? '',
        createdAt.toString().split(' ')[0],
      ].join(','));
    }

    return buffer.toString();
  }
}

/// Modelo de relatório de registros de horas
class TimeLogReport {
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalHours;
  final int totalDays;
  final double averageHoursPerDay;
  final Map<int, double> hoursByWeekday;
  final Map<String, double> hoursByWeek;
  final Map<String, double> hoursByMonth;
  final List<Map<String, dynamic>> timeLogs;
  final DateTime generatedAt;

  const TimeLogReport({
    required this.studentId,
    required this.startDate,
    required this.endDate,
    required this.totalHours,
    required this.totalDays,
    required this.averageHoursPerDay,
    required this.hoursByWeekday,
    required this.hoursByWeek,
    required this.hoursByMonth,
    required this.timeLogs,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalHours': totalHours,
    'totalDays': totalDays,
    'averageHoursPerDay': averageHoursPerDay,
    'hoursByWeekday': hoursByWeekday,
    'hoursByWeek': hoursByWeek,
    'hoursByMonth': hoursByMonth,
    'timeLogs': timeLogs,
    'generatedAt': generatedAt.toIso8601String(),
  };
}

/// Modelo de performance de estudante
class StudentPerformance {
  final String studentId;
  final String studentName;
  final double totalHours;
  final double averageHoursPerDay;
  final int totalDays;
  final DateTime? lastActivity;
  final double contractProgress;
  final bool isActive;

  const StudentPerformance({
    required this.studentId,
    required this.studentName,
    required this.totalHours,
    required this.averageHoursPerDay,
    required this.totalDays,
    this.lastActivity,
    required this.contractProgress,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'totalHours': totalHours,
    'averageHoursPerDay': averageHoursPerDay,
    'totalDays': totalDays,
    'lastActivity': lastActivity?.toIso8601String(),
    'contractProgress': contractProgress,
    'isActive': isActive,
  };
}

/// Modelo de relatório de performance de estudantes
class StudentPerformanceReport {
  final String supervisorId;
  final int totalStudents;
  final int activeStudents;
  final double totalHours;
  final double averageHoursPerStudent;
  final List<StudentPerformance> studentPerformances;
  final DateTime generatedAt;

  const StudentPerformanceReport({
    required this.supervisorId,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalHours,
    required this.averageHoursPerStudent,
    required this.studentPerformances,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'supervisorId': supervisorId,
    'totalStudents': totalStudents,
    'activeStudents': activeStudents,
    'totalHours': totalHours,
    'averageHoursPerStudent': averageHoursPerStudent,
    'studentPerformances': studentPerformances.map((p) => p.toJson()).toList(),
    'generatedAt': generatedAt.toIso8601String(),
  };
}

/// Modelo de relatório de contratos
class ContractReport {
  final int totalContracts;
  final int activeContracts;
  final int completedContracts;
  final int expiredContracts;
  final int expiringContracts;
  final Map<String, int> contractsByMonth;
  final List<Map<String, dynamic>> contracts;
  final DateTime generatedAt;

  const ContractReport({
    required this.totalContracts,
    required this.activeContracts,
    required this.completedContracts,
    required this.expiredContracts,
    required this.expiringContracts,
    required this.contractsByMonth,
    required this.contracts,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'totalContracts': totalContracts,
    'activeContracts': activeContracts,
    'completedContracts': completedContracts,
    'expiredContracts': expiredContracts,
    'expiringContracts': expiringContracts,
    'contractsByMonth': contractsByMonth,
    'contracts': contracts,
    'generatedAt': generatedAt.toIso8601String(),
  };
}
