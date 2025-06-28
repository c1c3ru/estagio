import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/enums/student_status.dart'
    as student_status_enum;
import 'package:gestao_de_estagio/domain/entities/filter_students_params.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/register_usecase.dart';
import 'package:gestao_de_estagio/features/supervisor/bloc/supervisor_event.dart';
import 'package:gestao_de_estagio/features/supervisor/bloc/supervisor_state.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../domain/entities/student_entity.dart';
import '../../../../domain/entities/time_log_entity.dart';
import '../../../../domain/entities/contract_entity.dart';
import '../../../../domain/usecases/supervisor/get_all_time_logs_for_supervisor_usecase.dart';
import '../../../../domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart';
import '../../../../domain/usecases/contract/get_all_contracts_usecase.dart';

// Usecases de Supervisor
import '../../../../domain/usecases/supervisor/get_supervisor_details_usecase.dart';
import '../../../../domain/usecases/supervisor/get_all_students_for_supervisor_usecase.dart';
import '../../../../domain/usecases/supervisor/get_student_details_for_supervisor_usecase.dart';
import '../../../../domain/usecases/supervisor/create_student_by_supervisor_usecase.dart';
import '../../../../domain/usecases/supervisor/update_student_by_supervisor_usecase.dart';
import '../../../../domain/usecases/supervisor/delete_student_by_supervisor_usecase.dart';

// Usecases de Contrato (usados pelo Supervisor)
import '../../../../domain/usecases/contract/create_contract_usecase.dart';
import '../../../../domain/usecases/contract/update_contract_usecase.dart';
import '../../../../domain/usecases/contract/delete_contract_usecase.dart';

import '../../../../core/enums/user_role.dart';

class SupervisorBloc extends Bloc<SupervisorEvent, SupervisorState> {
  // Usecases
  final GetAllStudentsForSupervisorUsecase _getAllStudentsForSupervisorUsecase;
  final GetStudentDetailsForSupervisorUsecase
      _getStudentDetailsForSupervisorUsecase;
  final CreateStudentBySupervisorUsecase _createStudentBySupervisorUsecase;
  final UpdateStudentBySupervisorUsecase _updateStudentBySupervisorUsecase;
  final DeleteStudentBySupervisorUsecase _deleteStudentBySupervisorUsecase;
  final GetAllTimeLogsForSupervisorUsecase _getAllTimeLogsForSupervisorUsecase;
  final ApproveOrRejectTimeLogUsecase _approveOrRejectTimeLogUsecase;
  final GetAllContractsUsecase _getAllContractsUsecase;
  final CreateContractUsecase _createContractUsecase;
  final UpdateContractUsecase _updateContractUsecase;
  final RegisterUsecase _registerAuthUserUsecase;

