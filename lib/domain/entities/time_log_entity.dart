import 'package:equatable/equatable.dart';

class TimeLogEntity extends Equatable {
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

  const TimeLogEntity({
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

  factory TimeLogEntity.fromJson(Map<String, dynamic> json) {
    return TimeLogEntity(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      checkInTime: json['check_in_time'] as String,
      checkOutTime: json['check_out_time'] as String?,
      hoursLogged:
          json['hours_logged'] != null ? json['hours_logged'] as double? : null,
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

  @override
  List<Object?> get props => [
        id,
        studentId,
        logDate,
        checkInTime,
        checkOutTime,
        hoursLogged,
        description,
        approved,
        supervisorId,
        approvedAt,
        createdAt,
        updatedAt,
      ];

  TimeLogEntity copyWith({
    String? id,
    String? studentId,
    DateTime? logDate,
    String? checkInTime,
    String? checkOutTime,
    double? hoursLogged,
    String? description,
    bool? approved,
    String? supervisorId,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeLogEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      logDate: logDate ?? this.logDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      hoursLogged: hoursLogged ?? this.hoursLogged,
      description: description ?? this.description,
      approved: approved ?? this.approved,
      supervisorId: supervisorId ?? this.supervisorId,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TimeLogEntity(id: $id, studentId: $studentId, logDate: $logDate, checkInTime: $checkInTime, checkOutTime: $checkOutTime, hoursLogged: $hoursLogged, description: $description, approved: $approved, supervisorId: $supervisorId, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
