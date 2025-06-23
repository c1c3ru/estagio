import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_supervisor_repository.dart';
import '../../entities/supervisor_entity.dart';

class UpdateSupervisorUsecase {
  final ISupervisorRepository _supervisorRepository;

  UpdateSupervisorUsecase(this._supervisorRepository);

  Future<Either<AppFailure, SupervisorEntity>> call(
      SupervisorEntity supervisor) async {
    // Validações
    if (supervisor.id.isEmpty) {
      return const Left(ValidationFailure('ID do supervisor é obrigatório'));
    }

    if (supervisor.department.isEmpty) {
      return const Left(ValidationFailure('Departamento é obrigatório'));
    }

    if (supervisor.specialization.isEmpty) {
      return const Left(ValidationFailure('Especialização é obrigatória'));
    }

    return await _supervisorRepository.updateSupervisor(supervisor);
  }
}
