// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:gestao_de_estagio/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthInitializeRequested extends AuthEvent {
  const AuthInitializeRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String role;
  final String? registration;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.registration,
  });

  @override
  List<Object?> get props => [email, password, fullName, role, registration];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String userId;
  final String? fullName;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? profilePictureUrl;

  const AuthUpdateProfileRequested({
    required this.userId,
    this.fullName,
    this.email,
    this.password,
    this.phoneNumber,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        password,
        phoneNumber,
        profilePictureUrl,
      ];
}

/// Evento para ouvir mudanças no estado de autenticação (ex: do stream do Supabase)
class AuthStateChangedEvent extends AuthEvent {
  final bool isAuthenticated;
  final UserEntity? user; // Usando UserEntity do domínio

  const AuthStateChangedEvent({required this.isAuthenticated, this.user});

  @override
  List<Object?> get props => [isAuthenticated, user];
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const AuthUserChanged({this.user});

  @override
  List<Object?> get props => [user];
}
