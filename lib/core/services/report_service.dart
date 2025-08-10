// lib/core/services/report_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../utils/app_logger.dart';
// import '../constants/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ReportType {
  studentTimeLog,
  supervisorOverview,
  contractStatus,
  attendanceReport,
  performanceMetrics,
  customReport,
}

enum ExportFormat {
  pdf,
  csv,
  json,
  excel,
}

class ReportData {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, dynamic>? filters;

  ReportData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.data,
    required this.generatedAt,
    required this.generatedBy,
    this.filters,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'data': data,
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'filters': filters,
    };
  }

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      data: json['data'],
      generatedAt: DateTime.parse(json['generatedAt']),
      generatedBy: json['generatedBy'],
      filters: json['filters'],
    );
  }
}

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final StreamController<ReportData> _reportGeneratedController =
      StreamController<ReportData>.broadcast();
  final StreamController<double> _exportProgressController =
      StreamController<double>.broadcast();

  bool _isInitialized = false;
  List<ReportData> _reportsHistory = [];

  /// Stream para relatórios gerados
  Stream<ReportData> get reportGeneratedStream =>
      _reportGeneratedController.stream;

  /// Stream para progresso de exportação
  Stream<double> get exportProgressStream => _exportProgressController.stream;

  /// Status de inicialização
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de relatórios
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Carrega histórico de relatórios
      await _loadReportsHistory();

      _isInitialized = true;
      AppLogger.info('ReportService inicializado com sucesso');

      return true;
    } catch (e) {
      AppLogger.error('Erro ao inicializar ReportService', error: e);
      return false;
    }
  }

  /// Gera relatório de time logs do estudante
  Future<ReportData> generateStudentTimeLogReport({
    required String studentId,
    required String studentName,
    required DateTime startDate,
    required DateTime endDate,
    String? generatedBy,
  }) async {
    try {
      final reportId =
          'time_log_${studentId}_${DateTime.now().millisecondsSinceEpoch}';

      // Simula dados do relatório (em produção viria do repository)
      final reportData =
          await _generateTimeLogData(studentId, startDate, endDate);

      final report = ReportData(
        id: reportId,
        title: 'Relatório de Horas - $studentName',
        description:
            'Relatório detalhado de horas trabalhadas entre ${_formatDate(startDate)} e ${_formatDate(endDate)}',
        type: ReportType.studentTimeLog,
        data: reportData,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy ?? 'Sistema',
        filters: {
          'studentId': studentId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      _addToHistory(report);
      _reportGeneratedController.add(report);

      if (kDebugMode) {
        AppLogger.debug('Relatório de time log gerado: $reportId');
      }

      return report;
    } catch (e) {
      AppLogger.error('Erro ao gerar relatório de time log', error: e);
      rethrow;
    }
  }

  /// Gera relatório de visão geral do supervisor
  Future<ReportData> generateSupervisorOverviewReport({
    required String supervisorId,
    required String supervisorName,
    required DateTime startDate,
    required DateTime endDate,
    String? generatedBy,
  }) async {
    try {
      final reportId =
          'supervisor_${supervisorId}_${DateTime.now().millisecondsSinceEpoch}';

      final reportData =
          await _generateSupervisorData(supervisorId, startDate, endDate);

      final report = ReportData(
        id: reportId,
        title: 'Visão Geral - $supervisorName',
        description:
            'Relatório de visão geral do supervisor entre ${_formatDate(startDate)} e ${_formatDate(endDate)}',
        type: ReportType.supervisorOverview,
        data: reportData,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy ?? 'Sistema',
        filters: {
          'supervisorId': supervisorId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      _addToHistory(report);
      _reportGeneratedController.add(report);

      return report;
    } catch (e) {
      AppLogger.error('Erro ao gerar relatório do supervisor', error: e);
      rethrow;
    }
  }

  /// Gera relatório de status de contratos
  Future<ReportData> generateContractStatusReport({
    DateTime? startDate,
    DateTime? endDate,
    String? generatedBy,
  }) async {
    try {
      final reportId = 'contracts_${DateTime.now().millisecondsSinceEpoch}';

      final reportData = await _generateContractData(startDate, endDate);

      final report = ReportData(
        id: reportId,
        title: 'Status dos Contratos',
        description: 'Relatório de status de todos os contratos',
        type: ReportType.contractStatus,
        data: reportData,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy ?? 'Sistema',
        filters: {
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        },
      );

      _addToHistory(report);
      _reportGeneratedController.add(report);

      return report;
    } catch (e) {
      AppLogger.error('Erro ao gerar relatório de contratos', error: e);
      rethrow;
    }
  }

  /// Gera relatório de presença
  Future<ReportData> generateAttendanceReport({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? studentIds,
    String? generatedBy,
  }) async {
    try {
      final reportId = 'attendance_${DateTime.now().millisecondsSinceEpoch}';

      final reportData =
          await _generateAttendanceData(startDate, endDate, studentIds);

      final report = ReportData(
        id: reportId,
        title: 'Relatório de Presença',
        description:
            'Relatório de presença entre ${_formatDate(startDate)} e ${_formatDate(endDate)}',
        type: ReportType.attendanceReport,
        data: reportData,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy ?? 'Sistema',
        filters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'studentIds': studentIds,
        },
      );

      _addToHistory(report);
      _reportGeneratedController.add(report);

      return report;
    } catch (e) {
      AppLogger.error('Erro ao gerar relatório de presença', error: e);
      rethrow;
    }
  }

  /// Gera relatório de métricas de performance
  Future<ReportData> generatePerformanceMetricsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? generatedBy,
  }) async {
    try {
      final reportId = 'performance_${DateTime.now().millisecondsSinceEpoch}';

      final reportData = await _generatePerformanceData(startDate, endDate);

      final report = ReportData(
        id: reportId,
        title: 'Métricas de Performance',
        description:
            'Relatório de métricas de performance entre ${_formatDate(startDate)} e ${_formatDate(endDate)}',
        type: ReportType.performanceMetrics,
        data: reportData,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy ?? 'Sistema',
        filters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      _addToHistory(report);
      _reportGeneratedController.add(report);

      return report;
    } catch (e) {
      AppLogger.error('Erro ao gerar relatório de performance', error: e);
      rethrow;
    }
  }

  /// Exporta relatório
  Future<String?> exportReport({
    required ReportData report,
    required ExportFormat format,
    String? customFileName,
  }) async {
    try {
      _exportProgressController.add(0.1);

      String content;
      String extension;

      switch (format) {
        case ExportFormat.csv:
          content = _convertToCsv(report);
          extension = 'csv';
          break;
        case ExportFormat.json:
          content = jsonEncode(report.toJson());
          extension = 'json';
          break;
        case ExportFormat.pdf:
          content = await _convertToPdf(report);
          extension = 'pdf';
          break;
        case ExportFormat.excel:
          content = await _convertToExcel(report);
          extension = 'xlsx';
          break;
      }

      _exportProgressController.add(0.5);

      final fileName = customFileName ?? '${report.id}.$extension';
      final filePath = await _saveFile(fileName, content,
          format == ExportFormat.pdf || format == ExportFormat.excel);

      _exportProgressController.add(1.0);

      if (kDebugMode) {
        AppLogger.debug('Relatório exportado: $filePath');
      }

      return filePath;
    } catch (e) {
      AppLogger.error('Erro ao exportar relatório', error: e);
      return null;
    }
  }

  /// Compartilha relatório (nova API)
  Future<bool> shareReport({
    required ReportData report,
    required ExportFormat format,
    String? customFileName,
  }) async {
    try {
      final filePath = await exportReport(
        report: report,
        format: format,
        customFileName: customFileName,
      );

      if (filePath != null) {
        await Share.shareXFiles([XFile(filePath)],
            text: 'Relatório: ${report.title}');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Erro ao compartilhar relatório', error: e);
      return false;
    }
  }

  /// Obtém histórico de relatórios
  List<ReportData> getReportsHistory() {
    return List.from(_reportsHistory);
  }

  /// Remove relatório do histórico
  void removeReport(String reportId) {
    _reportsHistory.removeWhere((report) => report.id == reportId);
    _saveReportsHistory();
  }

  /// Limpa histórico de relatórios
  void clearReportsHistory() {
    _reportsHistory.clear();
    _saveReportsHistory();
  }

  /// Obtém estatísticas de relatórios
  Map<String, dynamic> getReportStats() {
    final total = _reportsHistory.length;
    final byType = <String, int>{};

    for (final report in _reportsHistory) {
      final typeName = report.type.name;
      byType[typeName] = (byType[typeName] ?? 0) + 1;
    }

    return {
      'totalReports': total,
      'reportsByType': byType,
      'lastGenerated': _reportsHistory.isNotEmpty
          ? _reportsHistory.first.generatedAt.toIso8601String()
          : null,
    };
  }

  // Métodos privados para geração de dados

  Future<Map<String, dynamic>> _generateTimeLogData(
      String studentId, DateTime startDate, DateTime endDate) async {
    // Simula dados de time log
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'studentId': studentId,
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'summary': {
        'totalHours': 156.5,
        'totalDays': 22,
        'averageHoursPerDay': 7.1,
        'onTimePercentage': 95.5,
      },
      'dailyLogs': List.generate(22, (index) {
        final date = startDate.add(Duration(days: index));
        return {
          'date': date.toIso8601String(),
          'checkIn': '08:00',
          'checkOut': '17:00',
          'hours': 8.0,
          'status': 'approved',
        };
      }),
      'charts': {
        'weeklyHours': [40, 38, 42, 35, 41, 0, 0],
        'monthlyTrend': [156, 148, 162, 140],
      },
    };
  }

  Future<Map<String, dynamic>> _generateSupervisorData(
      String supervisorId, DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'supervisorId': supervisorId,
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'summary': {
        'totalStudents': 15,
        'activeStudents': 12,
        'pendingApprovals': 8,
        'totalHoursSupervised': 1240.5,
      },
      'students': List.generate(15, (index) {
        return {
          'id': 'student_$index',
          'name': 'Estudante ${index + 1}',
          'hoursThisMonth': 120 + (index * 5),
          'status': index < 12 ? 'active' : 'inactive',
        };
      }),
      'approvals': {
        'pending': 8,
        'approved': 45,
        'rejected': 3,
      },
    };
  }

  Future<Map<String, dynamic>> _generateContractData(
      DateTime? startDate, DateTime? endDate) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return {
      'summary': {
        'totalContracts': 25,
        'activeContracts': 18,
        'expiringContracts': 3,
        'completedContracts': 4,
      },
      'contracts': List.generate(25, (index) {
        return {
          'id': 'contract_$index',
          'studentName': 'Estudante ${index + 1}',
          'startDate': DateTime.now()
              .subtract(Duration(days: 30 + index))
              .toIso8601String(),
          'endDate':
              DateTime.now().add(Duration(days: 300 - index)).toIso8601String(),
          'status': index < 18
              ? 'active'
              : index < 21
                  ? 'expiring'
                  : 'completed',
          'hoursCompleted': 120 + (index * 10),
          'hoursRequired': 300,
        };
      }),
      'statusDistribution': {
        'active': 18,
        'pending': 2,
        'expired': 1,
        'completed': 4,
      },
    };
  }

  Future<Map<String, dynamic>> _generateAttendanceData(
      DateTime startDate, DateTime endDate, List<String>? studentIds) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'summary': {
        'totalStudents': studentIds?.length ?? 20,
        'averageAttendance': 92.5,
        'totalDays': 22,
      },
      'attendance': List.generate(studentIds?.length ?? 20, (studentIndex) {
        return {
          'studentId': studentIds?[studentIndex] ?? 'student_$studentIndex',
          'studentName': 'Estudante ${studentIndex + 1}',
          'attendanceRate': 85.0 + (studentIndex * 2),
          'daysPresent': 18 + (studentIndex % 5),
          'daysAbsent': 4 - (studentIndex % 5),
        };
      }),
    };
  }

  Future<Map<String, dynamic>> _generatePerformanceData(
      DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'metrics': {
        'averageHoursPerStudent': 145.2,
        'approvalRate': 94.8,
        'onTimePercentage': 91.3,
        'productivityScore': 87.6,
      },
      'trends': {
        'weekly': [85, 88, 92, 87, 90, 89, 91],
        'monthly': [87, 89, 91, 88],
      },
      'topPerformers': List.generate(5, (index) {
        return {
          'rank': index + 1,
          'studentName': 'Estudante ${index + 1}',
          'score': 95 - (index * 2),
          'hours': 180 - (index * 5),
        };
      }),
    };
  }

  // Métodos de conversão de formato

  String _convertToCsv(ReportData report) {
    final buffer = StringBuffer();

    // Cabeçalho
    buffer.writeln('Relatório: ${report.title}');
    buffer.writeln('Gerado em: ${report.generatedAt.toIso8601String()}');
    buffer.writeln('Gerado por: ${report.generatedBy}');
    buffer.writeln();

    // Dados (simplificado)
    if (report.data.containsKey('summary')) {
      final summary = report.data['summary'] as Map<String, dynamic>;
      buffer.writeln('Métrica,Valor');
      summary.forEach((key, value) {
        buffer.writeln('$key,$value');
      });
    }

    return buffer.toString();
  }

  Future<String> _convertToPdf(ReportData report) async {
    // Implementação simplificada - em produção usaria uma biblioteca como pdf
    return '''
    PDF Report: ${report.title}
    Generated: ${report.generatedAt.toIso8601String()}
    Data: ${jsonEncode(report.data)}
    ''';
  }

  Future<String> _convertToExcel(ReportData report) async {
    // Implementação simplificada - em produção usaria uma biblioteca como excel
    return '''
    Excel Report: ${report.title}
    Generated: ${report.generatedAt.toIso8601String()}
    Data: ${jsonEncode(report.data)}
    ''';
  }

  // Métodos auxiliares

  Future<String> _saveFile(
      String fileName, String content, bool isBinary) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reports/$fileName');

    await file.parent.create(recursive: true);
    await file.writeAsString(content);

    return file.path;
  }

  void _addToHistory(ReportData report) {
    _reportsHistory.insert(0, report);

    // Mantém apenas os últimos 50 relatórios
    if (_reportsHistory.length > 50) {
      _reportsHistory = _reportsHistory.take(50).toList();
    }

    _saveReportsHistory();
  }

  Future<void> _saveReportsHistory() async {
    // Implementação futura com persistência
  }

  Future<void> _loadReportsHistory() async {
    // Implementação futura com persistência
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Dispose do serviço
  void dispose() {
    _reportGeneratedController.close();
    _exportProgressController.close();
    _isInitialized = false;
  }

  // ---- Compat: wrappers e assinaturas legadas usadas em testes ----
  Future<ReportData> generateTimeLogReport({
    required String studentId,
    required String studentName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return generateStudentTimeLogReport(
      studentId: studentId,
      studentName: studentName,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ReportData> generateStudentPerformanceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return generatePerformanceMetricsReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ReportData> generateContractReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return generateContractStatusReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<String?> exportToCSV(ReportData report) async {
    return exportReport(report: report, format: ExportFormat.csv);
  }

  Future<String?> exportToJSON(ReportData report) async {
    return exportReport(report: report, format: ExportFormat.json);
  }

  // Assinatura legada para share
  Future<void> shareReportLegacy(String filePath, {String? subject}) async {
    await Share.shareXFiles([XFile(filePath)], text: subject);
  }
}
