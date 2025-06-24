// MUDANÇA AQUI: Importamos a INTERFACE do datasource, não a implementação.
import '../../domain/repositories/i_auth_datasource.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/entities/user_entity.dart';
// MUDANÇA AQUI: Removido o import da classe concreta 'AuthDatasource'.
import '../datasources/local/preferences_manager.dart';
import '../models/user_model.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/enums/user_role.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart'; // Import que estava faltando

class AuthRepository implements IAuthRepository {
  // MUDANÇA AQUI: A dependência agora é da interface.
  final IAuthDatasource _authDatasource;
  final PreferencesManager _preferencesManager;

  AuthRepository({
    // MUDANÇA AQUI: O construtor agora pede a interface.
    required IAuthDatasource authDatasource,
    required PreferencesManager preferencesManager,
  })  : _authDatasource = authDatasource,
        _preferencesManager = preferencesManager;

  // O resto do código permanece exatamente o mesmo, pois ele já usa
  // os métodos definidos na interface.

  @override
  Stream<UserEntity?> authStateChanges() =>
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
      if (userData == null) {
        return const Left(
            AuthFailure('Dados de usuário não retornados pelo login.'));
      }
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
  }) async {
    try {
      final userData = await _authDatasource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: '', // Valor padrão vazio
        role: UserRole.student, // Valor padrão student
        registration: null, // Valor padrão null
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
