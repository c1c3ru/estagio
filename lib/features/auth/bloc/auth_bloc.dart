import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/get_auth_state_changes_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/entities/user_entity.dart';

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUseCase;
  final LogoutUsecase _logoutUseCase;
  final RegisterUsecase _registerUseCase;
  final GetCurrentUserUsecase _getCurrentUserUseCase;
  final GetAuthStateChangesUsecase _getAuthStateChangesUseCase;
  final UpdateProfileUsecase _updateProfileUseCase;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required LoginUsecase loginUseCase,
    required LogoutUsecase logoutUseCase,
    required RegisterUsecase registerUseCase,
    required GetCurrentUserUsecase getCurrentUserUseCase,
    required GetAuthStateChangesUsecase getAuthStateChangesUseCase,
    required UpdateProfileUsecase updateProfileUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _registerUseCase = registerUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(AuthInitial()) {
    // Registrar handlers de eventos
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthInitializeRequested>((event, emit) async {
      // emit(AuthLoading());
      // final user = await getCurrentUserUseCase();
      // if (user != null) emit(AuthAuthenticated(user));
      // else emit(AuthUnauthenticated());
    });

    // Inicia a escuta das mudanças de estado de autenticação
    _authStateSubscription = _getAuthStateChangesUseCase().listen(
      (user) => add(AuthStateChanged(user)),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        emit(AuthRegistrationSuccess('Cadastro realizado com sucesso!'));
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthInitial());
        }
      },
    );
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthSuccess(event.user!));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _updateProfileUseCase(params: event.params);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        emit(AuthProfileUpdateSuccess('Perfil atualizado com sucesso!'));
        emit(AuthSuccess(user));
      },
    );
  }
}
