import '../../domain/entities/supervisor_entity.dart';

class SupervisorModel {
  final String id;
  final String fullName;
  final String? department;
  final String? position;
  final String? jobCode;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SupervisorModel({
    required this.id,
    required this.fullName,
    this.department,
    this.position,
    this.jobCode,
    this.profilePictureUrl,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      department: json['department'] as String?,
      position: json['position'] as String?,
      jobCode: json['job_code'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'department': department,
      'position': position,
      'job_code': jobCode,
      'profile_picture_url': profilePictureUrl,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SupervisorEntity toEntity() {
    return SupervisorEntity(
      id: id,
      fullName: fullName,
      department: department,
      position: position,
      jobCode: jobCode,
      profilePictureUrl: profilePictureUrl,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SupervisorModel.fromEntity(SupervisorEntity entity) {
    return SupervisorModel(
      id: entity.id,
      fullName: entity.fullName,
      department: entity.department,
      position: entity.position,
      jobCode: entity.jobCode,
      profilePictureUrl: entity.profilePictureUrl,
      phoneNumber: entity.phoneNumber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SupervisorModel copyWith({
    String? id,
    String? fullName,
    String? department,
    String? position,
    String? jobCode,
    String? profilePictureUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupervisorModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      position: position ?? this.position,
      jobCode: jobCode ?? this.jobCode,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupervisorModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.department == department &&
        other.position == position &&
        other.jobCode == jobCode &&
        other.profilePictureUrl == profilePictureUrl &&
        other.phoneNumber == phoneNumber &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        department.hashCode ^
        position.hashCode ^
        jobCode.hashCode ^
        profilePictureUrl.hashCode ^
        phoneNumber.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'SupervisorModel(id: $id, fullName: $fullName, department: $department, position: $position, jobCode: $jobCode, profilePictureUrl: $profilePictureUrl, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
