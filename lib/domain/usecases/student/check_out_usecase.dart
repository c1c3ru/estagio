// lib/domain/usecases/student/check_out_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_student_repository.dart';

class CheckOutUsecase {
  final IStudentRepository _repository;

  CheckOutUsecase(this._repository);

  Future<Either<AppFailure, TimeLogEntity>> call({
    required String studentId,
    required String activeTimeLogId,
    String? description,
  }) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    if (activeTimeLogId.isEmpty) {
      return const Left(ValidationFailure(
          'O ID do registo de tempo ativo não pode estar vazio.'));
    }
    return await _repository.checkOut(
      studentId: studentId,
      activeTimeLogId: activeTimeLogId,
      description: description,
    );
  }
}
