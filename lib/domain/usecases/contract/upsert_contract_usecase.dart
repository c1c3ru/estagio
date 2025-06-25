import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/i_contract_repository.dart';

class UpsertContractParams extends Equatable {
  final String? id;
  final String studentId;
  final String? supervisorId;
  final String contractType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const UpsertContractParams({
    this.id,
    required this.studentId,
    required this.supervisorId,
    required this.contractType,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        supervisorId,
        contractType,
        startDate,
        endDate,
        status,
      ];

  UpsertContractParams copyWith({
    String? id,
    String? studentId,
    String? supervisorId,
    String? contractType,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return UpsertContractParams(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      contractType: contractType ?? this.contractType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }
}

class UpsertContractUsecase {
  final IContractRepository _repository;

  UpsertContractUsecase(this._repository);

  Future<Either<AppFailure, ContractEntity>> call(
      UpsertContractParams params) async {
    try {
      final contract = ContractEntity(
        id: params.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: params.studentId,
        supervisorId: params.supervisorId,
        contractType: params.contractType,
        startDate: params.startDate,
        endDate: params.endDate,
        status: params.status,
        createdAt: DateTime.now(),
      );

      if (params.id != null) {
        return await _repository.updateContract(contract);
      } else {
        return await _repository.createContract(contract);
      }
    } on AppException catch (e) {
      return Left(AppFailure(message: e.message));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}
