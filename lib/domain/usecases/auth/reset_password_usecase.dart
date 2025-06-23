// lib/domain/usecases/auth/reset_password_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_auth_repository.dart';
import '../../../core/errors/app_exceptions.dart';

class ResetPasswordUsecase {
  final IAuthRepository _repository;

  ResetPasswordUsecase(this._repository);

  Future<Either<AppFailure, void>> call({required String email}) async {
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Formato de email inválido.'));
    }
    return await _repository.resetPassword(email: email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
