// lib/domain/usecases/student/check_in_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_student_repository.dart';

class CheckInUsecase {
  final IStudentRepository _repository;

  CheckInUsecase(this._repository);

  Future<Either<AppFailure, TimeLogEntity>> call({
    required String studentId,
    String? notes,
  }) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    return await _repository.checkIn(
      studentId: studentId,
      notes: notes,
    );
  }
}
