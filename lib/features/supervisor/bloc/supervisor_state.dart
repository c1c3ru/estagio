// lib/features/supervisor/presentation/bloc/supervisor_state.dart
import 'package:equatable/equatable.dart';
import 'package:gestao_de_estagio/domain/entities/filter_students_params.dart';
import '../../../domain/entities/supervisor_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/entities/time_log_entity.dart';
import '../../../domain/entities/contract_entity.dart';

// Dados agregados para o dashboard do supervisor
class SupervisorDashboardStats extends Equatable {
  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents; // Ou outros status relevantes
  final int expiringContractsSoon; // Contratos a vencer nos próximos X dias

  const SupervisorDashboardStats({
    required this.totalStudents,
    required this.activeStudents,
    required this.inactiveStudents,
    required this.expiringContractsSoon,
  });

  @override
  List<Object?> get props => [
        totalStudents,
        activeStudents,
        inactiveStudents,
        expiringContractsSoon,
      ];

  SupervisorDashboardStats copyWith({
    int? totalStudents,
    int? activeStudents,
    int? inactiveStudents,
    int? expiringContractsSoon,
  }) {
    return SupervisorDashboardStats(
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      inactiveStudents: inactiveStudents ?? this.inactiveStudents,
      expiringContractsSoon:
          expiringContractsSoon ?? this.expiringContractsSoon,
    );
  }
}

abstract class SupervisorState extends Equatable {
  const SupervisorState();

  @override
  List<Object?> get props => [];
}

class SupervisorInitial extends SupervisorState {
  const SupervisorInitial();
}

class SupervisorLoading extends SupervisorState {
  final String loadingMessage;

  const SupervisorLoading({required this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

/// Estado quando os dados do dashboard do supervisor são carregados.
class SupervisorDashboardLoadSuccess extends SupervisorState {
  final SupervisorEntity?
      supervisorProfile; // Perfil do supervisor logado (opcional aqui)
  final List<StudentEntity> students; // Lista de estudantes (pode ser filtrada)
  final List<ContractEntity>
      contracts; // Lista de contratos para o Gantt ou visão geral
  final SupervisorDashboardStats stats;
  final bool showGanttView;
  final List<TimeLogEntity> pendingApprovals; // Para aprovações pendentes
  final bool isLoading;
  final FilterStudentsParams? appliedFilters;

  const SupervisorDashboardLoadSuccess({
    this.supervisorProfile,
    required this.students,
    required this.contracts,
    required this.stats,
    this.showGanttView = false,
    required this.pendingApprovals,
    this.isLoading = false,
    this.appliedFilters,
  });

  @override
  List<Object?> get props => [
        supervisorProfile,
        students,
        contracts,
        stats,
        showGanttView,
        pendingApprovals,
        isLoading,
        appliedFilters,
      ];

  SupervisorDashboardLoadSuccess copyWith({
    SupervisorEntity? supervisorProfile,
    List<StudentEntity>? students,
    List<ContractEntity>? contracts,
    SupervisorDashboardStats? stats,
    bool? showGanttView,
    List<TimeLogEntity>? pendingApprovals,
    bool? isLoading,
    FilterStudentsParams? appliedFilters,
  }) {
    return SupervisorDashboardLoadSuccess(
      supervisorProfile: supervisorProfile ?? this.supervisorProfile,
      students: students ?? this.students,
      contracts: contracts ?? this.contracts,
      stats: stats ?? this.stats,
      showGanttView: showGanttView ?? this.showGanttView,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      isLoading: isLoading ?? this.isLoading,
      appliedFilters: appliedFilters ?? this.appliedFilters,
    );
  }
}

/// Estado quando os detalhes de um estudante específico são carregados.
class SupervisorStudentDetailsLoadSuccess extends SupervisorState {
  final StudentEntity student;
  final List<TimeLogEntity> timeLogs; // Logs de tempo do estudante
  final List<ContractEntity> contracts; // Contratos do estudante

  const SupervisorStudentDetailsLoadSuccess({
    required this.student,
    required this.timeLogs,
    required this.contracts,
  });

  @override
  List<Object?> get props => [student, timeLogs, contracts];
}

/// Estado quando a lista de logs para aprovação é carregada.
class SupervisorTimeLogsForApprovalLoadSuccess extends SupervisorState {
  final List<TimeLogEntity> timeLogs;

  const SupervisorTimeLogsForApprovalLoadSuccess({required this.timeLogs});

  @override
  List<Object?> get props => [timeLogs];
}

/// Estado quando a lista de contratos é carregada (para uma página de gestão de contratos, por exemplo).
class SupervisorContractsLoadSuccess extends SupervisorState {
  final List<ContractEntity> contracts;

  const SupervisorContractsLoadSuccess({required this.contracts});

  @override
  List<Object?> get props => [contracts];
}

/// Estado de sucesso para operações CRUD (Criar, Atualizar, Remover estudante/contrato, Aprovar log).
class SupervisorOperationSuccess extends SupervisorState {
  final String message;
  final dynamic entity; // A entidade que foi criada/atualizada (opcional)

  const SupervisorOperationSuccess({
    required this.message,
    this.entity,
  });

  @override
  List<Object?> get props => [message, entity];
}

/// Estado de falha para operações do supervisor.
class SupervisorOperationFailure extends SupervisorState {
  final String message;

  const SupervisorOperationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthErrorState extends SupervisorState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthSuccessState extends SupervisorState {
  final String message;

  const AuthSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthLoadingState extends SupervisorState {
  final String? message;

  const AuthLoadingState({this.message});

  @override
  List<Object?> get props => [message];
}
