import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_contract_repository.dart';

class GetContractStatisticsUsecase {
  final IContractRepository _repository;

  GetContractStatisticsUsecase(this._repository);

  Future<Either<AppFailure, Map<String, dynamic>>> call() async {
    return await _repository.getContractStatistics();
  }
}
