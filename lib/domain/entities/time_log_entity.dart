import 'package:equatable/equatable.dart';

class TimeLogEntity extends Equatable {
  final String id;
  final String studentId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String? description;
  final bool isApproved;
  final String? rejectionReason;
  final String? approvedBy; // Supervisor ID
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TimeLogEntity({
    required this.id,
    required this.studentId,
    required this.clockIn,
    this.clockOut,
    this.description,
    this.isApproved = false,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimeLogEntity.fromJson(Map<String, dynamic> json) {
    return TimeLogEntity(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      clockIn: DateTime.parse(json['clock_in'] as String),
      clockOut: json['clock_out'] != null
          ? DateTime.parse(json['clock_out'] as String)
          : null,
      description: json['description'] as String?,
      isApproved: json['is_approved'] as bool,
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

  @override
  List<Object?> get props => [
        id,
        studentId,
        clockIn,
        clockOut,
        description,
        isApproved,
        rejectionReason,
        approvedBy,
        approvedAt,
        createdAt,
        updatedAt,
      ];

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
    return TimeLogEntity(
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

  bool get isClockedIn => clockOut == null;

  Duration get duration {
    if (clockOut == null) {
      return Duration.zero;
    }
    return clockOut!.difference(clockIn);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeLogEntity &&
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

  get checkOutTime => clockOut;

  get logDate => clockIn;

  get checkInTime => clockIn;

  bool get approved => isApproved;

  get hoursLogged => duration.inHours.toDouble();

  @override
  String toString() {
    return 'TimeLogEntity(id: $id, studentId: $studentId, clockIn: $clockIn, clockOut: $clockOut, description: $description, isApproved: $isApproved, rejectionReason: $rejectionReason, approvedBy: $approvedBy, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
