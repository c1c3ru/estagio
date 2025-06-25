import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_time_log_repository.dart';

class ClockOutUsecase {
  final ITimeLogRepository _repository;

  ClockOutUsecase(this._repository);

  Future<Either<AppFailure, Unit>> call({
    required String studentId,
    String? notes,
  }) async {
    try {
      final activeTimeLog = await _repository.getActiveTimeLog(studentId);

      if (activeTimeLog == null) {
        return const Left(
          ValidationFailure('Não há registro de ponto ativo para encerrar.'),
        );
      }

      // --- VALIDAÇÃO ---
      final now = DateTime.now();
      final isSameDay = now.year == activeTimeLog.logDate.year &&
          now.month == activeTimeLog.logDate.month &&
          now.day == activeTimeLog.logDate.day;

      if (!isSameDay) {
        return const Left(ValidationFailure(
            'A saída deve ser registrada no mesmo dia da entrada.'));
      }

      final TimeOfDay checkInTime = _parseTime(activeTimeLog.checkInTime);
      final TimeOfDay checkOutTime = TimeOfDay.fromDateTime(now);
      final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
      final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;

      if (checkOutMinutes < checkInMinutes) {
        return const Left(ValidationFailure(
            'A hora de saída não pode ser anterior à hora de entrada.'));
      }
      // --- FIM DA VALIDAÇÃO ---

      final updatedTimeLog = activeTimeLog.copyWith(
        checkOutTime:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        description: notes ?? activeTimeLog.description,
      );

      await _repository.updateTimeLog(updatedTimeLog);

      return const Right(unit);
    } on AppFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
          AppFailure(message: 'Erro ao registrar saída: ${e.toString()}'));
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
