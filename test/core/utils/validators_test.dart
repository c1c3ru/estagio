// test/core/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('siapeRegistration', () {
      test('should return null for valid 7-digit SIAPE', () {
        // Arrange
        const validSiape = '1234567';

        // Act
        final result = Validators.siapeRegistration(validSiape);

        // Assert
        expect(result, isNull);
      });

      test('should return error for null value', () {
        // Act
        final result = Validators.siapeRegistration(null);

        // Assert
        expect(result, equals('Matrícula SIAPE é obrigatória.'));
      });

      test('should return error for empty string', () {
        // Act
        final result = Validators.siapeRegistration('');

        // Assert
        expect(result, equals('Matrícula SIAPE é obrigatória.'));
      });

      test('should return error for less than 7 digits', () {
        // Arrange
        const shortSiape = '123456';

        // Act
        final result = Validators.siapeRegistration(shortSiape);

        // Assert
        expect(
            result, equals('Matrícula SIAPE deve ter exatamente 7 dígitos.'));
      });

      test('should return error for more than 7 digits', () {
        // Arrange
        const longSiape = '12345678';

        // Act
        final result = Validators.siapeRegistration(longSiape);

        // Assert
        expect(
            result, equals('Matrícula SIAPE deve ter exatamente 7 dígitos.'));
      });

      test('should return null for alphanumeric string that cleans to 7 digits',
          () {
        // Arrange
        const alphanumericSiape = '1a2b3c4d5e6f7g';

        // Act
        final result = Validators.siapeRegistration(alphanumericSiape);

        // Assert
        expect(result, isNull);
      });

      test('should handle spaces and special characters', () {
        // Arrange
        const siapeWithSpaces = '123 4567';

        // Act
        final result = Validators.siapeRegistration(siapeWithSpaces);

        // Assert
        expect(result, isNull); // Should be valid after cleaning
      });

      test(
          'should return error for string with letters that do not clean to 7 digits',
          () {
        // Arrange
        const siapeWithLetters = 'abc1234';

        // Act
        final result = Validators.siapeRegistration(siapeWithLetters);

        // Assert
        expect(
            result, equals('Matrícula SIAPE deve ter exatamente 7 dígitos.'));
      });
    });

    group('siapeRegistrationUnique', () {
      test('should return null for valid and unique SIAPE', () {
        // Arrange
        const validSiape = '1234567';

        // Act
        final result =
            Validators.siapeRegistrationUnique(validSiape, isUnique: true);

        // Assert
        expect(result, isNull);
      });

      test('should return error for non-unique SIAPE', () {
        // Arrange
        const duplicateSiape = '1234567';

        // Act
        final result =
            Validators.siapeRegistrationUnique(duplicateSiape, isUnique: false);

        // Assert
        expect(result, equals('Esta matrícula SIAPE já está em uso.'));
      });

      test('should return basic validation error for invalid SIAPE', () {
        // Arrange
        const invalidSiape = '123';

        // Act
        final result =
            Validators.siapeRegistrationUnique(invalidSiape, isUnique: true);

        // Assert
        expect(
            result, equals('Matrícula SIAPE deve ter exatamente 7 dígitos.'));
      });
    });

    group('studentRegistration', () {
      test('should return null for valid 12-digit student registration', () {
        // Arrange
        const validRegistration = '123456789012';

        // Act
        final result = Validators.studentRegistration(validRegistration);

        // Assert
        expect(result, isNull);
      });

      test('should return error for null value', () {
        // Act
        final result = Validators.studentRegistration(null);

        // Assert
        expect(result, equals('Matrícula de aluno é obrigatória.'));
      });

      test('should return error for empty string', () {
        // Act
        final result = Validators.studentRegistration('');

        // Assert
        expect(result, equals('Matrícula de aluno é obrigatória.'));
      });

      test('should return error for less than 12 digits', () {
        // Arrange
        const shortRegistration = '12345678901';

        // Act
        final result = Validators.studentRegistration(shortRegistration);

        // Assert
        expect(result,
            equals('Matrícula de aluno deve ter exatamente 12 dígitos.'));
      });

      test('should return error for more than 12 digits', () {
        // Arrange
        const longRegistration = '1234567890123';

        // Act
        final result = Validators.studentRegistration(longRegistration);

        // Assert
        expect(result,
            equals('Matrícula de aluno deve ter exatamente 12 dígitos.'));
      });

      test(
          'should return null for alphanumeric string that cleans to 12 digits',
          () {
        // Arrange
        const alphanumericRegistration = '1a2b3c4d5e6f7g8h9i0j1k2l';

        // Act
        final result = Validators.studentRegistration(alphanumericRegistration);

        // Assert
        expect(result, isNull);
      });

      test('should handle spaces and special characters', () {
        // Arrange
        const registrationWithSpaces = '123 456 789 012';

        // Act
        final result = Validators.studentRegistration(registrationWithSpaces);

        // Assert
        expect(result, isNull); // Should be valid after cleaning
      });

      test(
          'should return error for string with letters that do not clean to 12 digits',
          () {
        // Arrange
        const registrationWithLetters = 'abc123456789';

        // Act
        final result = Validators.studentRegistration(registrationWithLetters);

        // Assert
        expect(result,
            equals('Matrícula de aluno deve ter exatamente 12 dígitos.'));
      });
    });
  });
}
