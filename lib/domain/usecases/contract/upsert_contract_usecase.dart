import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/enums/contract_status.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/i_contract_repository.dart';

class UpsertContractParams extends Equatable {
  final String? id;
  final String studentId;
  final String supervisorId;
  final String company;
  final String position;
  final DateTime startDate;
  final DateTime endDate;
  final double totalHoursRequired;
  final double weeklyHoursTarget;
  final ContractStatus status;

  const UpsertContractParams({
    this.id,
    required this.studentId,
    required this.supervisorId,
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.totalHoursRequired,
    required this.weeklyHoursTarget,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        supervisorId,
        company,
        position,
        startDate,
        endDate,
        totalHoursRequired,
        weeklyHoursTarget,
        status,
      ];

  UpsertContractParams copyWith({
    String? id,
    String? studentId,
    String? supervisorId,
    String? company,
    String? position,
    DateTime? startDate,
    DateTime? endDate,
    double? totalHoursRequired,
    double? weeklyHoursTarget,
    ContractStatus? status,
  }) {
    return UpsertContractParams(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalHoursRequired: totalHoursRequired ?? this.totalHoursRequired,
      weeklyHoursTarget: weeklyHoursTarget ?? this.weeklyHoursTarget,
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
        company: params.company,
        position: params.position,
        startDate: params.startDate,
        endDate: params.endDate,
        totalHoursRequired: params.totalHoursRequired,
        weeklyHoursTarget: params.weeklyHoursTarget,
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