  SupervisorBloc({
    required GetSupervisorDetailsUsecase getSupervisorDetailsUsecase,
    required GetAllStudentsForSupervisorUsecase
        getAllStudentsForSupervisorUsecase,
    required GetStudentDetailsForSupervisorUsecase
        getStudentDetailsForSupervisorUsecase,
    required CreateStudentBySupervisorUsecase createStudentBySupervisorUsecase,
    required UpdateStudentBySupervisorUsecase updateStudentBySupervisorUsecase,
    required DeleteStudentBySupervisorUsecase deleteStudentBySupervisorUsecase,
    required GetAllTimeLogsForSupervisorUsecase
        getAllTimeLogsForSupervisorUsecase,
    required ApproveOrRejectTimeLogUsecase approveOrRejectTimeLogUsecase,
    required GetAllContractsUsecase getAllContractsUsecase,
    required CreateContractUsecase createContractUsecase,
    required UpdateContractUsecase updateContractUsecase,
    required DeleteContractUsecase deleteContractUsecase,
    required RegisterUsecase registerAuthUserUsecase,
  })  : _getAllStudentsForSupervisorUsecase =
            getAllStudentsForSupervisorUsecase,
        _getStudentDetailsForSupervisorUsecase =
            getStudentDetailsForSupervisorUsecase,
        _createStudentBySupervisorUsecase = createStudentBySupervisorUsecase,
        _updateStudentBySupervisorUsecase = updateStudentBySupervisorUsecase,
        _deleteStudentBySupervisorUsecase = deleteStudentBySupervisorUsecase,
        _getAllTimeLogsForSupervisorUsecase =
            getAllTimeLogsForSupervisorUsecase,
        _approveOrRejectTimeLogUsecase = approveOrRejectTimeLogUsecase,
        _getAllContractsUsecase = getAllContractsUsecase,
        _createContractUsecase = createContractUsecase,
        _updateContractUsecase = updateContractUsecase,
        _registerAuthUserUsecase = registerAuthUserUsecase,
        super(const SupervisorInitial()) {
    on<LoadSupervisorDashboardDataEvent>(_onLoadSupervisorDashboardData);
    on<FilterStudentsEvent>(_onFilterStudents);
    on<LoadStudentDetailsForSupervisorEvent>(
        _onLoadStudentDetailsForSupervisor);
    on<CreateStudentBySupervisorEvent>(_onCreateStudentBySupervisor);
    on<UpdateStudentBySupervisorEvent>(_onUpdateStudentBySupervisor);
    on<DeleteStudentBySupervisorEvent>(_onDeleteStudentBySupervisor);
    on<LoadAllTimeLogsForApprovalEvent>(_onLoadAllTimeLogsForApproval);
    on<ApproveOrRejectTimeLogEvent>(_onApproveOrRejectTimeLog);
    on<LoadAllContractsEvent>(_onLoadAllContracts);
    on<CreateContractBySupervisorEvent>(_onCreateContractBySupervisor);
    on<UpdateContractBySupervisorEvent>(_onUpdateContractBySupervisor);
    on<ToggleDashboardViewEvent>(_onToggleDashboardView);
  }

