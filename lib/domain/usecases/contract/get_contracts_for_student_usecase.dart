// lib/domain/usecases/contract/get_contracts_for_student_usecase.dart
import 'package:dartz/dartz.dart' show Left;

import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_contract_repository.dart';

class GetContractsForStudentUsecase {
  final IContractRepository _repository;

  GetContractsForStudentUsecase(this._repository);

  Future<Object?> call(String studentId) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    return await _repository.getActiveContractByStudent(studentId);
  }
}
