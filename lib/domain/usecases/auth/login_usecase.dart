import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class LoginUsecase {
  final IAuthRepository _repository;

  const LoginUsecase(this._repository);

  Future<Either<AppFailure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure('E-mail é obrigatório'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Senha é obrigatória'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('E-mail inválido'));
    }

    return _repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
