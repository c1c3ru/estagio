import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_auth_repository.dart';

class LogoutUsecase {
  final IAuthRepository _repository;

  const LogoutUsecase(this._repository);

  Future<Either<AppFailure, void>> call() async {
    return _repository.logout();
  }
}
