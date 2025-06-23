import '../../domain/entities/contract_entity.dart';
import '../../core/enums/contract_status.dart';

class ContractModel {
  final String id;
  final String studentId;
  final String supervisorId;
  final String company;
  final String position;
  final DateTime startDate;
  final DateTime endDate;
  final double totalHoursRequired;
  final double weeklyHoursTarget;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ContractModel({
    required this.id,
    required this.studentId,
    required this.supervisorId,
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.totalHoursRequired,
    required this.weeklyHoursTarget,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      company: json['company'] as String,
      position: json['position'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalHoursRequired: (json['total_hours_required'] as num).toDouble(),
      weeklyHoursTarget: (json['weekly_hours_target'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'supervisor_id': supervisorId,
      'company': company,
      'position': position,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_hours_required': totalHoursRequired,
      'weekly_hours_target': weeklyHoursTarget,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ContractEntity toEntity() {
    return ContractEntity(
      id: id,
      studentId: studentId,
      supervisorId: supervisorId,
      company: company,
      position: position,
      startDate: startDate,
      endDate: endDate,
      totalHoursRequired: totalHoursRequired,
      weeklyHoursTarget: weeklyHoursTarget,
      status: ContractStatus.fromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ContractModel.fromEntity(ContractEntity entity) {
    return ContractModel(
      id: entity.id,
      studentId: entity.studentId,
      supervisorId: entity.supervisorId,
      company: entity.company,
      position: entity.position,
      startDate: entity.startDate,
      endDate: entity.endDate,
      totalHoursRequired: entity.totalHoursRequired,
      weeklyHoursTarget: entity.weeklyHoursTarget,
      status: entity.status.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ContractModel copyWith({
    String? id,
    String? studentId,
    String? supervisorId,
    String? company,
    String? position,
    DateTime? startDate,
    DateTime? endDate,
    double? totalHoursRequired,
    double? weeklyHoursTarget,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalHoursRequired: totalHoursRequired ?? this.totalHoursRequired,
      weeklyHoursTarget: weeklyHoursTarget ?? this.weeklyHoursTarget,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == ContractStatus.active.value;
  bool get isExpired => DateTime.now().isAfter(endDate);
  Duration get duration => endDate.difference(startDate);
  Duration get remainingTime => endDate.difference(DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContractModel &&
        other.id == id &&
        other.studentId == studentId &&
        other.supervisorId == supervisorId &&
        other.company == company &&
        other.position == position &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalHoursRequired == totalHoursRequired &&
        other.weeklyHoursTarget == weeklyHoursTarget &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        supervisorId.hashCode ^
        company.hashCode ^
        position.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        totalHoursRequired.hashCode ^
        weeklyHoursTarget.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ContractModel(id: $id, studentId: $studentId, supervisorId: $supervisorId, company: $company, position: $position, startDate: $startDate, endDate: $endDate, totalHoursRequired: $totalHoursRequired, weeklyHoursTarget: $weeklyHoursTarget, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
