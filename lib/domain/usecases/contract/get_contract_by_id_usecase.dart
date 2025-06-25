// lib/domain/usecases/contract/get_contract_by_id_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_contract_repository.dart';

class GetContractByIdUsecase {
  final IContractRepository _repository;

  GetContractByIdUsecase(this._repository);

  Future<Object?> call(String contractId) async {
    if (contractId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do contrato não pode estar vazio.'));
    }
    return await _repository.getContractById(contractId);
  }
}
