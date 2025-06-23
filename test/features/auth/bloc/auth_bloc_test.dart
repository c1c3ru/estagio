import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart'
    as exceptions;
import 'package:gestao_de_estagio/domain/entities/user_entity.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/get_auth_state_changes_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/login_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/logout_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/register_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/reset_password_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/update_profile_usecase.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_event.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  GetCurrentUserUsecase,
  LoginUsecase,
  LogoutUsecase,
  RegisterUsecase,
  ResetPasswordUsecase,
  UpdateProfileUsecase,
  GetAuthStateChangesUsecase,
])
void main() {
  late AuthBloc authBloc;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockGetAuthStateChangesUsecase mockGetAuthStateChangesUsecase;

  setUp(() {
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockGetAuthStateChangesUsecase = MockGetAuthStateChangesUsecase();

    authBloc = AuthBloc(
      getCurrentUserUsecase: mockGetCurrentUserUsecase,
      loginUsecase: mockLoginUsecase,
      logoutUsecase: mockLogoutUsecase,
      registerUsecase: mockRegisterUsecase,
      resetPasswordUsecase: mockResetPasswordUsecase,
      updateProfileUsecase: mockUpdateProfileUsecase,
      getAuthStateChangesUsecase: mockGetAuthStateChangesUsecase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    final testUser = UserEntity(
      id: '1',
      email: 'test@example.com',
      fullName: 'Test User',
      role: UserRole.student,
      createdAt: DateTime.now(),
    );

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockLoginUsecase(
          email: 'test@example.com',
          password: 'password',
        )).thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthRegistrationSuccess] when register is successful',
      build: () {
        when(mockRegisterUsecase(
          email: 'test@example.com',
          password: 'password',
          fullName: 'Test User',
          role: UserRole.student,
          registration: '123456789012',
        )).thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        email: 'test@example.com',
        password: 'password',
        fullName: 'Test User',
        role: 'student',
        registration: '123456789012',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthRegistrationSuccess(
          message:
              'Conta criada com sucesso! Verifique seu email para confirmar o cadastro.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUsecase(
          email: 'test@example.com',
          password: 'wrongpassword',
        )).thenAnswer((_) async =>
            const Left(exceptions.AuthFailure('Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'wrongpassword',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );
  });
}
