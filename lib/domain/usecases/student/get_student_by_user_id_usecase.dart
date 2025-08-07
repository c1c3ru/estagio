import 'package:dartz/dartz.dart';
import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class GetStudentByUserIdUsecase {
  final IStudentRepository _studentRepository;

  GetStudentByUserIdUsecase(this._studentRepository);

  Future<Either<AppFailure, StudentEntity?>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('ID do usuário não pode estar vazio'));
    }
    return await _studentRepository.getStudentByUserId(userId);
  }
}

