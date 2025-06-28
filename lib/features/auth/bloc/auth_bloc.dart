import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/get_auth_state_changes_usecase.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/entities/supervisor_entity.dart';

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUseCase;
  final LogoutUsecase _logoutUseCase;
  final RegisterUsecase _registerUseCase;
  final GetCurrentUserUsecase _getCurrentUserUseCase;
  final GetAuthStateChangesUsecase _getAuthStateChangesUseCase;
  final UpdateProfileUsecase _updateProfileUseCase;
  final ResetPasswordUsecase _resetPasswordUseCase;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required LoginUsecase loginUseCase,
    required LogoutUsecase logoutUseCase,
    required RegisterUsecase registerUseCase,
    required GetCurrentUserUsecase getCurrentUserUseCase,
    required GetAuthStateChangesUsecase getAuthStateChangesUseCase,
    required UpdateProfileUsecase updateProfileUseCase,
    required ResetPasswordUsecase resetPasswordUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _registerUseCase = registerUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(AuthInitial()) {
    if (kDebugMode) {
      print('🟡 AuthBloc: Construtor chamado');
    }

    // Registrar handlers de eventos
    on<AuthInitializeRequested>(_onAuthInitializeRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);

    if (kDebugMode) {
      print('🟡 AuthBloc: Handlers registrados');
    }

    // Inicia a escuta das mudanças de estado de autenticação
    try {
      _authStateSubscription = _getAuthStateChangesUseCase().listen(
        (user) {
          if (kDebugMode) {
            print(
                '🟡 AuthBloc: AuthStateChanged recebido: ${user?.email ?? 'null'}');
          }
          add(AuthStateChanged(user));
        },
        onError: (error) {
          if (kDebugMode) {
            print('🔴 AuthBloc: Erro na escuta de auth state: $error');
          }
        },
      );
      if (kDebugMode) {
        print('🟡 AuthBloc: AuthStateSubscription iniciado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 AuthBloc: Erro ao iniciar AuthStateSubscription: $e');
      }
    }
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
          if (_isProfileIncomplete(user)) {
            emit(AuthProfileIncomplete(user));
          } else {
            emit(AuthSuccess(user));
          }
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
      if (_isProfileIncomplete(event.user!)) {
        emit(AuthProfileIncomplete(event.user!));
      } else {
        emit(AuthSuccess(event.user!));
      }
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
        emit(const AuthProfileUpdateSuccess('Perfil atualizado com sucesso!'));
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _resetPasswordUseCase(email: event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthPasswordResetEmailSent(
          message: 'E-mail de redefinição enviado!')),
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
          emit(user != null ? AuthSuccess(user) : AuthInitial());
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔴 AuthBloc: Erro em _onAuthInitializeRequested: $e');
      }
      emit(AuthInitial());
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthInitial()),
      (user) => emit(user != null ? AuthSuccess(user) : AuthInitial()),
    );
  }

  // Função auxiliar para checar perfil incompleto
  bool _isProfileIncomplete(UserEntity user) {
    if (user.role.name == 'student' && user is StudentEntity) {
      final student = user as StudentEntity;
      final course = student.course;
      final advisor = student.advisorName;
      if (student.fullName.isEmpty ||
          course.isEmpty ||
          course == 'PENDENTE' ||
          advisor.isEmpty ||
          advisor == 'PENDENTE') {
        return true;
      }
    }
    if (user.role.name == 'supervisor' && user is SupervisorEntity) {
      final supervisor = user as SupervisorEntity;
      final department = supervisor.department;
      final position = supervisor.position;
      if ((department?.isEmpty ?? true) ||
          department == 'PENDENTE' ||
          (position?.isEmpty ?? true) ||
          position == 'PENDENTE') {
        return true;
      }
    }
    return false;
  }
}
