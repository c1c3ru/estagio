import 'package:dartz/dartz.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../entities/supervisor_entity.dart';
import '../../repositories/i_supervisor_repository.dart';

class EnsureSupervisorProfileUsecase {
  final ISupervisorRepository _repository;
  EnsureSupervisorProfileUsecase(this._repository);

  Future<Either<AppFailure, SupervisorEntity>> call({
    required String userId,
    required String fullName,
  }) {
    return _repository.ensureSupervisorProfile(userId: userId, fullName: fullName);
  }
}
