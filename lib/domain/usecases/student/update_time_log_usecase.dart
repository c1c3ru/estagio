// lib/domain/usecases/student/update_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_student_repository.dart';
import 'package:flutter/material.dart';

class UpdateTimeLogUsecase {
  final IStudentRepository _repository;

  UpdateTimeLogUsecase(this._repository);

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<Either<AppFailure, TimeLogEntity>> call(TimeLogEntity timeLog) async {
    // Validações no objeto timeLog podem ser feitas aqui.
    // Por exemplo, verificar se o ID não está vazio.
    if (timeLog.id.isEmpty) {
      return const Left(
          ValidationFailure('O ID do registo de tempo não pode estar vazio.'));
    }
    if (timeLog.checkOutTime != null) {
      final checkIn = _parseTime(timeLog.checkInTime);
      final checkOut = _parseTime(timeLog.checkOutTime!);
      final checkInDateTime = DateTime(
          timeLog.logDate.year,
          timeLog.logDate.month,
          timeLog.logDate.day,
          checkIn.hour,
          checkIn.minute);
      final checkOutDateTime = DateTime(
          timeLog.logDate.year,
          timeLog.logDate.month,
          timeLog.logDate.day,
          checkOut.hour,
          checkOut.minute);
      if (checkOutDateTime.isBefore(checkInDateTime)) {
        return const Left(ValidationFailure(
            'A hora de saída deve ser posterior à hora de entrada.'));
      }
    }
    return await _repository.updateTimeLog(timeLog);
  }
}
