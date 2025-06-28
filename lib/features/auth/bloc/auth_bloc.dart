import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/get_auth_state_changes_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

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
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AuthInitializeRequested>(_onAuthInitializeRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Iniciar a escuta de mudanças de estado de autenticação
    _authStateSubscription = _getAuthStateChangesUseCase.call().listen(
      (user) {
        if (kDebugMode) {
          print('🟡 AuthBloc: AuthStateChanged recebido: ${user?.email}');
        }

        if (user != null) {
          // Verificar se o perfil está completo
          if (_isProfileComplete(user)) {
            if (kDebugMode) {
              print(
                  '🟡 AuthBloc: AuthStateChanged - Perfil completo, emitindo AuthSuccess');
            }
            add(AuthStateChanged(user));
          } else {
            if (kDebugMode) {
              print(
                  '🟡 AuthBloc: AuthStateChanged - Perfil incompleto, emitindo AuthProfileIncomplete');
            }
            add(AuthStateChanged(user));
          }
        } else {
          if (kDebugMode) {
            print(
                '🟡 AuthBloc: AuthStateChanged - Usuário nulo, emitindo AuthUnauthenticated');
          }
          add(const AuthStateChanged(null));
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('🔴 AuthBloc: Erro na escuta de auth state: $error');
        }
        // Log do erro apenas, sem emitir estado
      },
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
      (failure) {
        if (failure.message.toLowerCase().contains('não confirmado') ||
            failure.message.toLowerCase().contains('email não confirmado')) {
          emit(AuthEmailConfirmationRequired(
            email: event.email,
            message:
                'E-mail não confirmado. Verifique sua caixa de entrada (inclusive o spam) e confirme o cadastro antes de fazer login.',
          ));
        } else {
          emit(AuthFailure(failure.message));
        }
      },
      (user) {
        if (_isProfileIncomplete(user)) {
          emit(AuthProfileIncomplete(user));
        } else {
          emit(AuthSuccess(user));
        }
      },
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
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
      role: event.role,
      registration: event.registration,
      isMandatoryInternship: event.isMandatoryInternship,
      supervisorId: event.supervisorId,
      course: event.course,
      advisorName: event.advisorName,
      classShift: event.classShift,
      internshipShift: event.internshipShift,
      birthDate: event.birthDate,
      contractStartDate: event.contractStartDate,
      contractEndDate: event.contractEndDate,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        if (_isProfileIncomplete(user)) {
          emit(AuthProfileIncomplete(user));
        } else {
          emit(AuthSuccess(user));
        }
      },
    );
  }

  Future<void> _onAuthInitializeRequested(
    AuthInitializeRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (kDebugMode) {
      print('🟡 AuthBloc: _onAuthInitializeRequested iniciado');
    }

    try {
      final result = await _getCurrentUserUseCase();
      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
                '🟡 AuthBloc: Falha ao obter usuário atual: ${failure.message}');
          }
          emit(AuthInitial());
        },
        (user) {
          if (kDebugMode) {
            print(
                '🟡 AuthBloc: Usuário atual obtido: ${user?.email ?? 'null'}');
          }
          if (user != null) {
            if (_isProfileIncomplete(user)) {
              if (kDebugMode) {
                print(
                    '🟡 AuthBloc: Perfil incompleto detectado, mas permitindo acesso');
              }
              emit(AuthSuccess(user, isProfileIncomplete: true));
            } else {
              if (kDebugMode) {
                print('🟡 AuthBloc: Perfil completo, emitindo AuthSuccess');
              }
              emit(AuthSuccess(user));
            }
          } else {
            emit(AuthInitial());
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔴 AuthBloc: Erro em _onAuthInitializeRequested: $e');
      }
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
        emit(const AuthProfileUpdateSuccess('Perfil atualizado com sucesso!'));
        emit(AuthSuccess(user));
      },
    );
  }

  // Função auxiliar para checar perfil incompleto
  bool _isProfileIncomplete(UserEntity user) {
    // Verificar se o usuário tem dados básicos preenchidos
    if (user.fullName.isEmpty || user.fullName == 'Estudante') {
      return true;
    }

    // Para estudantes, verificar se tem dados específicos
    if (user.role.name == 'student') {
      // Se o usuário não tem dados completos na tabela students, considerar incompleto
      // Isso será verificado quando o usuário acessar a página de perfil
      return false; // Por enquanto, permitir acesso e verificar na página de perfil
    }

    // Para supervisores, verificar se tem dados específicos
    if (user.role.name == 'supervisor') {
      // Se não temos dados completos do supervisor, considerar incompleto
      return false; // Por enquanto, permitir acesso e verificar na página de perfil
    }

    return false;
  }

  bool _isProfileComplete(UserEntity user) {
    // Implemente a lógica para verificar se o perfil é completo
    // Esta é uma implementação básica e pode ser expandida conforme necessário
    return !_isProfileIncomplete(user);
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      if (_isProfileComplete(event.user!)) {
        emit(AuthSuccess(event.user!));
      } else {
        emit(AuthProfileIncomplete(event.user!));
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
