import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

import '../../repositories/i_contract_repository.dart';
import '../../entities/contract_entity.dart';

class GetActiveContractByStudentUsecase {
  final IContractRepository _contractRepository;

  GetActiveContractByStudentUsecase(this._contractRepository);

  Future<Either<AppFailure, ContractEntity?>> call(String studentId) async {
    return await _contractRepository.getActiveContractByStudent(studentId);
  }
}
