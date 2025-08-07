import 'package:dartz/dartz.dart';
import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class UpdateStudentUsecase {
  final IStudentRepository _studentRepository;

  UpdateStudentUsecase(this._studentRepository);

  Future<Either<AppFailure, StudentEntity>> call(StudentEntity student) async {
    // Validações
    if (student.id.isEmpty) {
      return const Left(ValidationFailure('ID do estudante é obrigatório'));
    }

    if (student.registrationNumber.isEmpty) {
      return const Left(ValidationFailure('Matrícula é obrigatória'));
    }

    if (student.course.isEmpty) {
      return const Left(ValidationFailure('Curso é obrigatório'));
    }

    if (student.fullName.isEmpty) {
      return const Left(ValidationFailure('Nome completo é obrigatório'));
    }

    return await _studentRepository.updateStudent(student);
  }
}
