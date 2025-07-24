import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/enums/contract_status.dart';

import '../../domain/repositories/i_contract_repository.dart';
import '../../domain/entities/contract_entity.dart';
import '../../core/errors/app_exceptions.dart';
import '../datasources/supabase/contract_datasource.dart';
import '../models/contract_model.dart';

class ContractRepository implements IContractRepository {
  final ContractDatasource _contractDatasource;

  ContractRepository(this._contractDatasource);

  @override
  Future<Either<AppFailure, List<ContractEntity>>> getAllContracts({
    String? studentId,
    ContractStatus? status,
  }) async {
    try {
      final contractsData = await _contractDatasource.getAllContracts(
        studentId: studentId,
        status: status,
      );
      final contracts = contractsData
          .map((data) => ContractModel.fromJson(data).toEntity())
          .toList();
      return Right(contracts);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar contratos: $e'));
    }
  }

  @override
  Future<Either<AppFailure, ContractEntity>> getContractById(String id) async {
    try {
      final contractData = await _contractDatasource.getContractById(id);
      if (contractData == null) {
        return const Left(ServerFailure(message: 'Contrato não encontrado'));
      }
      return Right(ContractModel.fromJson(contractData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar contrato: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<ContractEntity>>> getContractsByStudent(
      String studentId) async {
    try {
      final contractsData =
          await _contractDatasource.getContractsByStudent(studentId);
      final contracts = contractsData
          .map((data) => ContractModel.fromJson(data).toEntity())
          .toList();
      return Right(contracts);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Erro ao buscar contratos do estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<ContractEntity>>> getContractsBySupervisor(
      String supervisorId) async {
    try {
      final contractsData =
          await _contractDatasource.getContractsBySupervisor(supervisorId);
      final contracts = contractsData
          .map((data) => ContractModel.fromJson(data).toEntity())
          .toList();
      return Right(contracts);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Erro ao buscar contratos do supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<ContractEntity>>> getActiveContracts() async {
    try {
      final contractsData = await _contractDatasource.getActiveContracts();
      final contracts = contractsData
          .map((data) => ContractModel.fromJson(data).toEntity())
          .toList();
      return Right(contracts);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar contratos ativos: $e'));
    }
  }

  @override
  Future<Either<AppFailure, ContractEntity>> createContract(
      ContractEntity contract) async {
    try {
      final contractModel = ContractModel.fromEntity(contract);
      final createdData =
          await _contractDatasource.createContract(contractModel.toJson());
      return Right(ContractModel.fromJson(createdData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao criar contrato: $e'));
    }
  }

  @override
  Future<Either<AppFailure, ContractEntity>> updateContract(
      ContractEntity contract) async {
    try {
      final contractModel = ContractModel.fromEntity(contract);
      final updatedData = await _contractDatasource.updateContract(
        contract.id,
        contractModel.toJson(),
      );
      return Right(ContractModel.fromJson(updatedData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao atualizar contrato: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteContract(String id) async {
    try {
      await _contractDatasource.deleteContract(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao excluir contrato: $e'));
    }
  }

  @override
  Future<Either<AppFailure, ContractEntity?>> getActiveContractByStudent(
      String studentId) async {
    try {
      final contractData =
          await _contractDatasource.getActiveContractByStudent(studentId);
      if (contractData == null) {
        return const Right(null);
      }
      return Right(ContractModel.fromJson(contractData).toEntity());
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro ao buscar contrato ativo do estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<ContractEntity>>> getExpiringContracts(int daysAhead) async {
    try {
      final contractsData =
          await _contractDatasource.getExpiringContracts(daysAhead);
      final contracts = contractsData
          .map((data) => ContractModel.fromJson(data).toEntity())
          .toList();
      return Right(contracts);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar contratos próximos do vencimento: $e'));
    }
  }

  @override
  Future<Either<AppFailure, Map<String, dynamic>>>
      getContractStatistics() async {
    try {
      final contractsData = await _contractDatasource.getAllContracts();
      final contracts = contractsData
          .map((data) => ContractModel.fromJson(data).toEntity())
          .toList();

      final totalContracts = contracts.length;
      final activeContracts =
          contracts.where((c) => c.status == 'active').length;
      final pendingContracts =
          contracts.where((c) => c.status == 'pending_approval').length;
      final completedContracts =
          contracts.where((c) => c.status == 'completed').length;
      final terminatedContracts =
          contracts.where((c) => c.status == 'terminated').length;

      final averageContractDuration = contracts.isEmpty
          ? 0.0
          : contracts
                  .map((c) => c.endDate.difference(c.startDate).inDays)
                  .reduce((a, b) => a + b) /
              totalContracts;

      return Right({
        'totalContracts': totalContracts,
        'activeContracts': activeContracts,
        'pendingContracts': pendingContracts,
        'completedContracts': completedContracts,
        'terminatedContracts': terminatedContracts,
        'averageContractDuration': averageContractDuration,
      });
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao calcular estatísticas: $e'));
    }
  }
}
