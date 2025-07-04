import 'package:equatable/equatable.dart';
import '../../core/enums/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final UserRole role;
  final bool isActive;
  final bool emailConfirmed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? matricula;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    this.isActive = true,
    this.emailConfirmed = false,
    required this.createdAt,
    this.updatedAt,
    this.matricula,
  });

  static final UserEntity empty = UserEntity(
    id: '',
    email: '',
    fullName: '',
    role: UserRole.student,
    createdAt: DateTime.fromMicrosecondsSinceEpoch(0),
    emailConfirmed: false,
    isActive: false,
    matricula: '',
  );

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        profilePictureUrl,
        role,
        isActive,
        emailConfirmed,
        createdAt,
        updatedAt,
        matricula,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
    UserRole? role,
    bool? isActive,
    bool? emailConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? matricula,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      matricula: matricula ?? this.matricula,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.profilePictureUrl == profilePictureUrl &&
        other.role == role &&
        other.isActive == isActive &&
        other.emailConfirmed == emailConfirmed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.matricula == matricula;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        phoneNumber.hashCode ^
        profilePictureUrl.hashCode ^
        role.hashCode ^
        isActive.hashCode ^
        emailConfirmed.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        matricula.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, profilePictureUrl: $profilePictureUrl, role: $role, isActive: $isActive, emailConfirmed: $emailConfirmed, createdAt: $createdAt, updatedAt: $updatedAt, matricula: $matricula)';
  }
}
