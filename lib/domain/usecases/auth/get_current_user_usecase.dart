import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class GetCurrentUserUsecase {
  final IAuthRepository _repository;

  const GetCurrentUserUsecase(this._repository);

  Future<Either<AppFailure, UserEntity?>> call() async {
    return _repository.getCurrentUser();
  }
}
