// test/core/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('Basic Validators', () {
      group('required', () {
        test('should return null for valid non-empty string', () {
          expect(Validators.required('test'), isNull);
          expect(Validators.required('  test  '), isNull);
        });

        test('should return error for null or empty string', () {
          expect(Validators.required(null), isNotNull);
          expect(Validators.required(''), isNotNull);
          expect(Validators.required('   '), isNotNull);
        });

        test('should use custom field name in error message', () {
          final result = Validators.required(null, fieldName: 'Nome');
          expect(result, contains('Nome'));
        });
      });

      group('email', () {
        test('should return null for valid email', () {
          expect(Validators.email('test@example.com'), isNull);
          expect(Validators.email('user.name@domain.co.uk'), isNull);
          expect(Validators.email('test+tag@example.org'), isNull);
        });

        test('should return error for invalid email', () {
          expect(Validators.email('invalid'), isNotNull);
          expect(Validators.email('test@'), isNotNull);
          expect(Validators.email('@example.com'), isNotNull);
          expect(Validators.email('test.example.com'), isNotNull);
        });

        test('should return error for null or empty email', () {
          expect(Validators.email(null), isNotNull);
          expect(Validators.email(''), isNotNull);
        });
      });

      group('password', () {
        test('should return null for valid password', () {
          expect(Validators.password('123456'), isNull);
          expect(Validators.password('password123'), isNull);
        });

        test('should return error for short password', () {
          expect(Validators.password('123'), isNotNull);
          expect(Validators.password('12345'), isNotNull);
        });

        test('should respect custom minimum length', () {
          expect(Validators.password('123456789', minLength: 10), isNotNull);
          expect(Validators.password('1234567890', minLength: 10), isNull);
        });

        test('should return error for null or empty password', () {
          expect(Validators.password(null), isNotNull);
          expect(Validators.password(''), isNotNull);
        });
      });

      group('strongPassword', () {
        test('should return null for strong password', () {
          expect(Validators.strongPassword('Password123'), isNull);
          expect(Validators.strongPassword('MyStr0ngP@ss'), isNull);
        });

        test('should return error for weak passwords', () {
          expect(Validators.strongPassword('password'), isNotNull); // No uppercase
          expect(Validators.strongPassword('PASSWORD'), isNotNull); // No lowercase
          expect(Validators.strongPassword('Password'), isNotNull); // No number
          expect(Validators.strongPassword('Pass123'), isNotNull); // Too short
        });

        test('should return error for null or empty password', () {
          expect(Validators.strongPassword(null), isNotNull);
          expect(Validators.strongPassword(''), isNotNull);
        });
      });

      group('confirmPassword', () {
        test('should return null when passwords match', () {
          expect(Validators.confirmPassword('password', 'password'), isNull);
        });

        test('should return error when passwords do not match', () {
          expect(Validators.confirmPassword('password1', 'password2'), isNotNull);
        });

        test('should return error for null or empty confirm password', () {
          expect(Validators.confirmPassword('password', null), isNotNull);
          expect(Validators.confirmPassword('password', ''), isNotNull);
        });
      });

      group('phoneNumber', () {
        test('should return null for valid phone numbers', () {
          expect(Validators.phoneNumber('1234567890'), isNull);
          expect(Validators.phoneNumber('+5511999999999'), isNull);
          expect(Validators.phoneNumber('(11) 99999-9999'), isNull);
        });

        test('should return error for invalid phone numbers', () {
          expect(Validators.phoneNumber('123'), isNotNull);
          expect(Validators.phoneNumber('abc'), isNotNull);
          expect(Validators.phoneNumber('123456789012345678'), isNotNull);
        });

        test('should return error for null or empty phone', () {
          expect(Validators.phoneNumber(null), isNotNull);
          expect(Validators.phoneNumber(''), isNotNull);
        });
      });
    });

    group('Date Validators', () {
      group('dateNotFuture', () {
        test('should return null for past and present dates', () {
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          final today = DateTime.now();
          
          expect(Validators.dateNotFuture(yesterday), isNull);
          expect(Validators.dateNotFuture(today), isNull);
        });

        test('should return error for future dates', () {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          expect(Validators.dateNotFuture(tomorrow), isNotNull);
        });

        test('should return error for null date', () {
          expect(Validators.dateNotFuture(null), isNotNull);
        });

        test('should use custom field name in error message', () {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final result = Validators.dateNotFuture(tomorrow, fieldName: 'Nascimento');
          expect(result, contains('Nascimento'));
        });
      });

      group('dateNotPast', () {
        test('should return null for present and future dates', () {
          final today = DateTime.now();
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          
          expect(Validators.dateNotPast(today), isNull);
          expect(Validators.dateNotPast(tomorrow), isNull);
        });

        test('should return error for past dates', () {
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          expect(Validators.dateNotPast(yesterday), isNotNull);
        });

        test('should return error for null date', () {
          expect(Validators.dateNotPast(null), isNotNull);
        });
      });

      group('dateRange', () {
        test('should return null for valid date range', () {
          final start = DateTime(2023, 1, 1);
          final end = DateTime(2023, 12, 31);
          
          expect(Validators.dateRange(start, end), isNull);
        });

        test('should return error when end date is before start date', () {
          final start = DateTime(2023, 12, 31);
          final end = DateTime(2023, 1, 1);
          
          expect(Validators.dateRange(start, end), isNotNull);
        });

        test('should return error for null dates', () {
          final date = DateTime.now();
          
          expect(Validators.dateRange(null, date), isNotNull);
          expect(Validators.dateRange(date, null), isNotNull);
          expect(Validators.dateRange(null, null), isNotNull);
        });
      });

      group('contractDuration', () {
        test('should return null for valid contract duration', () {
          final start = DateTime.now();
          final end = start.add(const Duration(days: 60));
          
          expect(Validators.contractDuration(start, end), isNull);
        });

        test('should return error for short contract duration', () {
          final start = DateTime.now();
          final end = start.add(const Duration(days: 15));
          
          expect(Validators.contractDuration(start, end), isNotNull);
        });

        test('should respect custom minimum days', () {
          final start = DateTime.now();
          final end = start.add(const Duration(days: 45));
          
          expect(Validators.contractDuration(start, end, minDays: 60), isNotNull);
          expect(Validators.contractDuration(start, end, minDays: 30), isNull);
        });
      });
    });

    group('Registration Validators', () {
      group('siapeRegistration', () {
        test('should return null for valid SIAPE registration', () {
          expect(Validators.siapeRegistration('1234567'), isNull);
          expect(Validators.siapeRegistration('0000001'), isNull);
        });

        test('should return error for invalid SIAPE registration', () {
          expect(Validators.siapeRegistration('123456'), isNotNull); // Too short
          expect(Validators.siapeRegistration('12345678'), isNotNull); // Too long
          expect(Validators.siapeRegistration('123456a'), isNotNull); // Contains letter
        });

        test('should return error for null or empty SIAPE', () {
          expect(Validators.siapeRegistration(null), isNotNull);
          expect(Validators.siapeRegistration(''), isNotNull);
        });
      });

      group('studentRegistration', () {
        test('should return null for valid student registration', () {
          expect(Validators.studentRegistration('123456789012'), isNull);
          expect(Validators.studentRegistration('000000000001'), isNull);
        });

        test('should return error for invalid student registration', () {
          expect(Validators.studentRegistration('12345678901'), isNotNull); // Too short
          expect(Validators.studentRegistration('1234567890123'), isNotNull); // Too long
          expect(Validators.studentRegistration('12345678901a'), isNotNull); // Contains letter
        });

        test('should return error for null or empty registration', () {
          expect(Validators.studentRegistration(null), isNotNull);
          expect(Validators.studentRegistration(''), isNotNull);
        });
      });
    });

    group('Domain-Specific Validators', () {
      group('fullName', () {
        test('should return null for valid full names', () {
          expect(Validators.fullName('João Silva'), isNull);
          expect(Validators.fullName('Maria da Silva Santos'), isNull);
        });

        test('should return error for single name', () {
          expect(Validators.fullName('João'), isNotNull);
        });

        test('should return error for short names', () {
          expect(Validators.fullName('Jo'), isNotNull);
          expect(Validators.fullName('A B'), isNotNull);
        });

        test('should return error for null or empty name', () {
          expect(Validators.fullName(null), isNotNull);
          expect(Validators.fullName(''), isNotNull);
        });
      });

      group('course', () {
        test('should return null for valid course names', () {
          expect(Validators.course('Engenharia'), isNull);
          expect(Validators.course('Ciência da Computação'), isNull);
        });

        test('should return error for short course names', () {
          expect(Validators.course('CC'), isNotNull);
        });

        test('should return error for null or empty course', () {
          expect(Validators.course(null), isNotNull);
          expect(Validators.course(''), isNotNull);
        });
      });

      group('hoursWorked', () {
        test('should return null for valid hours', () {
          expect(Validators.hoursWorked(8.0), isNull);
          expect(Validators.hoursWorked(0.0), isNull);
          expect(Validators.hoursWorked(24.0), isNull);
        });

        test('should return error for invalid hours', () {
          expect(Validators.hoursWorked(-1.0), isNotNull);
          expect(Validators.hoursWorked(25.0), isNotNull);
        });

        test('should return error for null hours', () {
          expect(Validators.hoursWorked(null), isNotNull);
        });
      });

      group('description', () {
        test('should return null for valid descriptions', () {
          expect(Validators.description('Valid description'), isNull);
          expect(Validators.description(''), isNull);
          expect(Validators.description(null), isNull);
        });

        test('should return error for long descriptions', () {
          final longDescription = 'a' * 501;
          expect(Validators.description(longDescription), isNotNull);
        });

        test('should respect custom max length', () {
          expect(Validators.description('test', maxLength: 3), isNotNull);
          expect(Validators.description('test', maxLength: 5), isNull);
        });
      });
    });

    group('Composite Validators', () {
      group('validateStudentRegistration', () {
        test('should return no errors for valid student data', () {
          final result = Validators.validateStudentRegistration(
            fullName: 'João Silva',
            email: 'joao@example.com',
            password: 'Password123',
            confirmPassword: 'Password123',
            registration: '123456789012',
            course: 'Engenharia',
          );

          expect(Validators.hasValidationErrors(result), isFalse);
        });

        test('should return errors for invalid student data', () {
          final result = Validators.validateStudentRegistration(
            fullName: 'João', // Invalid: single name
            email: 'invalid-email', // Invalid email
            password: 'weak', // Invalid: too short
            confirmPassword: 'different', // Invalid: doesn\'t match
            registration: '123', // Invalid: too short
            course: 'CC', // Invalid: too short
          );

          expect(Validators.hasValidationErrors(result), isTrue);
          expect(result['fullName'], isNotNull);
          expect(result['email'], isNotNull);
          expect(result['password'], isNotNull);
          expect(result['confirmPassword'], isNotNull);
          expect(result['registration'], isNotNull);
          expect(result['course'], isNotNull);
        });
      });

      group('validateSupervisorRegistration', () {
        test('should return no errors for valid supervisor data', () {
          final result = Validators.validateSupervisorRegistration(
            fullName: 'Dr. Maria Santos',
            email: 'maria@example.com',
            password: 'Password123',
            confirmPassword: 'Password123',
            siapeRegistration: '1234567',
          );

          expect(Validators.hasValidationErrors(result), isFalse);
        });

        test('should return errors for invalid supervisor data', () {
          final result = Validators.validateSupervisorRegistration(
            fullName: 'Maria', // Invalid: single name
            email: 'invalid-email', // Invalid email
            password: 'weak', // Invalid: too short
            confirmPassword: 'different', // Invalid: doesn\'t match
            siapeRegistration: '123', // Invalid: too short
          );

          expect(Validators.hasValidationErrors(result), isTrue);
          expect(result['fullName'], isNotNull);
          expect(result['email'], isNotNull);
          expect(result['password'], isNotNull);
          expect(result['confirmPassword'], isNotNull);
          expect(result['siapeRegistration'], isNotNull);
        });
      });

      group('validateTimeLog', () {
        test('should return no errors for valid time log data', () {
          final result = Validators.validateTimeLog(
            studentId: 'student-123',
            description: 'Worked on project',
          );

          expect(Validators.hasValidationErrors(result), isFalse);
        });

        test('should return errors for invalid time log data', () {
          final result = Validators.validateTimeLog(
            studentId: '', // Invalid: empty
            description: 'a' * 501, // Invalid: too long
          );

          expect(Validators.hasValidationErrors(result), isTrue);
          expect(result['studentId'], isNotNull);
          expect(result['description'], isNotNull);
        });
      });

      group('validateContract', () {
        test('should return no errors for valid contract data', () {
          final start = DateTime.now();
          final end = start.add(const Duration(days: 60));

          final result = Validators.validateContract(
            studentId: 'student-123',
            supervisorId: 'supervisor-456',
            startDate: start,
            endDate: end,
          );

          expect(Validators.hasValidationErrors(result), isFalse);
        });

        test('should return errors for invalid contract data', () {
          final start = DateTime.now();
          final end = start.subtract(const Duration(days: 1)); // Invalid: end before start

          final result = Validators.validateContract(
            studentId: '', // Invalid: empty
            supervisorId: '', // Invalid: empty
            startDate: start,
            endDate: end,
          );

          expect(Validators.hasValidationErrors(result), isTrue);
          expect(result['studentId'], isNotNull);
          expect(result['supervisorId'], isNotNull);
          expect(result['contractDuration'], isNotNull);
        });
      });
    });

    group('Utility Methods', () {
      test('hasValidationErrors should detect errors correctly', () {
        final noErrors = {'field1': null, 'field2': null};
        final withErrors = {'field1': 'Error', 'field2': null};

        expect(Validators.hasValidationErrors(noErrors), isFalse);
        expect(Validators.hasValidationErrors(withErrors), isTrue);
      });

      test('getValidationErrors should return only errors', () {
        final mixed = {'field1': 'Error 1', 'field2': null, 'field3': 'Error 3'};
        final errors = Validators.getValidationErrors(mixed);

        expect(errors.length, equals(2));
        expect(errors['field1'], equals('Error 1'));
        expect(errors['field3'], equals('Error 3'));
        expect(errors.containsKey('field2'), isFalse);
      });

      test('getFirstValidationError should return first error', () {
        final mixed = {'field1': null, 'field2': 'First Error', 'field3': 'Second Error'};
        final firstError = Validators.getFirstValidationError(mixed);

        expect(firstError, equals('First Error'));
      });

      test('getFirstValidationError should return null when no errors', () {
        final noErrors = {'field1': null, 'field2': null};
        final firstError = Validators.getFirstValidationError(noErrors);

        expect(firstError, isNull);
      });
    });
  });
}