  Future<void> _onLoadSupervisorDashboardData(
    LoadSupervisorDashboardDataEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    if (state is! SupervisorDashboardLoadSuccess) {
      emit(const SupervisorLoading(
          loadingMessage: 'A carregar dados do dashboard...'));
    }

    try {
      final results = await Future.wait([
        _getAllStudentsForSupervisorUsecase.call(),
        _getAllContractsUsecase.call(const GetAllContractsParams()),
        _getAllTimeLogsForSupervisorUsecase
            .call(const GetAllTimeLogsParams(pendingOnly: true)),
      ]);

      final studentsResult =
          results[0] as Either<AppFailure, List<StudentEntity>>;
      final List<StudentEntity> students = studentsResult.fold(
        (failure) => throw failure,
        (studentList) => studentList,
      );

      final contractsResult =
          results[1] as Either<AppFailure, List<ContractEntity>>;
      final List<ContractEntity> contracts = contractsResult.fold(
        (failure) => throw failure,
        (contractList) => contractList,
      );

      final timeLogsResult =
          results[2] as Either<AppFailure, List<TimeLogEntity>>;
      final List<TimeLogEntity> pendingApprovals = timeLogsResult.fold(
        (failure) => throw failure,
        (timeLogList) => timeLogList,
      );

      final now = DateTime.now();
      final activeStudents = students
          .where(
              (s) => s.status == student_status_enum.StudentStatus.active.name)
          .length;
      final inactiveStudents = students
          .where((s) =>
              s.status == student_status_enum.StudentStatus.inactive.name)
          .length;
      final expiringContractsSoon = contracts
          .where((c) =>
              c.endDate.isAfter(now) &&
              c.endDate.isBefore(now.add(const Duration(days: 30))))
          .length;

      final stats = SupervisorDashboardStats(
        totalStudents: students.length,
        activeStudents: activeStudents,
        inactiveStudents: inactiveStudents,
        expiringContractsSoon: expiringContractsSoon,
      );

      emit(SupervisorDashboardLoadSuccess(
        students: students,
        contracts: contracts,
        stats: stats,
        pendingApprovals: pendingApprovals,
        showGanttView: (state is SupervisorDashboardLoadSuccess)
            ? (state as SupervisorDashboardLoadSuccess).showGanttView
            : false,
      ));
    } on AppFailure catch (e) {
      emit(SupervisorOperationFailure(message: e.message));
    } catch (e) {
      emit(SupervisorOperationFailure(
          message:
              'Ocorreu um erro inesperado ao carregar o dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onFilterStudents(
    FilterStudentsEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is SupervisorDashboardLoadSuccess) {
      emit(currentState.copyWith(isLoading: true));

      final result =
          await _getAllStudentsForSupervisorUsecase.call(params: event.params);

      result.fold(
        (failure) => emit(SupervisorOperationFailure(message: failure.message)),
        (filteredStudents) {
          emit(currentState.copyWith(
            students: filteredStudents,
            isLoading: false,
            appliedFilters: event.params,
          ));
        },
      );
    } else {
      add(LoadSupervisorDashboardDataEvent());
    }
  }

  Future<void> _onApproveOrRejectTimeLog(
    ApproveOrRejectTimeLogEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    if (state is SupervisorDashboardLoadSuccess) {
      final currentState = state as SupervisorDashboardLoadSuccess;
      emit(currentState.copyWith(isLoading: true));

      try {
        final result = await _approveOrRejectTimeLogUsecase.call(
          ApproveOrRejectTimeLogParams(
            timeLogId: event.timeLogId,
            approved: event.approved,
            supervisorId: event.supervisorId,
            rejectionReason: event.rejectionReason,
          ),
        );

        result.fold(
          (failure) =>
              emit(SupervisorOperationFailure(message: failure.message)),
          (_) {
            // Recarrega os logs pendentes após aprovar/rejeitar
            add(const LoadAllTimeLogsForApprovalEvent(pendingOnly: true));
          },
        );
      } catch (e) {
        emit(SupervisorOperationFailure(
            message: 'Erro ao processar o registro de tempo: ${e.toString()}'));
      }
    }
  }

  void _onToggleDashboardView(
    ToggleDashboardViewEvent event,
    Emitter<SupervisorState> emit,
  ) {
    if (state is SupervisorDashboardLoadSuccess) {
      final currentDashboardState = state as SupervisorDashboardLoadSuccess;
      emit(currentDashboardState.copyWith(
          showGanttView: !currentDashboardState.showGanttView,
          isLoading: true,
          appliedFilters: const FilterStudentsParams(
              status: student_status_enum.StudentStatus.active),
          pendingApprovals: []));
    }
  }

  // --- Other Event Handlers (unchanged) ---
  Future<void> _onLoadStudentDetailsForSupervisor(
    LoadStudentDetailsForSupervisorEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading(
        loadingMessage: 'A carregar detalhes do estudante...'));
    try {
      final studentResult =
          await _getStudentDetailsForSupervisorUsecase.call(event.studentId);
      final (student, timeLogs, contracts) = studentResult.fold(
        (failure) => throw failure,
        (s) => s,
      );

      emit(SupervisorStudentDetailsLoadSuccess(
        student: student,
        timeLogs: timeLogs,
        contracts: contracts,
      ));
    } catch (e) {
      emit(SupervisorOperationFailure(
          message: e is AppFailure
              ? e.message
              : 'Erro ao carregar detalhes do estudante.'));
    }
  }

  Future<void> _onCreateStudentBySupervisor(
    CreateStudentBySupervisorEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading(loadingMessage: 'A criar estudante...'));

    final authResult = await _registerAuthUserUsecase.call(
      fullName: event.studentData.fullName,
      email: event.initialEmail,
      password: event.initialPassword,
      role: UserRole.student,
      registration: event.studentData.registrationNumber,
    );

    await authResult.fold(
      (failure) async {
        emit(SupervisorOperationFailure(
            message:
                'Falha ao criar utilizador de autenticação: ${failure.message}'));
      },
      (authUserEntity) async {
        try {
          final studentToCreate =
              event.studentData.copyWith(id: authUserEntity.id);

          final studentProfileResult =
              await _createStudentBySupervisorUsecase.call(studentToCreate);

          studentProfileResult.fold(
            (profileFailure) {
              emit(SupervisorOperationFailure(
                  message:
                      'Utilizador auth criado, mas falha ao criar perfil de estudante: ${profileFailure.message}'));
            },
            (createdStudent) {
              emit(SupervisorOperationSuccess(
                  message: 'Estudante criado com sucesso!',
                  entity: createdStudent));
              add(LoadSupervisorDashboardDataEvent());
            },
          );
        } catch (e) {
          emit(SupervisorOperationFailure(
              message: e is AppFailure
                  ? e.message
                  : 'Erro ao criar perfil de estudante.'));
        }
      },
    );
  }

