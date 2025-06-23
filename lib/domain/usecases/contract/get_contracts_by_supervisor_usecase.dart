import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import '../../repositories/i_contract_repository.dart';
import '../../entities/contract_entity.dart';

class GetContractsBySupervisorUsecase {
  final IContractRepository _contractRepository;

  GetContractsBySupervisorUsecase(this._contractRepository);

  Future<Either<AppFailure, List<ContractEntity>>> call(
      String supervisorId) async {
    return await _contractRepository.getContractsBySupervisor(supervisorId);
  }
}
