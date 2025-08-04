import 'package:equatable/equatable.dart';

enum ExceptionType { auth, server, cache, network, validation, unknown }

enum StudentStatus {
  active,
  inactive,
  graduated,
  suspended,
  pending,
  completed,
  terminated,
  unknown;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
}

class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class DatabaseException extends AppException {
  DatabaseException(super.message);
}

class AppFailure extends Equatable {
  final String message;
  final dynamic originalException;

  const AppFailure({
    required this.message,
    this.originalException,
  });

  /// Cria uma falha inesperada
  static AppFailure unexpected([String? message]) {
    return AppFailure(
      message: message ?? 'Erro inesperado ocorreu',
    );
  }

  @override
  List<Object?> get props => [message, originalException];

  @override
  String toString() => message;
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(String message) : super(message: message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(String message) : super(message: message);
}

class AuthFailure extends AppFailure {
  const AuthFailure(String message) : super(message: message);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure(String message) : super(message: message);
}

class NotImplementedFailure extends AppFailure {
  const NotImplementedFailure({required super.message, super.originalException});
}

class ServerFailure extends AppFailure {
  const ServerFailure({
    required super.message,
    super.originalException,
  });
}

class ServerException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const ServerException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'ServerException: $message';
}
