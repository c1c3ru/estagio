import 'package:dartz/dartz.dart';
import '../../repositories/i_auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/enums/user_role.dart';

class RegisterUsecase {
  final IAuthRepository _repository;

  const RegisterUsecase(this._repository);

  Future<Either<AppFailure, UserEntity>> call({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? registration,
    bool? isMandatoryInternship,
    String? supervisorId,
  }) async {
    if (fullName.isEmpty) {
      return const Left(ValidationFailure('Nome completo é obrigatório'));
    }
    if (email.isEmpty) {
      return const Left(ValidationFailure('E-mail é obrigatório'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Senha é obrigatória'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('E-mail inválido'));
    }

    if (!_isValidPassword(password)) {
      return const Left(ValidationFailure(
          'A senha deve ter no mínimo 8 caracteres, uma letra maiúscula, uma minúscula e um número'));
    }

    if (role == UserRole.student &&
        (registration == null || registration.isEmpty)) {
      return const Left(
          ValidationFailure('Matrícula é obrigatória para estudantes'));
    }

    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      registration: registration,
      isMandatoryInternship: isMandatoryInternship,
      supervisorId: supervisorId,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$')
        .hasMatch(password);
  }
}
