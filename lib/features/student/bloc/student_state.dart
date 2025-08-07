// lib/features/student/presentation/bloc/student_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/student_entity.dart';
import '../../../../domain/entities/time_log_entity.dart';
import '../../../../domain/entities/contract_entity.dart'; // Se o dashboard mostrar info de contrato

// Estrutura para agrupar estatísticas de tempo, se necessário
class StudentTimeStats extends Equatable {
  final double hoursThisWeek;
  final double hoursThisMonth; // Exemplo
  final List<TimeLogEntity> recentLogs;
  final TimeLogEntity? activeTimeLog; // Log de tempo ativo (se houver check-in)

  const StudentTimeStats({
    this.hoursThisWeek = 0.0,
    this.hoursThisMonth = 0.0,
    this.recentLogs = const [],
    this.activeTimeLog,
  });

  @override
  List<Object?> get props =>
      [hoursThisWeek, hoursThisMonth, recentLogs, activeTimeLog];

  StudentTimeStats copyWith({
    double? hoursThisWeek,
    double? hoursThisMonth,
    List<TimeLogEntity>? recentLogs,
    TimeLogEntity? activeTimeLog,
    bool? clearActiveTimeLog,
  }) {
    return StudentTimeStats(
      hoursThisWeek: hoursThisWeek ?? this.hoursThisWeek,
      hoursThisMonth: hoursThisMonth ?? this.hoursThisMonth,
      recentLogs: recentLogs ?? this.recentLogs,
      activeTimeLog: clearActiveTimeLog == true
          ? null
          : activeTimeLog ?? this.activeTimeLog,
    );
  }
}

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

/// Estado quando os dados do dashboard do estudante são carregados com sucesso.
class StudentDashboardLoadSuccess extends StudentState {
  final StudentEntity student;
  final StudentTimeStats timeStats; // Agrupa estatísticas de tempo
  final List<ContractEntity> contracts; // Contratos do estudante

  const StudentDashboardLoadSuccess({
    required this.student,
    required this.timeStats,
    this.contracts = const [],
  });

  @override
  List<Object?> get props => [student, timeStats, contracts];

  StudentDashboardLoadSuccess copyWith({
    StudentEntity? student,
    StudentTimeStats? timeStats,
    List<ContractEntity>? contracts,
  }) {
    return StudentDashboardLoadSuccess(
      student: student ?? this.student,
      timeStats: timeStats ?? this.timeStats,
      contracts: contracts ?? this.contracts,
    );
  }
}

/// Estado quando os registos de tempo são carregados (para a página de logs).
class StudentTimeLogsLoadSuccess extends StudentState {
  final List<TimeLogEntity> timeLogs;
  // Adicione informações de paginação se implementado
  // final bool hasReachedMax;

  const StudentTimeLogsLoadSuccess({
    required this.timeLogs,
    // this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [timeLogs /*, hasReachedMax*/];
}

/// Estado de sucesso para operações de check-in/check-out/criação/atualização de log.
class StudentTimeLogOperationSuccess extends StudentState {
  final TimeLogEntity? timeLog; // O log que foi criado/atualizado
  final String message;

  const StudentTimeLogOperationSuccess(
      {this.timeLog, required this.message});

  @override
  List<Object?> get props => [timeLog, message];
}

/// Estado de sucesso para remoção de log de tempo.
class StudentTimeLogDeleteSuccess extends StudentState {
  final String message;
  const StudentTimeLogDeleteSuccess(
      {this.message = 'Registo de tempo removido com sucesso.'});
  @override
  List<Object?> get props => [message];
}

/// Estado de sucesso na atualização do perfil do estudante.
class StudentProfileUpdateSuccess extends StudentState {
  final StudentEntity updatedStudent;
  final String message;

  const StudentProfileUpdateSuccess(
      {required this.updatedStudent,
      this.message = 'Perfil atualizado com sucesso!'});

  @override
  List<Object?> get props => [updatedStudent, message];
}

/// Estado quando um log de tempo ativo é encontrado (ou não).
class ActiveTimeLogFetched extends StudentState {
  final TimeLogEntity? activeTimeLog; // Null se não houver log ativo

  const ActiveTimeLogFetched({this.activeTimeLog});

  @override
  List<Object?> get props => [activeTimeLog];
}

/// Estado de falha para operações do estudante.
class StudentOperationFailure extends StudentState {
  final String message;

  const StudentOperationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class StudentDetailsLoaded extends StudentState {
  final StudentEntity student;
  const StudentDetailsLoaded({required this.student});

  @override
  List<Object> get props => [student];
}

class StudentDashboardLoading extends StudentState {}

class StudentDashboardLoaded extends StudentState {
  final Map<String, dynamic> dashboardData;
  const StudentDashboardLoaded({required this.dashboardData});

  @override
  List<Object> get props => [dashboardData];
}

class StudentDashboardError extends StudentState {
  final String message;
  const StudentDashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
