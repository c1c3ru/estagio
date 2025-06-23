import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart' as errors;
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/domain/entities/user_entity.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/login_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/logout_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/register_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/update_profile_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/get_auth_state_changes_usecase.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_event.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  GetCurrentUserUsecase,
  LoginUsecase,
  LogoutUsecase,
  RegisterUsecase,
  UpdateProfileUsecase,
  GetAuthStateChangesUsecase,
])
void main() {
  late AuthBloc authBloc;
  late MockGetCurrentUserUsecase mockGetCurrentUserUseCase;
  late MockLoginUsecase mockLoginUseCase;
  late MockLogoutUsecase mockLogoutUseCase;
  late MockRegisterUsecase mockRegisterUseCase;
  late MockUpdateProfileUsecase mockUpdateProfileUseCase;
  late MockGetAuthStateChangesUsecase mockGetAuthStateChangesUseCase;
  late UserEntity mockUser;

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUsecase();
    mockLoginUseCase = MockLoginUsecase();
    mockLogoutUseCase = MockLogoutUsecase();
    mockRegisterUseCase = MockRegisterUsecase();
    mockUpdateProfileUseCase = MockUpdateProfileUsecase();
    mockGetAuthStateChangesUseCase = MockGetAuthStateChangesUsecase();
    mockUser = UserEntity(
      id: '1',
      email: 'test@test.com',
      fullName: 'Test User',
      role: UserRole.student,
      createdAt: DateTime(2023, 1, 1),
    );

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      registerUseCase: mockRegisterUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      getAuthStateChangesUseCase: mockGetAuthStateChangesUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
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
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(() => mockLoginUseCase(
                  email: anyNamed('email'),
                  password: anyNamed('password'),
                ))
            .thenAnswer((_) =>
                Future.value(Right<errors.AppFailure, UserEntity>(testUser)));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        email: 'test@test.com',
        password: 'password',
      )),
      expect: () => [
        AuthLoading(),
        AuthSuccess(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when register succeeds',
      build: () {
        when(() => mockRegisterUseCase(
                  email: anyNamed('email'),
                  password: anyNamed('password'),
                ))
            .thenAnswer((_) =>
                Future.value(Right<errors.AppFailure, UserEntity>(testUser)));
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(
        email: 'test@test.com',
        password: 'password',
      )),
      expect: () => [
        AuthLoading(),
        const AuthRegistrationSuccess('Cadastro realizado com sucesso!'),
        AuthSuccess(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(() => mockLoginUseCase(
                  email: anyNamed('email'),
                  password: anyNamed('password'),
                ))
            .thenAnswer((_) => Future.value(Left<errors.AppFailure, UserEntity>(
                const errors.AuthFailure('Invalid credentials'))));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        email: 'test@test.com',
        password: 'password',
      )),
      expect: () => [
        AuthLoading(),
        const AuthFailure('Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthInitial] when logout succeeds',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer(
            (_) => Future.value(const Right<errors.AppFailure, void>(null)));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthInitial(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when logout fails',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer((_) => Future.value(
            Left<errors.AppFailure, void>(
                const errors.AuthFailure('Logout failed'))));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        const AuthFailure('Logout failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when getCurrentUser succeeds',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer((_) =>
            Future.value(Right<errors.AppFailure, UserEntity?>(testUser)));
        return authBloc;
      },
      act: (bloc) => bloc.add(GetCurrentUserRequested()),
      expect: () => [
        AuthLoading(),
        AuthSuccess(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthInitial] when getCurrentUser returns null',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer((_) =>
            Future.value(const Right<errors.AppFailure, UserEntity?>(null)));
        return authBloc;
      },
      act: (bloc) => bloc.add(GetCurrentUserRequested()),
      expect: () => [
        AuthLoading(),
        AuthInitial(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when getCurrentUser fails',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer((_) => Future.value(
            Left<errors.AppFailure, UserEntity?>(
                const errors.AuthFailure('Failed to get user'))));
        return authBloc;
      },
      act: (bloc) => bloc.add(GetCurrentUserRequested()),
      expect: () => [
        AuthLoading(),
        const AuthFailure('Failed to get user'),
      ],
    );

    test('emits AuthSuccess when authStateChanges emits a user', () {
      when(() => mockGetAuthStateChangesUseCase())
          .thenAnswer((_) => Stream<UserEntity?>.value(testUser));

      expectLater(
        authBloc.stream,
        emitsInOrder([AuthSuccess(testUser)]),
      );
    });

    test('emits AuthInitial when authStateChanges emits null', () {
      when(() => mockGetAuthStateChangesUseCase())
          .thenAnswer((_) => Stream<UserEntity?>.value(null));

      expectLater(
        authBloc.stream,
        emitsInOrder([AuthInitial()]),
      );
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthProfileUpdateSuccess, AuthSuccess] when updateProfile succeeds',
      build: () {
        final params = UpdateProfileParams(
          fullName: 'Updated Name',
          email: 'updated@test.com',
        );
        when(() => mockUpdateProfileUseCase(params: anyNamed('params')))
            .thenAnswer((_) =>
                Future.value(Right<errors.AppFailure, UserEntity>(testUser)));
        return authBloc;
      },
      act: (bloc) => bloc.add(UpdateProfileRequested(
        params: UpdateProfileParams(
          fullName: 'Updated Name',
          email: 'updated@test.com',
        ),
      )),
      expect: () => [
        AuthLoading(),
        const AuthProfileUpdateSuccess('Perfil atualizado com sucesso!'),
        AuthSuccess(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when updateProfile fails',
      build: () {
        when(() => mockUpdateProfileUseCase(params: anyNamed('params')))
            .thenAnswer((_) => Future.value(Left<errors.AppFailure, UserEntity>(
                const errors.AuthFailure('Failed to update profile'))));
        return authBloc;
      },
      act: (bloc) => bloc.add(UpdateProfileRequested(
        params: UpdateProfileParams(
          fullName: 'Updated Name',
          email: 'updated@test.com',
        ),
      )),
      expect: () => [
        AuthLoading(),
        const AuthFailure('Failed to update profile'),
      ],
    );
  });
}
