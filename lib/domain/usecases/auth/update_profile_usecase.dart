// lib/domain/usecases/auth/update_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class UpdateProfileUsecase {
  final IAuthRepository _repository;

  UpdateProfileUsecase(this._repository);

  Future<Either<AppFailure, UserEntity>> call({
    required String userId,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    if (fullName != null && fullName.isEmpty) {
      return const Left(
          ValidationFailure('O nome completo não pode estar vazio.'));
    }

    if (email != null && !_isValidEmail(email)) {
      return const Left(ValidationFailure('Formato de email inválido.'));
    }

    return await _repository.updateProfile(
      userId: userId,
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
