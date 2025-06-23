// lib/domain/usecases/student/create_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart'; // Para TimeOfDay
import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_student_repository.dart';

class CreateTimeLogUsecase {
  final IStudentRepository _repository;

  CreateTimeLogUsecase(this._repository);

  Future<Either<AppFailure, TimeLogEntity>> call({
    required String studentId,
    required DateTime logDate,
    required TimeOfDay checkInTime,
    TimeOfDay? checkOutTime,
    String? description,
  }) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    // Validação para garantir que checkOutTime, se fornecido, é posterior a checkInTime no mesmo dia.
    if (checkOutTime != null) {
      final checkInDateTime = DateTime(logDate.year, logDate.month, logDate.day,
          checkInTime.hour, checkInTime.minute);
      final checkOutDateTime = DateTime(logDate.year, logDate.month,
          logDate.day, checkOutTime.hour, checkOutTime.minute);
      if (checkOutDateTime.isBefore(checkInDateTime)) {
        return const Left(ValidationFailure(
            'A hora de saída deve ser posterior à hora de entrada.'));
      }
    }

    return await _repository.createTimeLog(
      studentId: studentId,
      logDate: logDate,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      description: description,
    );
  }
}
