import '../../core/enums/user_role.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.profilePictureUrl,
    required super.role,
    super.isActive = true,
    super.emailConfirmed = false,
    required super.createdAt,
    super.updatedAt,
    super.matricula,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: (json['full_name'] ?? json['fullName'] ?? '') as String,
      phoneNumber: json['phone_number'] as String?,
      profilePictureUrl:
          json['profile_picture_url'] ?? json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String),
      isActive: json['is_active'] as bool? ?? true,
      emailConfirmed: json['email_confirmed'] as bool? ?? false,
      createdAt:
          DateTime.parse(json['created_at'] ?? json['createdAt'] as String),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'] as String)
          : null,
      matricula: json['matricula'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'role': role.value,
      'is_active': isActive,
      'email_confirmed': emailConfirmed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'matricula': matricula,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      role: role,
      isActive: isActive,
      emailConfirmed: emailConfirmed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      matricula: matricula,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      profilePictureUrl: entity.profilePictureUrl,
      role: entity.role,
      isActive: entity.isActive,
      emailConfirmed: entity.emailConfirmed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      matricula: entity.matricula,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
    return other is UserModel &&
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
    return 'UserModel(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, profilePictureUrl: $profilePictureUrl, role: $role, isActive: $isActive, emailConfirmed: $emailConfirmed, createdAt: $createdAt, updatedAt: $updatedAt, matricula: $matricula)';
  }
}
