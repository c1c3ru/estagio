// lib/domain/usecases/student/update_student_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/student_entity.dart';
import '../../repositories/i_student_repository.dart';

class UpdateStudentProfileUsecase {
  final IStudentRepository _repository;

  UpdateStudentProfileUsecase(this._repository);

  Future<Either<AppFailure, StudentEntity>> call(StudentEntity student) async {
    if (student.id.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }

    if (student.fullName.isEmpty) {
      return const Left(
          ValidationFailure('O nome do estudante não pode estar vazio.'));
    }

    return await _repository.updateStudentProfile(student);
  }
}
