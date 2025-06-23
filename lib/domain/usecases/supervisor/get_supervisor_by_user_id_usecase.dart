import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

import '../../repositories/i_supervisor_repository.dart';
import '../../entities/supervisor_entity.dart';

class GetSupervisorByUserIdUsecase {
  final ISupervisorRepository _supervisorRepository;

  GetSupervisorByUserIdUsecase(this._supervisorRepository);

  Future<Either<AppFailure, SupervisorEntity?>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(
          ValidationFailure('ID do usuário não pode estar vazio'));
    }
    return await _supervisorRepository.getSupervisorByUserId(userId);
  }
}
