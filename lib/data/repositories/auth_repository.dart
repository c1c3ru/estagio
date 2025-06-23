import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/supabase/auth_datasource.dart';
import '../datasources/local/preferences_manager.dart';
import '../models/user_model.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/enums/user_role.dart';

class AuthRepository implements IAuthRepository {
  final AuthDatasource _authDatasource;
  final PreferencesManager _preferencesManager;

  AuthRepository({
    required AuthDatasource authDatasource,
    required PreferencesManager preferencesManager,
  })  : _authDatasource = authDatasource,
        _preferencesManager = preferencesManager;

  @override
  Stream<UserEntity?> get authStateChanges =>
      _authDatasource.getAuthStateChanges().map((userData) =>
          userData != null ? UserModel.fromJson(userData).toEntity() : null);

  @override
  Future<Either<AppFailure, UserEntity>> getCurrentUser() async {
    try {
      final userData = await _authDatasource.getCurrentUser();
      if (userData != null) {
        final userModel = UserModel.fromJson(userData);
        await _preferencesManager.saveUserData(userModel.toJson());
        return Right(userModel.toEntity());
      }

      final cachedUserData = _preferencesManager.getUserData();
      if (cachedUserData != null) {
        final userModel = UserModel.fromJson(cachedUserData);
        return Right(userModel.toEntity());
      }

      return const Left(AuthFailure('Usuário não encontrado'));
    } catch (e) {
      final cachedUserData = _preferencesManager.getUserData();
      if (cachedUserData != null) {
        final userModel = UserModel.fromJson(cachedUserData);
        return Right(userModel.toEntity());
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
      final userModel = UserModel.fromJson(userData);
      await _preferencesManager.saveUserData(userModel.toJson());
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Erro no login: $e'));
    }
  }

  @override
  Future<Either<AppFailure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
  }) async {
    try {
      final userData = await _authDatasource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        registration: registration,
      );
      final userModel = UserModel.fromJson(userData);
      await _preferencesManager.saveUserData(userModel.toJson());
      return Right(userModel.toEntity());
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
    required String userId,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    try {
      final userData = await _authDatasource.updateProfile(
        userId: userId,
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
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
