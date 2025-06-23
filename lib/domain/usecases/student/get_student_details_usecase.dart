// lib/domain/usecases/student/get_student_details_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/student_entity.dart';
import '../../repositories/i_student_repository.dart';

class GetStudentDetailsUsecase {
  final IStudentRepository _repository;

  GetStudentDetailsUsecase(this._repository);

  Future<Either<AppFailure, StudentEntity>> call(String userId) async {
    // Validação básica do ID do usuário pode ser adicionada aqui, se necessário.
    if (userId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do utilizador não pode estar vazio.'));
    }
    return await _repository.getStudentDetails(userId);
  }
}
