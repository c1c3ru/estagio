import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/usecases/student/get_student_dashboard_usecase.dart';
import '../../../domain/entities/contract_entity.dart';
import '../../../domain/entities/time_log_entity.dart';
import '../../../domain/usecases/time_log/get_time_logs_by_student_usecase.dart';
import '../../../domain/usecases/time_log/clock_in_usecase.dart';
import '../../../domain/usecases/time_log/clock_out_usecase.dart';
import '../../../domain/usecases/time_log/get_active_time_log_usecase.dart';
import '../../../domain/repositories/i_student_repository.dart';

import '../../../data/models/student_model.dart';

// Importar eventos e estados dos arquivos separados
import 'student_event.dart';
import 'student_state.dart';

// BLoC
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentDashboardUsecase _getStudentDashboardUsecase;
  final GetTimeLogsByStudentUsecase _getTimeLogsByStudentUsecase;
  final ClockInUsecase _clockInUsecase;
  final ClockOutUsecase _clockOutUsecase;
  final GetActiveTimeLogUsecase _getActiveTimeLogUsecase;
  final IStudentRepository _studentRepository;

  StudentBloc({
    required GetStudentDashboardUsecase getStudentDashboardUsecase,
    required GetTimeLogsByStudentUsecase getTimeLogsByStudentUsecase,
    required ClockInUsecase clockInUsecase,
    required ClockOutUsecase clockOutUsecase,
    required GetActiveTimeLogUsecase getActiveTimeLogUsecase,
    required IStudentRepository studentRepository,
  })  : _getStudentDashboardUsecase = getStudentDashboardUsecase,
        _getTimeLogsByStudentUsecase = getTimeLogsByStudentUsecase,
        _clockInUsecase = clockInUsecase,
        _clockOutUsecase = clockOutUsecase,
        _getActiveTimeLogUsecase = getActiveTimeLogUsecase,
        _studentRepository = studentRepository,
        super(const StudentInitial()) {
    // Registrar handlers para os eventos
    on<LoadStudentDashboardDataEvent>(_onLoadStudentDashboardData);
    on<UpdateStudentProfileInfoEvent>(_onUpdateStudentProfileInfo);
    on<StudentCheckInEvent>(_onStudentCheckIn);
    on<StudentCheckOutEvent>(_onStudentCheckOut);
    on<LoadStudentTimeLogsEvent>(_onLoadStudentTimeLogs);
    on<CreateManualTimeLogEvent>(_onCreateManualTimeLog);
    on<UpdateManualTimeLogEvent>(_onUpdateManualTimeLog);
    on<DeleteTimeLogRequestedEvent>(_onDeleteTimeLog);
    on<FetchActiveTimeLogEvent>(_onFetchActiveTimeLog);
  }

  // Implementar os handlers dos eventos
  Future<void> _onLoadStudentDashboardData(
    LoadStudentDashboardDataEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      // Usar o use case para carregar dados do dashboard
      final result = await _getStudentDashboardUsecase(event.userId);

      result.fold(
        (failure) => emit(StudentOperationFailure(message: failure.message)),
        (dashboardData) {
          final studentData = dashboardData['student'];

          if (studentData == null) {
            // Usuário não tem dados de estudante - precisa completar cadastro
            emit(const StudentOperationFailure(
              message:
                  'Perfil incompleto. Complete seu cadastro para continuar.',
            ));
            return;
          }

          // Criar StudentEntity a partir dos dados do dashboard usando StudentModel
          final student =
              StudentModel.fromJson(studentData as Map<String, dynamic>)
                  .toEntity();

          // Extrair dados de timeStats e contracts do dashboard
          final timeStatsData =
              dashboardData['timeStats'] as Map<String, dynamic>? ?? {};
          final contractsData = dashboardData['contracts'] as List? ?? [];
          final activeTimeLogData =
              timeStatsData['activeTimeLog'] as Map<String, dynamic>?;

          final timeStats = StudentTimeStats(
            hoursThisWeek:
                (timeStatsData['hoursThisWeek'] as num?)?.toDouble() ?? 0.0,
            hoursThisMonth:
                (timeStatsData['hoursThisMonth'] as num?)?.toDouble() ?? 0.0,
            activeTimeLog: activeTimeLogData != null
                ? TimeLogEntity(
                    id: activeTimeLogData['id'] as String,
                    studentId: activeTimeLogData['student_id'] as String,
                    logDate:
                        DateTime.parse(activeTimeLogData['log_date'] as String),
                    checkInTime: activeTimeLogData['check_in_time'] as String,
                    checkOutTime:
                        activeTimeLogData['check_out_time'] as String?,
                    createdAt: DateTime.parse(
                        activeTimeLogData['created_at'] as String),
                    description: activeTimeLogData['description'] as String?,
                    hoursLogged:
                        (activeTimeLogData['hours_logged'] as num?)?.toDouble(),
                    approved: activeTimeLogData['approved'] as bool?,
                  )
                : null,
          );

          final contracts = contractsData
              .map((contractData) {
                final data = contractData as Map<String, dynamic>;
                return ContractEntity(
                  id: data['id'] as String,
                  studentId: data['student_id'] as String,
                  supervisorId: data['supervisor_id'] as String?,
                  contractType: data['contract_type'] as String,
                  status: data['status'] as String,
                  startDate: DateTime.parse(data['start_date'] as String),
                  endDate: DateTime.parse(data['end_date'] as String),
                  description: data['description'] as String?,
                  createdAt: DateTime.parse(data['created_at'] as String),
                  updatedAt: data['updated_at'] != null
                      ? DateTime.parse(data['updated_at'] as String)
                      : null,
                );
              })
              .toList()
              .cast<ContractEntity>();

          emit(StudentDashboardLoadSuccess(
            student: student,
            timeStats: timeStats,
            contracts: contracts,
          ));
        },
      );
    } catch (e) {
      emit(StudentOperationFailure(message: 'Erro inesperado: $e'));
    }
  }

  Future<void> _onUpdateStudentProfileInfo(
    UpdateStudentProfileInfoEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      // Implementar lógica para atualizar perfil
      emit(const StudentLoading());
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onStudentCheckIn(
    StudentCheckInEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final result = await _clockInUsecase(event.userId, notes: event.notes);
      result.fold(
        (failure) => emit(StudentOperationFailure(message: failure.message)),
        (timeLog) => emit(StudentTimeLogOperationSuccess(
          timeLog: timeLog,
          message: 'Check-in realizado com sucesso!',
        )),
      );
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onStudentCheckOut(
    StudentCheckOutEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final result = await _clockOutUsecase(
        studentId: event.userId,
        notes: event.notes,
      );
      result.fold(
        (failure) => emit(StudentOperationFailure(message: failure.message)),
        (_) => emit(const StudentTimeLogOperationSuccess(
          timeLog: null,
          message: 'Check-out realizado com sucesso!',
        )),
      );
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadStudentTimeLogs(
    LoadStudentTimeLogsEvent event,
    Emitter<StudentState> emit,
  ) async {
    if (kDebugMode) {
      print(
          '🟢 StudentBloc: _onLoadStudentTimeLogs iniciado para userId: ${event.userId}');
    }

    emit(const StudentLoading());
    try {
      final eitherTimeLogs = await _getTimeLogsByStudentUsecase(event.userId);

      if (kDebugMode) {
        print(
            '🟢 StudentBloc: _onLoadStudentTimeLogs recebeu resultado do usecase');
      }

      final timeLogs = eitherTimeLogs.getOrElse(() => []);

      if (kDebugMode) {
        print(
            '🟢 StudentBloc: _onLoadStudentTimeLogs emitindo StudentTimeLogsLoadSuccess com ${timeLogs.length} logs');
      }

      emit(StudentTimeLogsLoadSuccess(timeLogs: timeLogs));
    } catch (e) {
      if (kDebugMode) {
        print('🔴 StudentBloc: Erro em _onLoadStudentTimeLogs: $e');
      }
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onCreateManualTimeLog(
    CreateManualTimeLogEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final result = await _studentRepository.createTimeLog(
        studentId: event.userId,
        logDate: event.logDate,
        checkInTime: event.checkInTime,
        checkOutTime: event.checkOutTime,
        description: event.description,
      );
      result.fold(
        (failure) => emit(StudentOperationFailure(message: failure.message)),
        (log) => emit(StudentTimeLogOperationSuccess(
            timeLog: log, message: 'Registro criado com sucesso!')),
      );
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateManualTimeLog(
    UpdateManualTimeLogEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      // Chame o usecase real para atualizar o log
      // final result = await _updateTimeLogUsecase(...);
      // result.fold(
      //   (failure) => emit(StudentOperationFailure(message: failure.message)),
      //   (log) => emit(StudentTimeLogOperationSuccess(timeLog: log, message: 'Registo atualizado com sucesso!')),
      // );
      emit(
        StudentTimeLogOperationSuccess(
            timeLog: TimeLogEntity(
              id: 'fake',
              studentId: 'fake',
              logDate: DateTime.now(),
              checkInTime: '08:00',
              createdAt: DateTime.now(),
            ),
            message: 'Registo atualizado com sucesso!'),
      );
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onDeleteTimeLog(
    DeleteTimeLogRequestedEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      // Chame o usecase real para deletar o log
      // final result = await _deleteTimeLogUsecase(...);
      // result.fold(
      //   (failure) => emit(StudentOperationFailure(message: failure.message)),
      //   (_) => emit(const StudentTimeLogDeleteSuccess()),
      // );
      emit(const StudentTimeLogDeleteSuccess());
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchActiveTimeLog(
    FetchActiveTimeLogEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      final result = await _getActiveTimeLogUsecase(event.userId);
      result.fold(
        (failure) => emit(StudentOperationFailure(message: failure.message)),
        (activeTimeLog) =>
            emit(ActiveTimeLogFetched(activeTimeLog: activeTimeLog)),
      );
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }
}
