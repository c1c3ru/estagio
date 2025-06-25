import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_contract_repository.dart';
import '../../entities/contract_entity.dart';

class CreateContractUsecase {
  final IContractRepository _contractRepository;

  CreateContractUsecase(this._contractRepository);

  Future<Either<AppFailure, ContractEntity>> call(
      ContractEntity contract) async {
    if (contract.studentId.isEmpty) {
      return const Left(ValidationFailure('ID do estudante é obrigatório'));
    }

    if (contract.supervisorId == null || contract.supervisorId!.isEmpty) {
      return const Left(ValidationFailure('ID do supervisor é obrigatório'));
    }

    if (contract.startDate.isAfter(contract.endDate)) {
      return const Left(ValidationFailure(
          'Data de início deve ser anterior à data de término'));
    }

    return await _contractRepository.createContract(contract);
  }
}
