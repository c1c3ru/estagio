// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class GetCurrentUserRequested extends AuthEvent {}

class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateProfileRequested extends AuthEvent {
  final UpdateProfileParams params;

  const UpdateProfileRequested({required this.params});

  @override
  List<Object> get props => [params];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthInitializeRequested extends AuthEvent {
  const AuthInitializeRequested();
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

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const AuthUserChanged({this.user});

  @override
  List<Object?> get props => [user];
}
