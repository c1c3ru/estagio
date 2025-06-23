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

      test('should return error for non-numeric characters', () {
        // Arrange
        const alphanumericSiape = '123456a';

        // Act
        final result = Validators.siapeRegistration(alphanumericSiape);

        // Assert
        expect(result, equals('Matrícula SIAPE deve conter apenas números.'));
      });

      test('should handle spaces and special characters', () {
        // Arrange
        const siapeWithSpaces = '123 456 7';

        // Act
        final result = Validators.siapeRegistration(siapeWithSpaces);

        // Assert
        expect(result, isNull); // Should be valid after cleaning
      });

      test('should return error for string with letters', () {
        // Arrange
        const siapeWithLetters = 'abc1234';

        // Act
        final result = Validators.siapeRegistration(siapeWithLetters);

        // Assert
        expect(result, equals('Matrícula SIAPE deve conter apenas números.'));
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
  });
}
