// lib/domain/usecases/auth/get_auth_state_changes_usecase.dart
import '../../../domain/entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class GetAuthStateChangesUsecase {
  final IAuthRepository _repository;

  const GetAuthStateChangesUsecase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.authStateChanges();
  }
}
