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
    required super.createdAt,
    super.updatedAt,
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
      createdAt:
          DateTime.parse(json['created_at'] ?? json['createdAt'] as String),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'role': role.toString(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
      createdAt: createdAt,
      updatedAt: updatedAt,
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
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
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
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, profilePictureUrl: $profilePictureUrl, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
