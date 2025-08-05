import 'package:dartz/dartz.dart';

import '../../core/enums/class_shift.dart';
import '../../core/enums/internship_shift.dart';
import '../../core/enums/user_role.dart';
import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_datasource.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../datasources/local/preferences_manager.dart';
import '../models/user_model.dart';

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;
  final PreferencesManager _preferencesManager;

  AuthRepository(this._authDatasource, this._preferencesManager);

  @override
  Stream<UserEntity?> authStateChanges() => _authDatasource
      .getAuthStateChanges()
      .map((userData) => userData != null ? UserModel.fromJson(userData).toEntity() : null)
      .distinct((previous, next) {
        // Evitar emissões duplicadas
        if (previous == null && next == null) return true;
        if (previous == null || next == null) return false;
        return previous.id == next.id && previous.email == next.email;
      });

  @override
  Future<Either<AppFailure, UserEntity>> getCurrentUser() async {
    try {
      final userData = await _authDatasource.getCurrentUser();
      if (userData != null) {
        final user = UserModel.fromJson(userData).toEntity();
        await _preferencesManager.saveUserData(userData);
        return Right(user);
      }

      final cachedUserData = _preferencesManager.getUserData();
      if (cachedUserData != null) {
        return Right(UserModel.fromJson(cachedUserData).toEntity());
      }

      return const Left(AuthFailure('Usuário não encontrado'));
    } catch (e) {
      final cachedUserData = _preferencesManager.getUserData();
      if (cachedUserData != null) {
        return Right(UserModel.fromJson(cachedUserData).toEntity());
      }
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userData =
          await _authDatasource.signInWithEmailAndPassword(email, password);

      if (userData == null) {
        return const Left(
            AuthFailure('Credenciais inválidas ou usuário não encontrado.'));
      }

      final user = UserModel.fromJson(userData);
      await _preferencesManager.saveUserData(userData);
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthFailure('Erro no login: $e'));
    }
  }

  @override
  Future<Either<AppFailure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? registration,
    bool? isMandatoryInternship,
    String? supervisorId,
    String? course,
    String? advisorName,
    String? department,
    ClassShift? classShift,
    InternshipShift? internshipShift,
    DateTime? birthDate,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
  }) async {
    try {
      final userData = await _authDatasource.signUpWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        registration: registration,
        isMandatoryInternship: isMandatoryInternship,
        supervisorId: supervisorId,
        course: course,
        advisorName: advisorName,
        department: department,
        classShift: classShift?.name,
        internshipShift: internshipShift?.name,
        birthDate: birthDate?.toIso8601String(),
        contractStartDate: contractStartDate?.toIso8601String(),
        contractEndDate: contractEndDate?.toIso8601String(),
      );
      return Right(UserModel.fromJson(userData).toEntity());
    } catch (e) {
      return Left(AuthFailure('Erro no registro: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> logout() async {
    try {
      await _authDatasource.signOut();
      await _preferencesManager.removeUserData();
      await _preferencesManager.removeUserToken();
      return const Right(null);
    } catch (e) {
      await _preferencesManager.removeUserData();
      await _preferencesManager.removeUserToken();
      return Left(AuthFailure('Erro no logout: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await _authDatasource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, UserEntity>> updateProfile({
    required UpdateProfileParams params,
  }) async {
    try {
      final currentUserData = await _authDatasource.getCurrentUser();
      final userId = currentUserData?['id'] as String?;
      if (userId == null) {
        return const Left(AuthFailure('Usuário não autenticado.'));
      }

      final userData = await _authDatasource.updateProfile(
        userId: userId,
        fullName: params.fullName,
        email: params.email,
        password: params.password,
        phoneNumber: params.phoneNumber,
        profilePictureUrl: params.profilePictureUrl,
      );
      return Right(UserModel.fromJson(userData).toEntity());
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final userData = await _authDatasource.getCurrentUser();
      return userData != null;
    } catch (e) {
      final cachedUserData = _preferencesManager.getUserData();
      return cachedUserData != null;
    }
  }
}
