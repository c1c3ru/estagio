// lib/domain/usecases/supervisor/get_supervisor_details_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/supervisor_entity.dart';
import '../../repositories/i_supervisor_repository.dart';

class GetSupervisorDetailsUsecase {
  final ISupervisorRepository _repository;

  GetSupervisorDetailsUsecase(this._repository);

  Future<Either<AppFailure, SupervisorEntity>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do utilizador não pode estar vazio.'));
    }
    return await _repository.getSupervisorDetails(userId);
  }
}
