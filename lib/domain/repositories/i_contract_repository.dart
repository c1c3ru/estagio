import 'package:dartz/dartz.dart';
import '../entities/contract_entity.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/enums/contract_status.dart';

abstract class IContractRepository {
  Future<Either<AppFailure, List<ContractEntity>>> getAllContracts({
    String? studentId,
    ContractStatus? status,
  });

  Future<Either<AppFailure, ContractEntity>> getContractById(String id);

  Future<Either<AppFailure, ContractEntity>> createContract(
      ContractEntity contract);

  Future<Either<AppFailure, ContractEntity>> updateContract(
      ContractEntity contract);

  Future<Either<AppFailure, void>> deleteContract(String id);

  Future<Either<AppFailure, List<ContractEntity>>> getContractsByStudent(
      String studentId);

  Future<Either<AppFailure, List<ContractEntity>>> getContractsBySupervisor(
      String supervisorId);

  Future<Either<AppFailure, ContractEntity?>> getActiveContractByStudent(
      String studentId);

  Future<Either<AppFailure, Map<String, dynamic>>> getContractStatistics();
}
