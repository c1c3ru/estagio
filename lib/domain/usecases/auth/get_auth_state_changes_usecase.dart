// lib/domain/usecases/auth/get_auth_state_changes_usecase.dart
import '../../repositories/i_auth_repository.dart';
import '../../entities/user_entity.dart';

class GetAuthStateChangesUsecase {
  final IAuthRepository _repository;

  GetAuthStateChangesUsecase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.authStateChanges;
  }
}
