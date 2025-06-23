// lib/domain/usecases/supervisor/create_student_by_supervisor_usecase.dart
import 'package:dartz/dartz.dart';
import '../../entities/student_entity.dart';
import '../../repositories/i_supervisor_repository.dart';
import '../../../core/errors/app_exceptions.dart';

class CreateStudentBySupervisorUsecase {
  final ISupervisorRepository _repository;

  CreateStudentBySupervisorUsecase(this._repository);

  Future<Either<AppFailure, StudentEntity>> call(
      StudentEntity studentData) async {
    // Validações básicas nos dados do estudante podem ser feitas aqui.
    // Ex: studentData.fullName não pode estar vazio.
    if (studentData.fullName.trim().isEmpty) {
      return const Left(
          ValidationFailure('O nome completo do estudante é obrigatório.'));
    }
    if (studentData.registrationNumber.trim().isEmpty) {
      return const Left(ValidationFailure(
          'O número de matrícula do estudante é obrigatório.'));
    }
    // Adicione outras validações conforme necessário.
    return await _repository.createStudent(studentData);
  }
}
