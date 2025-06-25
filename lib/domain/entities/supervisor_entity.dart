class SupervisorEntity {
  final String id;
  final String fullName;
  final String? department;
  final String? position;
  final String? jobCode;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupervisorEntity({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupervisorEntity &&
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
    return 'SupervisorEntity(id: $id, fullName: $fullName, department: $department, position: $position, jobCode: $jobCode, profilePictureUrl: $profilePictureUrl, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  SupervisorEntity copyWith({
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
    return SupervisorEntity(
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
}
