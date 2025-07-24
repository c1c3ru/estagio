import 'package:dartz/dartz.dart';
import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class GetStudentByIdUsecase {
  final IStudentRepository _studentRepository;

  GetStudentByIdUsecase(this._studentRepository);

  Future<Either<AppFailure, StudentEntity?>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('ID do estudante não pode estar vazio'));
    }
    return await _studentRepository.getStudentById(id);
  }
}

