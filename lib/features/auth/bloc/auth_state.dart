// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart'; // Importa UserEntity do domínio

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial, antes de qualquer ação de autenticação.
class AuthInitial extends AuthState {}

/// Estado enquanto uma operação de autenticação está em progresso.
class AuthLoading extends AuthState {}

/// Estado de sucesso na autenticação (login ou verificação de status).
class AuthSuccess extends AuthState {
  final UserEntity user;
  final bool isProfileIncomplete;

  const AuthSuccess(this.user, {this.isProfileIncomplete = false});

  @override
  List<Object> get props => [user, isProfileIncomplete];
}

/// Estado quando o utilizador não está autenticado.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de sucesso no registo (geralmente leva a um passo de confirmação de email).
class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// Estado quando o registro foi bem-sucedido mas requer confirmação de email.
class AuthEmailConfirmationRequired extends AuthState {
  final String email;
  final String message;

  const AuthEmailConfirmationRequired({
    required this.email,
    this.message = 'Verifique seu e-mail para confirmar o cadastro',
  });

  @override
  List<Object> get props => [email, message];
}

/// Estado de sucesso no envio de email de redefinição de senha.
class AuthPasswordResetEmailSent extends AuthState {
  final String message;

  const AuthPasswordResetEmailSent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de falha em qualquer operação de autenticação.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Estado de sucesso na atualização do perfil
class AuthProfileUpdateSuccess extends AuthState {
  final String message;

  const AuthProfileUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthLogoutSuccess extends AuthState {
  const AuthLogoutSuccess();
}

class AuthProfileUpdated extends AuthState {
  final UserEntity updatedUser;
  const AuthProfileUpdated({required this.updatedUser});

  @override
  List<Object?> get props => [updatedUser];
}

/// Estado quando o perfil do usuário está incompleto e precisa ser preenchido
class AuthProfileIncomplete extends AuthState {
  final UserEntity user;
  const AuthProfileIncomplete(this.user);

  @override
  List<Object?> get props => [user];
}
