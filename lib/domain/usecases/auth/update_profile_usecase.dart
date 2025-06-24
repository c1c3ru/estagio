// lib/domain/usecases/auth/update_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class UpdateProfileParams {
  final String? fullName;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? profilePictureUrl;

  const UpdateProfileParams({
    this.fullName,
    this.email,
    this.password,
    this.phoneNumber,
    this.profilePictureUrl,
  });
}

class UpdateProfileUsecase {
  final IAuthRepository _repository;

  const UpdateProfileUsecase(this._repository);

  Future<Either<AppFailure, UserEntity>> call({
    required UpdateProfileParams params,
  }) async {
    if (params.email != null && !_isValidEmail(params.email!)) {
      return const Left(ValidationFailure('E-mail inválido'));
    }

    if (params.password != null && !_isValidPassword(params.password!)) {
      return const Left(ValidationFailure(
          'A senha deve ter no mínimo 8 caracteres, uma letra maiúscula, uma minúscula e um número'));
    }

    return _repository.updateProfile(params: params);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$')
        .hasMatch(password);
  }
}
