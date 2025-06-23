// lib/features/supervisor/presentation/bloc/supervisor_event.dart
import 'package:equatable/equatable.dart';
import 'package:gestao_de_estagio/domain/entities/filter_students_params.dart';
import '../../../core/enums/contract_status.dart';
import '../../../domain/entities/contract_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/entities/supervisor_entity.dart';
// Importe UserRole e StudentStatus dos seus enums centrais

abstract class SupervisorEvent extends Equatable {
  const SupervisorEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar os dados iniciais do dashboard do supervisor.
class LoadSupervisorDashboardDataEvent extends SupervisorEvent {}

/// Evento para filtrar a lista de estudantes no dashboard.
class FilterStudentsEvent extends SupervisorEvent {
  final FilterStudentsParams params;

  const FilterStudentsEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Evento para carregar os detalhes de um estudante específico.
class LoadStudentDetailsForSupervisorEvent extends SupervisorEvent {
  final String studentId;

  const LoadStudentDetailsForSupervisorEvent({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

/// Evento para o supervisor criar um novo estudante.
/// O StudentEntity aqui conteria os dados do formulário de criação.
class CreateStudentBySupervisorEvent extends SupervisorEvent {
  final StudentEntity studentData;
  final String initialEmail;
  final String initialPassword;

  const CreateStudentBySupervisorEvent({
    required this.studentData,
    required this.initialEmail,
    required this.initialPassword,
  });

  @override
  List<Object?> get props => [studentData, initialEmail, initialPassword];
}

/// Evento para o supervisor atualizar os dados de um estudante.
class UpdateStudentBySupervisorEvent extends SupervisorEvent {
  final StudentEntity studentData;

  const UpdateStudentBySupervisorEvent({required this.studentData});

  @override
  List<Object?> get props => [studentData];
}

/// Evento para o supervisor remover um estudante.
class DeleteStudentBySupervisorEvent extends SupervisorEvent {
  final String studentId;

  const DeleteStudentBySupervisorEvent({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

/// Evento para carregar todos os registos de tempo (para aprovação ou visualização).
class LoadAllTimeLogsForApprovalEvent extends SupervisorEvent {
  final String? studentIdFilter;
  final bool pendingOnly;

  const LoadAllTimeLogsForApprovalEvent({
    this.studentIdFilter,
    this.pendingOnly = true,
  });

  @override
  List<Object?> get props => [studentIdFilter, pendingOnly];
}

/// Evento para o supervisor aprovar ou rejeitar um registo de tempo.
class ApproveOrRejectTimeLogEvent extends SupervisorEvent {
  final String timeLogId;
  final bool approved;
  final String supervisorId;
  final String? rejectionReason;

  const ApproveOrRejectTimeLogEvent({
    required this.timeLogId,
    required this.approved,
    required this.supervisorId,
    this.rejectionReason,
  });

  @override
  List<Object?> get props =>
      [timeLogId, approved, supervisorId, rejectionReason];
}

/// Evento para carregar todos os contratos (para visualização ou gestão).
class LoadAllContractsEvent extends SupervisorEvent {
  final String? studentIdFilter;
  final ContractStatus? statusFilter;

  const LoadAllContractsEvent({
    this.studentIdFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [studentIdFilter, statusFilter];
}

/// Evento para o supervisor criar um novo contrato.
class CreateContractBySupervisorEvent extends SupervisorEvent {
  final ContractEntity contract;

  const CreateContractBySupervisorEvent({required this.contract});

  @override
  List<Object?> get props => [contract];
}

/// Evento para o supervisor atualizar um contrato existente.
class UpdateContractBySupervisorEvent extends SupervisorEvent {
  final ContractEntity contract;

  const UpdateContractBySupervisorEvent({required this.contract});

  @override
  List<Object?> get props => [contract];
}

/// Evento para alternar a visualização no dashboard (ex: Lista vs Gantt).
class ToggleDashboardViewEvent extends SupervisorEvent {}

/// Evento para carregar todos os supervisores (admin).
class LoadAllSupervisorsEvent extends SupervisorEvent {}

/// Evento para criar supervisor (admin).
class CreateSupervisorEvent extends SupervisorEvent {
  final SupervisorEntity supervisor;
  final String initialEmail;
  final String initialPassword;
  const CreateSupervisorEvent(
      {required this.supervisor,
      required this.initialEmail,
      required this.initialPassword});
  @override
  List<Object?> get props => [supervisor, initialEmail, initialPassword];
}

/// Evento para atualizar supervisor (admin).
class UpdateSupervisorEvent extends SupervisorEvent {
  final SupervisorEntity supervisor;
  const UpdateSupervisorEvent({required this.supervisor});
  @override
  List<Object?> get props => [supervisor];
}

/// Evento para deletar supervisor (admin).
class DeleteSupervisorEvent extends SupervisorEvent {
  final String supervisorId;
  const DeleteSupervisorEvent(this.supervisorId);
  @override
  List<Object?> get props => [supervisorId];
}
