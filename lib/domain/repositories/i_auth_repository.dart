import 'package:dartz/dartz.dart';
import '../../core/errors/app_exceptions.dart';
import '../entities/user_entity.dart';
import '../usecases/auth/update_profile_usecase.dart';

abstract class IAuthRepository {
  Future<Either<AppFailure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<AppFailure, void>> logout();

  Future<Either<AppFailure, UserEntity>> register({
    required String email,
    required String password,
  });

  Future<Either<AppFailure, UserEntity?>> getCurrentUser();

  Stream<UserEntity?> authStateChanges();

  Future<Either<AppFailure, UserEntity>> updateProfile({
    required UpdateProfileParams params,
  });

  Future<Either<AppFailure, void>> resetPassword({
    required String email,
  });
}
