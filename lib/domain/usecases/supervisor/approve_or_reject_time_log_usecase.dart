// lib/domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/notifications/notification_helper.dart';
import '../../entities/time_log_entity.dart';
import '../../entities/student_entity.dart';
import '../../entities/supervisor_entity.dart';
import '../../repositories/i_supervisor_repository.dart';
import '../../repositories/i_student_repository.dart';
import '../../repositories/i_time_log_repository.dart';

class ApproveOrRejectTimeLogParams extends Equatable {
  final String timeLogId;
  final bool approved;
  final String supervisorId;
  final String? rejectionReason;

  const ApproveOrRejectTimeLogParams({
    required this.timeLogId,
    required this.approved,
    required this.supervisorId,
    this.rejectionReason,
  });

  @override
  List<Object?> get props =>
      [timeLogId, approved, supervisorId, rejectionReason];
}

class ApproveOrRejectTimeLogUsecase {
  final ISupervisorRepository _supervisorRepository;
  final IStudentRepository _studentRepository;
  final ITimeLogRepository _timeLogRepository;
  final NotificationHelper _notificationHelper;

  ApproveOrRejectTimeLogUsecase(
    this._supervisorRepository,
    this._studentRepository,
    this._timeLogRepository,
    this._notificationHelper,
  );

  Future<Either<AppFailure, TimeLogEntity>> call(
      ApproveOrRejectTimeLogParams params) async {
    try {
      // Primeiro, obter informações do registro de horas antes da aprovação/rejeição
      final timeLogResult = await _timeLogRepository.getTimeLogById(params.timeLogId);
      if (timeLogResult.isLeft()) {
        return timeLogResult;
      }
      
      final originalTimeLog = timeLogResult.getOrElse(() => throw Exception('TimeLog not found'));
      
      // Obter informações do estudante e supervisor
      final studentResult = await _studentRepository.getStudentById(originalTimeLog.studentId);
      final supervisorResult = await _supervisorRepository.getSupervisorById(params.supervisorId);
      
      if (studentResult.isLeft()) {
        return Left(studentResult.fold((l) => l, (r) => throw Exception()));
      }
      
      final student = studentResult.getOrElse(() => throw Exception('Student not found'));
      final supervisor = supervisorResult.fold(
        (failure) => null,
        (supervisor) => supervisor,
      );
      
      // Executar aprovação/rejeição
      final result = await _timeLogRepository.updateTimeLogStatus(
        timeLogId: params.timeLogId,
        approved: params.approved,
        rejectionReason: params.rejectionReason,
      );

      // Se a operação foi bem-sucedida, enviar notificação
      if (result.isRight()) {
        final updatedTimeLog = result.getOrElse(() => throw Exception('Updated TimeLog not found'));
        
        // Criar wrappers para as interfaces do NotificationHelper
        final timeLogWrapper = _TimeLogWrapper(updatedTimeLog);
        final studentWrapper = _StudentWrapper(student!);
        final supervisorWrapper = supervisor != null ? _SupervisorWrapper(supervisor) : null;
        
        // Enviar notificação baseada no resultado
        if (params.approved) {
          await _notificationHelper.notifyTimeLogStatusChange(
            timeLog: timeLogWrapper,
            approved: true,
            student: studentWrapper,
            supervisor: supervisorWrapper,
          );
        } else {
          if (params.rejectionReason != null) {
            await _notificationHelper.notifyTimeLogRejectedWithReason(
              timeLog: timeLogWrapper,
              student: studentWrapper,
              reason: params.rejectionReason!,
              supervisor: supervisorWrapper,
            );
          } else {
            await _notificationHelper.notifyTimeLogStatusChange(
              timeLog: timeLogWrapper,
              approved: false,
              student: studentWrapper,
              supervisor: supervisorWrapper,
            );
          }
        }
      }

      return result;
    } catch (e) {
      return Left(AppFailure.unexpected(e.toString()));
    }
  }
}

// Wrappers para implementar as interfaces do NotificationHelper
class _TimeLogWrapper implements TimeLogNotifiable {
  final TimeLogEntity _timeLog;

  _TimeLogWrapper(this._timeLog);

  @override
  String get id => _timeLog.id;

  @override
  DateTime get date => _timeLog.logDate;

  @override
  Duration get duration {
    if (_timeLog.checkOutTime != null) {
      try {
        final checkInDateTime = DateTime.parse(
            '${_timeLog.logDate.toIso8601String().split('T')[0]}T${_timeLog.checkInTime}');
        final checkOutDateTime = DateTime.parse(
            '${_timeLog.logDate.toIso8601String().split('T')[0]}T${_timeLog.checkOutTime!}');
        return checkOutDateTime.difference(checkInDateTime);
      } catch (e) {
        return Duration.zero;
      }
    }
    return Duration.zero;
  }

  @override
  String get studentId => _timeLog.studentId;
}

class _StudentWrapper implements StudentNotifiable {
  final StudentEntity _student;

  _StudentWrapper(this._student);

  @override
  String get id => _student.id;

  @override
  String get name => _student.name;
}

class _SupervisorWrapper implements SupervisorNotifiable {
  final SupervisorEntity _supervisor;

  _SupervisorWrapper(this._supervisor);

  @override
  String get id => _supervisor.id;

  @override
  String get name => _supervisor.name;
}
