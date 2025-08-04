// lib/domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import 'package:gestao_de_estagio/core/services/notification_helper.dart';
import '../../entities/time_log_entity.dart';
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

  ApproveOrRejectTimeLogUsecase(
    this._supervisorRepository,
    this._studentRepository,
    this._timeLogRepository,
  );

  Future<Either<AppFailure, TimeLogEntity>> call(
      ApproveOrRejectTimeLogParams params) async {
    try {
      // Primeiro, obter informações do registro de horas antes da aprovação/rejeição
      final timeLogResult =
          await _timeLogRepository.getTimeLogById(params.timeLogId);
      if (timeLogResult.isLeft()) {
        return timeLogResult;
      }

      final originalTimeLog =
          timeLogResult.getOrElse(() => throw Exception('TimeLog not found'));

      // Obter informações do estudante e supervisor
      final studentResult =
          await _studentRepository.getStudentById(originalTimeLog.studentId);
      final supervisorResult =
          await _supervisorRepository.getSupervisorById(params.supervisorId);

      if (studentResult.isLeft()) {
        return Left(studentResult.fold((l) => l, (r) => throw Exception()));
      }

      final student =
          studentResult.getOrElse(() => throw Exception('Student not found'));
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
        final updatedTimeLog = result
            .getOrElse(() => throw Exception('Updated TimeLog not found'));

        // Enviar notificação baseada no resultado
        if (params.approved) {
          await NotificationHelper.notifyTimeLogApproval(
            timeLog: updatedTimeLog,
            student: student!,
            supervisor: supervisor!,
          );
        } else {
          await NotificationHelper.notifyTimeLogRejection(
            timeLog: updatedTimeLog,
            student: student!,
            supervisor: supervisor!,
            rejectionReason: params.rejectionReason,
          );
        }
      }

      return result;
    } catch (e) {
      return Left(AppFailure.unexpected(e.toString()));
    }
  }
}

// Wrappers para implementar as interfaces do NotificationHelper
// Removendo wrappers desnecessários - usando NotificationHelper.notifyTimeLogApproval/Rejection diretamente
