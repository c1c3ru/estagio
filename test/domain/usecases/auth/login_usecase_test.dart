import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/domain/entities/user_entity.dart';
import 'package:gestao_de_estagio/domain/repositories/i_auth_repository.dart';
import 'package:gestao_de_estagio/domain/usecases/auth/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  late LoginUsecase usecase;
  late MockIAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockIAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  final tUser = UserEntity(
    id: '1',
    email: 'test@test.com',
    fullName: 'Test User',
    role: UserRole.student,
    createdAt: DateTime.now(),
  );

  group('LoginUsecase', () {
    test('deve retornar usuário quando login for bem-sucedido', () async {
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(tUser));

      final result = await usecase(email: 'test@test.com', password: 'password');

      expect(result, Right(tUser));
      verify(mockRepository.login(email: 'test@test.com', password: 'password'));
    });

    test('deve retornar falha quando credenciais forem inválidas', () async {
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(AuthFailure('Credenciais inválidas')));

      final result = await usecase(email: 'test@test.com', password: 'wrong');

      expect(result, const Left(AuthFailure('Credenciais inválidas')));
    });
  });
}