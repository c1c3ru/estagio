// lib/domain/usecases/supervisor/delete_student_by_supervisor_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_supervisor_repository.dart';

class DeleteStudentBySupervisorUsecase {
  final ISupervisorRepository _repository;

  DeleteStudentBySupervisorUsecase(this._repository);

  Future<Either<AppFailure, void>> call(String studentId) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    return await _repository.deleteStudent(studentId);
  }
}
