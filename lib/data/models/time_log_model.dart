import '../../domain/entities/time_log_entity.dart';

class TimeLogModel extends TimeLogEntity {
  const TimeLogModel({
    required super.id,
    required super.studentId,
    required super.clockIn,
    super.clockOut,
    super.description,
    super.isApproved = false,
    super.rejectionReason,
    super.approvedBy,
    super.approvedAt,
    required super.createdAt,
    super.updatedAt,
  });

  factory TimeLogModel.fromJson(Map<String, dynamic> json) {
    return TimeLogModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      clockIn: DateTime.parse(json['clock_in'] as String),
      clockOut: json['clock_out'] != null
          ? DateTime.parse(json['clock_out'] as String)
          : null,
      description: json['description'] as String?,
      isApproved: json['is_approved'] as bool? ?? false,
      rejectionReason: json['rejection_reason'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
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
      'clock_in': clockIn.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
      'description': description,
      'is_approved': isApproved,
      'rejection_reason': rejectionReason,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TimeLogEntity toEntity() {
    return TimeLogEntity(
      id: id,
      studentId: studentId,
      clockIn: clockIn,
      clockOut: clockOut,
      description: description,
      isApproved: isApproved,
      rejectionReason: rejectionReason,
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TimeLogModel.fromEntity(TimeLogEntity entity) {
    return TimeLogModel(
      id: entity.id,
      studentId: entity.studentId,
      clockIn: entity.clockIn,
      clockOut: entity.clockOut,
      description: entity.description,
      isApproved: entity.isApproved,
      rejectionReason: entity.rejectionReason,
      approvedBy: entity.approvedBy,
      approvedAt: entity.approvedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  TimeLogEntity copyWith({
    String? id,
    String? studentId,
    DateTime? clockIn,
    DateTime? clockOut,
    String? description,
    bool? isApproved,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeLogModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      description: description ?? this.description,
      isApproved: isApproved ?? this.isApproved,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration? get totalHours {
    if (updatedAt == null) return null;
    return updatedAt!.difference(clockIn);
  }

  bool get isActive => updatedAt == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeLogModel &&
        other.id == id &&
        other.studentId == studentId &&
        other.clockIn == clockIn &&
        other.clockOut == clockOut &&
        other.description == description &&
        other.isApproved == isApproved &&
        other.rejectionReason == rejectionReason &&
        other.approvedBy == approvedBy &&
        other.approvedAt == approvedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        clockIn.hashCode ^
        clockOut.hashCode ^
        description.hashCode ^
        isApproved.hashCode ^
        rejectionReason.hashCode ^
        approvedBy.hashCode ^
        approvedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'TimeLogModel(id: $id, studentId: $studentId, clockIn: $clockIn, clockOut: $clockOut, description: $description, isApproved: $isApproved, rejectionReason: $rejectionReason, approvedBy: $approvedBy, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
