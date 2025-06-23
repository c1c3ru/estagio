// lib/domain/usecases/contract/get_all_contracts_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/enums/contract_status.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/i_contract_repository.dart';

class GetAllContractsParams extends Equatable {
  final String? studentId;
  final ContractStatus? status;

  const GetAllContractsParams({
    this.studentId,
    this.status,
  });

  @override
  List<Object?> get props => [studentId, status];
}

class GetAllContractsUsecase {
  final IContractRepository _repository;

  GetAllContractsUsecase(this._repository);

  Future<Either<AppFailure, List<ContractEntity>>> call(
      GetAllContractsParams params) async {
    try {
      return await _repository.getAllContracts(
        studentId: params.studentId,
        status: params.status,
      );
    } on AppException catch (e) {
      return Left(AppFailure(message: e.message));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}
