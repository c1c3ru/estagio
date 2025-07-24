import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/core/validation/validation_service.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

void main() {
  group('ValidationService', () {
    group('validateEmail', () {
      test('should return Right for valid email', () {
        const email = 'test@example.com';
        final result = ValidationService.validateEmail(email);
        
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (validEmail) => expect(validEmail, email),
        );
      });

      test('should return Left for empty email', () {
        const email = '';
        final result = ValidationService.validateEmail(email);
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Email é obrigatório'),
          (validEmail) => fail('Should fail'),
        );
      });

      test('should return Left for invalid email format', () {
        const email = 'invalid-email';
        final result = ValidationService.validateEmail(email);
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Email inválido'),
          (validEmail) => fail('Should fail'),
        );
      });
    });

    group('validatePassword', () {
      test('should return Right for valid password', () {
        const password = 'password123';
        final result = ValidationService.validatePassword(password);
        
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (validPassword) => expect(validPassword, password),
        );
      });

      test('should return Left for empty password', () {
        const password = '';
        final result = ValidationService.validatePassword(password);
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Senha é obrigatória'),
          (validPassword) => fail('Should fail'),
        );
      });

      test('should return Left for short password', () {
        const password = '123';
        final result = ValidationService.validatePassword(password);
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Senha deve ter pelo menos 6 caracteres'),
          (validPassword) => fail('Should fail'),
        );
      });
    });

    group('validateLoginForm', () {
      test('should return Right for valid login data', () {
        const email = 'test@example.com';
        const password = 'password123';
        
        final result = ValidationService.validateLoginForm(
          email: email,
          password: password,
        );
        
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (validData) {
            expect(validData['email'], email);
            expect(validData['password'], password);
          },
        );
      });

      test('should return Left for invalid email', () {
        const email = 'invalid-email';
        const password = 'password123';
        
        final result = ValidationService.validateLoginForm(
          email: email,
          password: password,
        );
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Email inválido'),
          (validData) => fail('Should fail'),
        );
      });
    });

    group('validateStudentRegistration', () {
      test('should return Right for valid student data', () {
        const fullName = 'João Silva';
        const email = 'joao@example.com';
        const password = 'password123';
        const registration = '12345';
        const course = 'Engenharia';
        
        final result = ValidationService.validateStudentRegistration(
          fullName: fullName,
          email: email,
          password: password,
          registration: registration,
          course: course,
        );
        
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (validData) {
            expect(validData['fullName'], fullName);
            expect(validData['email'], email);
            expect(validData['password'], password);
            expect(validData['registration'], registration);
            expect(validData['course'], course);
          },
        );
      });

      test('should return Left for invalid name', () {
        const fullName = '';
        const email = 'joao@example.com';
        const password = 'password123';
        const registration = '12345';
        
        final result = ValidationService.validateStudentRegistration(
          fullName: fullName,
          email: email,
          password: password,
          registration: registration,
        );
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Nome é obrigatório'),
          (validData) => fail('Should fail'),
        );
      });
    });
  });
}