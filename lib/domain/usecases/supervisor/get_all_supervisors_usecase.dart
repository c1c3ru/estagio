import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

import '../../repositories/i_supervisor_repository.dart';
import '../../entities/supervisor_entity.dart';

class GetAllSupervisorsUsecase {
  final ISupervisorRepository _supervisorRepository;

  GetAllSupervisorsUsecase(this._supervisorRepository);

  Future<Either<AppFailure, List<SupervisorEntity>>> call() async {
    return await _supervisorRepository.getAllSupervisors();
  }
}
