import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/time_log_entity.dart';
import '../../../domain/usecases/time_log/clock_in_usecase.dart';
import '../../../domain/usecases/time_log/clock_out_usecase.dart';
import '../../../domain/usecases/time_log/get_time_logs_by_student_usecase.dart';
import '../../../domain/usecases/time_log/get_active_time_log_usecase.dart';
import '../../../domain/usecases/time_log/get_total_hours_by_student_usecase.dart';

// Events
abstract class TimeLogEvent extends Equatable {
  const TimeLogEvent();

  @override
  List<Object?> get props => [];
}

class TimeLogLoadByStudentRequested extends TimeLogEvent {
  final String studentId;

  const TimeLogLoadByStudentRequested({required this.studentId});

  @override
  List<Object> get props => [studentId];
}

class TimeLogClockInRequested extends TimeLogEvent {
  final String studentId;
  final String? notes;

  const TimeLogClockInRequested({
    required this.studentId,
    this.notes,
  });

  @override
  List<Object?> get props => [studentId, notes];
}

class TimeLogClockOutRequested extends TimeLogEvent {
  final String studentId;
  final String? notes;

  const TimeLogClockOutRequested({
    required this.studentId,
    this.notes,
  });

  @override
  List<Object?> get props => [studentId, notes];
}

class TimeLogGetActiveRequested extends TimeLogEvent {
  final String studentId;

  const TimeLogGetActiveRequested({required this.studentId});

  @override
  List<Object> get props => [studentId];
}

class TimeLogGetTotalHoursRequested extends TimeLogEvent {
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;

