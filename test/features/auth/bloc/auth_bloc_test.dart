import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginUsecase,
  LogoutUsecase,
  RegisterUsecase,
  GetCurrentUserUsecase,
  GetAuthStateChangesUsecase,
  UpdateProfileUsecase,
  ResetPasswordUsecase,
])
void main() {
  late AuthBloc authBloc;
  late MockLoginUsecase mockLoginUseCase;
  late MockLogoutUsecase mockLogoutUseCase;
  late MockRegisterUsecase mockRegisterUseCase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUseCase;
  late MockGetAuthStateChangesUsecase mockGetAuthStateChangesUseCase;
  late MockUpdateProfileUsecase mockUpdateProfileUseCase;
  late MockResetPasswordUsecase mockResetPasswordUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUsecase();
    mockLogoutUseCase = MockLogoutUsecase();
    mockRegisterUseCase = MockRegisterUsecase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUsecase();
    mockGetAuthStateChangesUseCase = MockGetAuthStateChangesUsecase();
    mockUpdateProfileUseCase = MockUpdateProfileUsecase();
    mockResetPasswordUseCase = MockResetPasswordUsecase();

    when(mockGetAuthStateChangesUseCase.call())
        .thenAnswer((_) => const Stream.empty());

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      registerUseCase: mockRegisterUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      getAuthStateChangesUseCase: mockGetAuthStateChangesUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    final mockUser = UserEntity.empty;

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when LoginRequested is added and login succeeds',
      build: () {
        when(mockLoginUseCase.call(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => Right(mockUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
          const LoginRequested(email: 'test@test.com', password: 'password')),
      expect: () => <AuthState>[
        AuthLoading(),
        AuthSuccess(mockUser),
      ],
    );
  });
}
