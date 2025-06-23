// lib/domain/usecases/student/delete_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_student_repository.dart';

class DeleteTimeLogUsecase {
  final IStudentRepository _repository;

  DeleteTimeLogUsecase(this._repository);

  Future<Either<AppFailure, void>> call(String timeLogId) async {
    if (timeLogId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do registo de tempo não pode estar vazio.'));
    }
    return await _repository.deleteTimeLog(timeLogId);
  }
}
