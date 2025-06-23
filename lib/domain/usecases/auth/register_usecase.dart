import 'package:dartz/dartz.dart';
import '../../repositories/i_auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/enums/user_role.dart';

class RegisterUsecase {
  final IAuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<Either<AppFailure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
  }) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure('E-mail é obrigatório'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Senha é obrigatória'));
    }

    if (fullName.isEmpty) {
      return const Left(ValidationFailure('Nome completo é obrigatório'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('E-mail inválido'));
    }

    return await _repository.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      registration: registration,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
