// lib/domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/notification_helper.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_supervisor_repository.dart';
import '../../repositories/i_student_repository.dart';

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
  final NotificationHelper _notificationHelper;

  ApproveOrRejectTimeLogUsecase(
    this._supervisorRepository,
    this._studentRepository,
    this._notificationHelper,
  );

  Future<Either<AppFailure, TimeLogEntity>> call(
      ApproveOrRejectTimeLogParams params) async {
    try {
      // Primeiro, obter informações do registro de horas antes da aprovação/rejeição
      final timeLogResult = await _supervisorRepository.getTimeLogById(params.timeLogId);
      if (timeLogResult.isLeft()) {
        return timeLogResult;
      }
      
      final originalTimeLog = timeLogResult.getOrElse(() => throw Exception('TimeLog not found'));
      
      // Executar aprovação/rejeição
      final result = await _supervisorRepository.approveOrRejectTimeLog(
        timeLogId: params.timeLogId,
        approved: params.approved,
        supervisorId: params.supervisorId,
        rejectionReason: params.rejectionReason,
      );

      // Se a operação foi bem-sucedida, enviar notificação
      if (result.isRight()) {
        final updatedTimeLog = result.getOrElse(() => throw Exception('Updated TimeLog not found'));
        
        // Obter informações do estudante para personalizar a notificação
        final studentResult = await _studentRepository.getStudentById(originalTimeLog.studentId);
        final studentName = studentResult.fold(
          (failure) => 'Estudante',
          (student) => student.name,
        );

        // Enviar notificação baseada no resultado
        if (params.approved) {
          await _notificationHelper.notifyTimeLogApproved(
            studentId: originalTimeLog.studentId,
            studentName: studentName,
            timeLogId: params.timeLogId,
            date: originalTimeLog.date,
            hours: updatedTimeLog.totalHours,
          );
        } else {
          await _notificationHelper.notifyTimeLogRejected(
            studentId: originalTimeLog.studentId,
            studentName: studentName,
            timeLogId: params.timeLogId,
            date: originalTimeLog.date,
            reason: params.rejectionReason ?? 'Não especificado',
          );
        }
      }

      return result;
    } on AppException catch (e) {
      return Left(AppFailure(message: e.message));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}
