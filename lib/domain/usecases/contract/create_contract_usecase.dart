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

    if (contract.supervisorId.isEmpty) {
      return const Left(ValidationFailure('ID do supervisor é obrigatório'));
    }

    if (contract.company.isEmpty) {
      return const Left(ValidationFailure('Nome da empresa é obrigatório'));
    }

    if (contract.position.isEmpty) {
      return const Left(ValidationFailure('Cargo é obrigatório'));
    }

    if (contract.weeklyHoursTarget <= 0) {
      return const Left(
          ValidationFailure('Carga horária semanal deve ser maior que zero'));
    }

    if (contract.totalHoursRequired <= 0) {
      return const Left(
          ValidationFailure('Carga horária total deve ser maior que zero'));
    }

    if (contract.startDate.isAfter(contract.endDate)) {
      return const Left(ValidationFailure(
          'Data de início deve ser anterior à data de término'));
    }

    return await _contractRepository.createContract(contract);
  }
}
