import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/validation/validation_service.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/get_auth_state_changes_usecase.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class EnhancedAuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUseCase;
  final LogoutUsecase _logoutUseCase;
  final RegisterUsecase _registerUseCase;
  final GetCurrentUserUsecase _getCurrentUserUseCase;
  final GetAuthStateChangesUsecase _getAuthStateChangesUseCase;
  final UpdateProfileUsecase _updateProfileUseCase;
  final ResetPasswordUsecase _resetPasswordUseCase;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  EnhancedAuthBloc({
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
    
    AppLogger.bloc('EnhancedAuthBloc initialized');
    
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AuthInitializeRequested>(_onAuthInitializeRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);

    _initializeAuthStateListener();
  }

  void _initializeAuthStateListener() {
    _authStateSubscription = _getAuthStateChangesUseCase.call().listen(
      (user) {
        AppLogger.auth('Auth state changed: ${user?.email ?? 'null'}');
        add(AuthStateChanged(user));
      },
      onError: (error, stackTrace) {
        AppLogger.error('Auth state listener error', 
          tag: 'Auth', error: error, stackTrace: stackTrace);
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    AppLogger.bloc('EnhancedAuthBloc closed');
    return super.close();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Login requested for: ${event.email}');
    
    // Validar dados de entrada
    final validation = ValidationService.validateLoginForm(
      email: event.email,
      password: event.password,
    );
    
    if (validation.isLeft()) {
      validation.fold(
        (failure) {
          AppLogger.warning('Login validation failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (_) {},
      );
      return;
    }

    emit(AuthLoading());
    
    try {
      final result = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      
      result.fold(
        (failure) {
          AppLogger.warning('Login failed: ${failure.message}');
          
          if (failure.message.toLowerCase().contains('não confirmado') ||
              failure.message.toLowerCase().contains('email não confirmado')) {
            emit(AuthEmailConfirmationRequired(
              email: event.email,
              message: 'E-mail não confirmado. Verifique sua caixa de entrada.',
            ));
          } else {
            emit(AuthFailure(failure.message));
          }
        },
        (user) {
          AppLogger.auth('Login successful for: ${user.email}');
          
          if (_isProfileIncomplete(user)) {
            emit(AuthProfileIncomplete(user));
          } else {
            emit(AuthSuccess(user));
          }
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected login error', 
        tag: 'Auth', error: error, stackTrace: stackTrace);
      emit(const AuthFailure('Erro inesperado durante o login'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Logout requested');
    emit(AuthLoading());
    
    try {
      final result = await _logoutUseCase();
      result.fold(
        (failure) {
          AppLogger.warning('Logout failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (_) {
          AppLogger.auth('Logout successful');
          emit(const AuthUnauthenticated());
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected logout error', 
        tag: 'Auth', error: error, stackTrace: stackTrace);
      emit(const AuthFailure('Erro inesperado durante o logout'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Registration requested for: ${event.email}');
    
    // Validar dados básicos
    final validation = ValidationService.validateStudentRegistration(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
      registration: event.registration ?? '',
    );
    
    if (validation.isLeft()) {
      validation.fold(
        (failure) {
          AppLogger.warning('Registration validation failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (_) {},
      );
      return;
    }

    emit(AuthLoading());
    
    try {
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
        (failure) {
          AppLogger.warning('Registration failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          AppLogger.auth('Registration successful for: ${user.email}');
          
          if (_isProfileIncomplete(user)) {
            emit(AuthProfileIncomplete(user));
          } else {
            emit(AuthSuccess(user));
          }
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected registration error', 
        tag: 'Auth', error: error, stackTrace: stackTrace);
      emit(const AuthFailure('Erro inesperado durante o registro'));
    }
  }

  Future<void> _onAuthInitializeRequested(
    AuthInitializeRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Auth initialization requested');
    
    try {
      final result = await _getCurrentUserUseCase();
      result.fold(
        (failure) {
          AppLogger.info('No current user found: ${failure.message}');
          emit(AuthInitial());
        },
        (user) {
          if (user != null) {
            AppLogger.auth('Current user found: ${user.email}');
            
            if (_isProfileIncomplete(user)) {
              emit(AuthProfileIncomplete(user));
            } else {
              emit(AuthSuccess(user));
            }
          } else {
            AppLogger.info('No current user');
            emit(AuthInitial());
          }
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Auth initialization error', 
        tag: 'Auth', error: error, stackTrace: stackTrace);
      emit(AuthInitial());
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Profile update requested');
    emit(AuthLoading());
    
    try {
      final result = await _updateProfileUseCase(params: event.params);
      result.fold(
        (failure) {
          AppLogger.warning('Profile update failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          AppLogger.auth('Profile updated successfully');
          emit(const AuthProfileUpdateSuccess('Perfil atualizado com sucesso!'));
          emit(AuthSuccess(user));
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected profile update error', 
        tag: 'Auth', error: error, stackTrace: stackTrace);
      emit(const AuthFailure('Erro inesperado ao atualizar perfil'));
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Password reset requested for: ${event.email}');
    
    // Validar email
    final emailValidation = ValidationService.validateEmail(event.email);
    if (emailValidation.isLeft()) {
      emailValidation.fold(
        (failure) {
          AppLogger.warning('Password reset email validation failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (_) {},
      );
      return;
    }

    emit(AuthLoading());
    
    try {
      final result = await _resetPasswordUseCase(email: event.email);
      result.fold(
        (failure) {
          AppLogger.warning('Password reset failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (_) {
          AppLogger.auth('Password reset email sent successfully');
          emit(const AuthPasswordResetEmailSent(
            message: 'Email de redefinição de senha enviado com sucesso!'));
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected password reset error', 
        tag: 'Auth', error: error, stackTrace: stackTrace);
      emit(const AuthFailure('Erro inesperado ao redefinir senha'));
    }
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

  bool _isProfileIncomplete(UserEntity user) {
    if (user.fullName.isEmpty ||
        user.fullName == 'Estudante' ||
        user.fullName == 'Student' ||
        user.fullName == 'Usuário' ||
        user.fullName == 'User') {
      return true;
    }
    return false;
  }

  bool _isProfileComplete(UserEntity user) {
    return !_isProfileIncomplete(user);
  }
}