import 'package:dartz/dartz.dart';
import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class GetStudentsBySupervisorUsecase {
  final IStudentRepository _studentRepository;

  GetStudentsBySupervisorUsecase(this._studentRepository);

  Future<Either<AppFailure, List<StudentEntity>>> call(String supervisorId) async {
    if (supervisorId.isEmpty) {
      return const Left(ValidationFailure('ID do supervisor não pode estar vazio'));
    }
    
    return await _studentRepository.getStudentsBySupervisor(supervisorId);
  }
}

