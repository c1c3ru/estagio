import 'package:dartz/dartz.dart';
import '../../repositories/i_auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class GetCurrentUserUsecase {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase(this._authRepository);

  Future<Either<AppFailure, UserEntity?>> call() async {
    return await _authRepository.getCurrentUser();
  }
}
