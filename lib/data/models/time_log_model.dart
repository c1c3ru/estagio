import '../../domain/entities/time_log_entity.dart';

class TimeLogModel {
  final String id;
  final String studentId;
  final DateTime logDate;
  final String checkInTime;
  final String? checkOutTime;
  final double? hoursLogged;
  final String? description;
  final bool? approved;
  final String? supervisorId;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TimeLogModel({
    required this.id,
    required this.studentId,
    required this.logDate,
    required this.checkInTime,
    this.checkOutTime,
    this.hoursLogged,
    this.description,
    this.approved,
    this.supervisorId,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimeLogModel.fromJson(Map<String, dynamic> json) {
    return TimeLogModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      checkInTime: json['check_in_time'] as String,
      checkOutTime: json['check_out_time'] as String?,
      hoursLogged: (json['hours_logged'] as num?)?.toDouble(),
      description: json['description'] as String?,
      approved: json['approved'] as bool?,
      supervisorId: json['supervisor_id'] as String?,
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
      'log_date': logDate.toIso8601String().split('T')[0], // Apenas a data
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'hours_logged': hoursLogged,
      'description': description,
      'approved': approved,
      'supervisor_id': supervisorId,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TimeLogEntity toEntity() {
    return TimeLogEntity(
      id: id,
      studentId: studentId,
      logDate: logDate,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      hoursLogged: hoursLogged,
      description: description,
      approved: approved,
      supervisorId: supervisorId,
      approvedAt: approvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeLogModel &&
        other.id == id &&
        other.studentId == studentId &&
        other.logDate == logDate &&
        other.checkInTime == checkInTime &&
        other.checkOutTime == checkOutTime &&
        other.hoursLogged == hoursLogged &&
        other.description == description &&
        other.approved == approved &&
        other.supervisorId == supervisorId &&
        other.approvedAt == approvedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        logDate.hashCode ^
        checkInTime.hashCode ^
        checkOutTime.hashCode ^
        hoursLogged.hashCode ^
        description.hashCode ^
        approved.hashCode ^
        supervisorId.hashCode ^
        approvedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'TimeLogModel(id: $id, studentId: $studentId, logDate: $logDate, checkInTime: $checkInTime, checkOutTime: $checkOutTime, hoursLogged: $hoursLogged, description: $description, approved: $approved, supervisorId: $supervisorId, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
