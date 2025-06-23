import '../../domain/entities/supervisor_entity.dart';

class SupervisorModel {
  final String id;
  final String userId;
  final String department;
  final String position;
  final String specialization;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupervisorModel({
    required this.id,
    required this.userId,
    required this.department,
    required this.position,
    required this.specialization,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      department: json['department'] as String,
      specialization: json["specialization"] as String,
      position: json["position"] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'department': department,
      'position': position,
      'specialization': specialization,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SupervisorEntity toEntity() {
    return SupervisorEntity(
      id: id,
      userId: userId,
      department: department,
      specialization: specialization,
      position: position,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SupervisorModel.fromEntity(SupervisorEntity entity) {
    return SupervisorModel(
      id: entity.id,
      userId: entity.userId,
      department: entity.department,
      position: entity.position,
      specialization: entity.specialization,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SupervisorModel copyWith({
    String? id,
    String? userId,
    String? department,
    String? specialization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupervisorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      department: department ?? this.department,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      position: 'Função',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupervisorModel &&
        other.id == id &&
        other.userId == userId &&
        other.department == department &&
        other.specialization == specialization &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        department.hashCode ^
        specialization.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'SupervisorModel(id: $id, userId: $userId, department: $department, specialization: $specialization, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
