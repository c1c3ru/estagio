import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/student/get_student_dashboard_usecase.dart';
import '../../../domain/entities/contract_entity.dart';
import '../../../domain/entities/time_log_entity.dart';

import '../../../data/models/student_model.dart';

// Importar eventos e estados dos arquivos separados
import 'student_event.dart';
import 'student_state.dart';

// BLoC
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentDashboardUsecase _getStudentDashboardUsecase;

  StudentBloc({
    required GetStudentDashboardUsecase getStudentDashboardUsecase,
  })  : _getStudentDashboardUsecase = getStudentDashboardUsecase,
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
          // Criar StudentEntity a partir dos dados do dashboard usando StudentModel
          final studentData = dashboardData['student'] as Map<String, dynamic>;
          final student = StudentModel.fromJson(studentData).toEntity();

          const timeStats = StudentTimeStats();
          final contracts = <ContractEntity>[];

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
      // Implementar lógica de check-in
      emit(const StudentLoading());
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
      // Implementar lógica de check-out
      emit(const StudentLoading());
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadStudentTimeLogs(
    LoadStudentTimeLogsEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      // Aqui você deve chamar o usecase real para buscar os logs do estudante
      // Exemplo fictício:
      // final result = await _getStudentTimeLogsUsecase(event.userId);
      // result.fold(
      //   (failure) => emit(StudentOperationFailure(message: failure.message)),
      //   (logs) => emit(StudentTimeLogsLoadSuccess(timeLogs: logs)),
      // );
      emit(const StudentTimeLogsLoadSuccess(timeLogs: [])); // Remover depois
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onCreateManualTimeLog(
    CreateManualTimeLogEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      // Chame o usecase real para criar o log
      // final result = await _createTimeLogUsecase(...);
      // result.fold(
      //   (failure) => emit(StudentOperationFailure(message: failure.message)),
      //   (log) => emit(StudentTimeLogOperationSuccess(timeLog: log, message: 'Registo criado com sucesso!')),
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
            message: 'Registo criado com sucesso!'),
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
    emit(const StudentLoading());
    try {
      // Implementar lógica para buscar log ativo
      emit(const StudentLoading());
    } catch (e) {
      emit(StudentOperationFailure(message: e.toString()));
    }
  }
}
