import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

import '../../repositories/i_contract_repository.dart';
import '../../entities/contract_entity.dart';

class GetContractsByStudentUsecase {
  final IContractRepository _contractRepository;

  GetContractsByStudentUsecase(this._contractRepository);

  Future<Either<AppFailure, List<ContractEntity>>> call(
      String studentId) async {
    return await _contractRepository.getContractsByStudent(studentId);
  }
}