  Future<void> _onUpdateStudentBySupervisor(
    UpdateStudentBySupervisorEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading(loadingMessage: 'A atualizar estudante...'));
    final result =
        await _updateStudentBySupervisorUsecase.call(event.studentData);
    result.fold(
      (failure) => emit(SupervisorOperationFailure(message: failure.message)),
      (updatedStudent) {
        emit(SupervisorOperationSuccess(
            message: 'Estudante atualizado com sucesso!',
            entity: updatedStudent));
        add(LoadSupervisorDashboardDataEvent());
      },
    );
  }

  Future<void> _onDeleteStudentBySupervisor(
    DeleteStudentBySupervisorEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading(loadingMessage: 'A remover estudante...'));
    final result =
        await _deleteStudentBySupervisorUsecase.call(event.studentId);
    result.fold(
      (failure) => emit(SupervisorOperationFailure(message: failure.message)),
      (_) {
        emit(const SupervisorOperationSuccess(
            message: 'Estudante removido com sucesso!'));
        add(LoadSupervisorDashboardDataEvent());
      },
    );
  }

  Future<void> _onLoadAllTimeLogsForApproval(
    LoadAllTimeLogsForApprovalEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    if (state is SupervisorDashboardLoadSuccess) {
      final currentState = state as SupervisorDashboardLoadSuccess;
      emit(currentState.copyWith(isLoading: true));

      final result = await _getAllTimeLogsForSupervisorUsecase.call(
        GetAllTimeLogsParams(
          studentId: event.studentIdFilter,
          pendingOnly: event.pendingOnly,
        ),
      );

      result.fold(
        (failure) => emit(SupervisorOperationFailure(message: failure.message)),
        (timeLogs) {
          emit(currentState.copyWith(
            pendingApprovals: timeLogs,
            isLoading: false,
          ));
        },
      );
    }
  }

  Future<void> _onLoadAllContracts(
    LoadAllContractsEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    if (state is SupervisorDashboardLoadSuccess) {
      final currentState = state as SupervisorDashboardLoadSuccess;
      emit(currentState.copyWith(isLoading: true));

      final result = await _getAllContractsUsecase.call(
        GetAllContractsParams(
          studentId: event.studentIdFilter,
          status: event.statusFilter,
        ),
      );

      result.fold(
        (failure) => emit(SupervisorOperationFailure(message: failure.message)),
        (contracts) {
          emit(currentState.copyWith(
            contracts: contracts,
            isLoading: false,
          ));
        },
      );
    }
  }

  Future<void> _onCreateContractBySupervisor(
    CreateContractBySupervisorEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading(loadingMessage: 'A criar contrato...'));
    final result = await _createContractUsecase.call(event.contract);
    result.fold(
        (failure) => emit(SupervisorOperationFailure(message: failure.message)),
        (newContract) {
      emit(SupervisorOperationSuccess(
          message: 'Contrato criado com sucesso!', entity: newContract));
      add(LoadSupervisorDashboardDataEvent());
    });
  }

  Future<void> _onUpdateContractBySupervisor(
    UpdateContractBySupervisorEvent event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading(loadingMessage: 'A atualizar contrato...'));
    final result = await _updateContractUsecase.call(event.contract);
    result.fold(
        (failure) => emit(SupervisorOperationFailure(message: failure.message)),
        (updatedContract) {
      emit(SupervisorOperationSuccess(
          message: 'Contrato atualizado com sucesso!',
          entity: updatedContract));
      add(LoadSupervisorDashboardDataEvent());
    });
  }
}