  const TimeLogGetTotalHoursRequested({
    required this.studentId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [studentId, startDate, endDate];
}

// States
abstract class TimeLogState extends Equatable {
  const TimeLogState();

  @override
  List<Object?> get props => [];
}

class TimeLogInitial extends TimeLogState {}

// Loading States
class TimeLogLoading extends TimeLogState {}

class TimeLogSelecting extends TimeLogState {}

class TimeLogInserting extends TimeLogState {}

class TimeLogUpdating extends TimeLogState {}

class TimeLogDeleting extends TimeLogState {}

class TimeLogClockingIn extends TimeLogState {}

class TimeLogClockingOut extends TimeLogState {}

// Success States
class TimeLogLoadByStudentSuccess extends TimeLogState {
  final List<TimeLogEntity> timeLogs;

  const TimeLogLoadByStudentSuccess({required this.timeLogs});

  @override
  List<Object> get props => [timeLogs];
}

class TimeLogClockInSuccess extends TimeLogState {
  final TimeLogEntity timeLog;

  const TimeLogClockInSuccess({required this.timeLog});

  @override
  List<Object> get props => [timeLog];
}

class TimeLogClockOutSuccess extends TimeLogState {
  final TimeLogEntity timeLog;

  const TimeLogClockOutSuccess({required this.timeLog});

  @override
  List<Object> get props => [timeLog];
}

class TimeLogGetActiveSuccess extends TimeLogState {
  final TimeLogEntity? activeTimeLog;

  const TimeLogGetActiveSuccess({required this.activeTimeLog});

  @override
  List<Object?> get props => [activeTimeLog];
}

class TimeLogGetTotalHoursSuccess extends TimeLogState {
  final Map<String, dynamic> totalHours;

  const TimeLogGetTotalHoursSuccess({required this.totalHours});

  @override
  List<Object> get props => [totalHours];
}

// Error States
class TimeLogSelectError extends TimeLogState {
  final String message;

  const TimeLogSelectError({required this.message});

  @override
  List<Object> get props => [message];
}

class TimeLogInsertError extends TimeLogState {
  final String message;

  const TimeLogInsertError({required this.message});

  @override
  List<Object> get props => [message];
}

class TimeLogUpdateError extends TimeLogState {
  final String message;

  const TimeLogUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

class TimeLogDeleteError extends TimeLogState {
  final String message;

  const TimeLogDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}

class TimeLogClockInError extends TimeLogState {
  final String message;

  const TimeLogClockInError({required this.message});

  @override
  List<Object> get props => [message];
}

class TimeLogClockOutError extends TimeLogState {
  final String message;

  const TimeLogClockOutError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class TimeLogBloc extends Bloc<TimeLogEvent, TimeLogState> {
  final ClockInUsecase _clockInUsecase;
  final ClockOutUsecase _clockOutUsecase;
  final GetTimeLogsByStudentUsecase _getTimeLogsByStudentUsecase;
  final GetActiveTimeLogUsecase _getActiveTimeLogUsecase;
  final GetTotalHoursByStudentUsecase _getTotalHoursByStudentUsecase;

  TimeLogBloc({
    required ClockInUsecase clockInUsecase,
    required ClockOutUsecase clockOutUsecase,
    required GetTimeLogsByStudentUsecase getTimeLogsByStudentUsecase,
    required GetActiveTimeLogUsecase getActiveTimeLogUsecase,
    required GetTotalHoursByStudentUsecase getTotalHoursByStudentUsecase,
  })  : _clockInUsecase = clockInUsecase,
        _clockOutUsecase = clockOutUsecase,
        _getTimeLogsByStudentUsecase = getTimeLogsByStudentUsecase,
        _getActiveTimeLogUsecase = getActiveTimeLogUsecase,
        _getTotalHoursByStudentUsecase = getTotalHoursByStudentUsecase,
        super(TimeLogInitial()) {
    on<TimeLogLoadByStudentRequested>(_onTimeLogLoadByStudentRequested);
    on<TimeLogClockInRequested>(_onTimeLogClockInRequested);
    on<TimeLogClockOutRequested>(_onTimeLogClockOutRequested);
    on<TimeLogGetActiveRequested>(_onTimeLogGetActiveRequested);
    on<TimeLogGetTotalHoursRequested>(_onTimeLogGetTotalHoursRequested);
  }

  Future<void> _onTimeLogLoadByStudentRequested(
    TimeLogLoadByStudentRequested event,
    Emitter<TimeLogState> emit,
  ) async {
    emit(TimeLogSelecting());
    try {
      final timeLogs = await _getTimeLogsByStudentUsecase(event.studentId);
      emit(TimeLogLoadByStudentSuccess(timeLogs: timeLogs));
    } catch (e) {
      emit(TimeLogSelectError(message: e.toString()));
    }
  }

  Future<void> _onTimeLogClockInRequested(
    TimeLogClockInRequested event,
    Emitter<TimeLogState> emit,
  ) async {
    emit(TimeLogClockingIn());
    try {
      final timeLog =
          await _clockInUsecase(event.studentId, notes: event.notes);
      emit(TimeLogClockInSuccess(timeLog: timeLog));
      add(TimeLogLoadByStudentRequested(studentId: event.studentId));
    } catch (e) {
      emit(TimeLogClockInError(message: e.toString()));
    }
  }

  Future<void> _onTimeLogClockOutRequested(
    TimeLogClockOutRequested event,
    Emitter<TimeLogState> emit,
  ) async {
    emit(TimeLogClockingOut());
    try {
      final timeLog =
          await _clockOutUsecase(event.studentId, notes: event.notes);
      emit(TimeLogClockOutSuccess(timeLog: timeLog));
      add(TimeLogLoadByStudentRequested(studentId: event.studentId));
    } catch (e) {
      emit(TimeLogClockOutError(message: e.toString()));
    }
  }

  Future<void> _onTimeLogGetActiveRequested(
    TimeLogGetActiveRequested event,
    Emitter<TimeLogState> emit,
  ) async {
    emit(TimeLogSelecting());
    try {
      final activeTimeLog = await _getActiveTimeLogUsecase(event.studentId);
      emit(TimeLogGetActiveSuccess(activeTimeLog: activeTimeLog));
    } catch (e) {
      emit(TimeLogSelectError(message: e.toString()));
    }
  }

  Future<void> _onTimeLogGetTotalHoursRequested(
    TimeLogGetTotalHoursRequested event,
    Emitter<TimeLogState> emit,
  ) async {
    emit(TimeLogSelecting());
    try {
      final totalHours = await _getTotalHoursByStudentUsecase(
        event.studentId,
        event.startDate,
        event.endDate,
      );
      emit(TimeLogGetTotalHoursSuccess(totalHours: totalHours));
    } catch (e) {
      emit(TimeLogSelectError(message: e.toString()));
    }
  }
}
