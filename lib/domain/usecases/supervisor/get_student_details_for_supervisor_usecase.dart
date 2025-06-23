// lib/domain/usecases/supervisor/get_student_details_for_supervisor_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import 'package:gestao_de_estagio/domain/entities/contract_entity.dart';
import 'package:gestao_de_estagio/domain/entities/student_entity.dart';
import 'package:gestao_de_estagio/domain/entities/time_log_entity.dart';
import 'package:gestao_de_estagio/domain/repositories/i_supervisor_repository.dart';

class GetStudentDetailsForSupervisorUsecase {
  final ISupervisorRepository _repository;

  GetStudentDetailsForSupervisorUsecase(this._repository);

  Future<
      Either<AppFailure,
          (StudentEntity, List<TimeLogEntity>, List<ContractEntity>)>> call(
      String studentId) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    return _repository.getStudentDetails(studentId);
  }
}
