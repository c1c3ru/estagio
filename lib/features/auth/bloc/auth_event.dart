// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:gestao_de_estagio/core/enums/class_shift.dart';
import 'package:gestao_de_estagio/core/enums/internship_shift.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../core/enums/user_role.dart';

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
  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String? registration;
  final bool? isMandatoryInternship;
  final String? supervisorId;
  final String? course;
  final String? advisorName;
  final String? department;
  final ClassShift? classShift;
  final InternshipShift? internshipShift;
  final DateTime? birthDate;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.registration,
    this.isMandatoryInternship,
    this.supervisorId,
    this.course,
    this.advisorName,
    this.department,
    this.classShift,
    this.internshipShift,
    this.birthDate,
    this.contractStartDate,
    this.contractEndDate,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        password,
        role,
        registration,
        isMandatoryInternship,
        supervisorId,
        course,
        advisorName,
        department,
        classShift,
        internshipShift,
        birthDate,
        contractStartDate,
        contractEndDate,
      ];
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
