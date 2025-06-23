import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import '../../repositories/i_supervisor_repository.dart';
import '../../entities/supervisor_entity.dart';

class GetSupervisorByIdUsecase {
  final ISupervisorRepository _supervisorRepository;

  GetSupervisorByIdUsecase(this._supervisorRepository);

  Future<Either<AppFailure, SupervisorEntity>> call(String id) async {
    if (id.isEmpty) {
      return const Left(
          ValidationFailure('ID do supervisor não pode estar vazio'));
    }
    return await _supervisorRepository.getSupervisorById(id);
  }
}
