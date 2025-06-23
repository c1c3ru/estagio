import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/enums/user_role.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<AppFailure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
  });

  Future<Either<AppFailure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<AppFailure, void>> logout();

  Future<Either<AppFailure, UserEntity?>> getCurrentUser();

  Future<Either<AppFailure, void>> resetPassword({
    required String email,
  });

  Future<Either<AppFailure, UserEntity>> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profilePictureUrl,
  });

  Future<bool> isLoggedIn();
}
