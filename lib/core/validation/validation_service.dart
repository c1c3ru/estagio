import '../errors/app_exceptions.dart';
import 'package:dartz/dartz.dart';

class ValidationService {
  static Either<ValidationFailure, String> validateEmail(String email) {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }
    
    return Right(email);
  }

  static Either<ValidationFailure, String> validatePassword(String password) {
    if (password.isEmpty) {
      return const Left(ValidationFailure('Senha é obrigatória'));
    }
    
    if (password.length < 6) {
      return const Left(ValidationFailure('Senha deve ter pelo menos 6 caracteres'));
    }
    
    return Right(password);
  }

  static Either<ValidationFailure, String> validateName(String name) {
    if (name.isEmpty) {
      return const Left(ValidationFailure('Nome é obrigatório'));
    }
    
    if (name.length < 2) {
      return const Left(ValidationFailure('Nome deve ter pelo menos 2 caracteres'));
    }
    
    return Right(name);
  }

  static Either<ValidationFailure, String> validateRegistration(String registration) {
    if (registration.isEmpty) {
      return const Left(ValidationFailure('Matrícula é obrigatória'));
    }
    
    if (registration.length < 3) {
      return const Left(ValidationFailure('Matrícula deve ter pelo menos 3 caracteres'));
    }
    
    return Right(registration);
  }

  static Either<ValidationFailure, String> validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return const Left(ValidationFailure('Telefone é obrigatório'));
    }
    
    final phoneRegex = RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$');
    if (!phoneRegex.hasMatch(phone)) {
      return const Left(ValidationFailure('Formato de telefone inválido'));
    }
    
    return Right(phone);
  }

  static Either<ValidationFailure, DateTime> validateDate(DateTime? date, String fieldName) {
    if (date == null) {
      return Left(ValidationFailure('$fieldName é obrigatória'));
    }
    
    return Right(date);
  }

  static Either<ValidationFailure, DateTime> validateFutureDate(DateTime? date, String fieldName) {
    if (date == null) {
      return Left(ValidationFailure('$fieldName é obrigatória'));
    }
    
    if (date.isBefore(DateTime.now())) {
      return Left(ValidationFailure('$fieldName deve ser uma data futura'));
    }
    
    return Right(date);
  }

  static Either<ValidationFailure, Map<String, String>> validateLoginForm({
    required String email,
    required String password,
  }) {
    final emailValidation = validateEmail(email);
    final passwordValidation = validatePassword(password);
    
    return emailValidation.fold(
      (failure) => Left(failure),
      (validEmail) => passwordValidation.fold(
        (failure) => Left(failure),
        (validPassword) => Right({
          'email': validEmail,
          'password': validPassword,
        }),
      ),
    );
  }

  static Either<ValidationFailure, Map<String, dynamic>> validateStudentRegistration({
    required String fullName,
    required String email,
    required String password,
    required String registration,
    String? course,
  }) {
    final nameValidation = validateName(fullName);
    final emailValidation = validateEmail(email);
    final passwordValidation = validatePassword(password);
    final registrationValidation = validateRegistration(registration);
    
    return nameValidation.fold(
      (failure) => Left(failure),
      (validName) => emailValidation.fold(
        (failure) => Left(failure),
        (validEmail) => passwordValidation.fold(
          (failure) => Left(failure),
          (validPassword) => registrationValidation.fold(
            (failure) => Left(failure),
            (validRegistration) => Right({
              'fullName': validName,
              'email': validEmail,
              'password': validPassword,
              'registration': validRegistration,
              'course': course,
            }),
          ),
        ),
      ),
    );
  }
}