import '../../domain/entities/student_entity.dart';

class StudentModel {
  final String id;
  final String fullName;
  final String registrationNumber;
  final String course;
  final String advisorName;
  final bool isMandatoryInternship;
  final String classShift;
  final String internshipShift1;
  final String? internshipShift2;
  final DateTime birthDate;
  final DateTime contractStartDate;
  final DateTime contractEndDate;
  final double totalHoursRequired;
  final double totalHoursCompleted;
  final double weeklyHoursTarget;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? status;
  final String? supervisorId;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.registrationNumber,
    required this.course,
    required this.advisorName,
    required this.isMandatoryInternship,
    required this.classShift,
    required this.internshipShift1,
    this.internshipShift2,
    required this.birthDate,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.totalHoursRequired,
    required this.totalHoursCompleted,
    required this.weeklyHoursTarget,
    this.profilePictureUrl,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
    this.status,
    this.supervisorId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      registrationNumber: json['registration_number'] as String,
      course: json['course'] as String,
      advisorName: json['advisor_name'] as String,
      isMandatoryInternship: json['is_mandatory_internship'] as bool,
      classShift: json['class_shift'] as String,
      internshipShift1: json['internship_shift_1'] as String,
      internshipShift2: json['internship_shift_2'] as String?,
      birthDate: DateTime.parse(json['birth_date'] as String),
      contractStartDate: DateTime.parse(json['contract_start_date'] as String),
      contractEndDate: DateTime.parse(json['contract_end_date'] as String),
      totalHoursRequired:
          (json['total_hours_required'] as num?)?.toDouble() ?? 0.0,
      totalHoursCompleted:
          (json['total_hours_completed'] as num?)?.toDouble() ?? 0.0,
      weeklyHoursTarget:
          (json['weekly_hours_target'] as num?)?.toDouble() ?? 0.0,
      profilePictureUrl: json['profile_picture_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      status: json['status'] as String?,
      supervisorId: json['supervisor_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'registration_number': registrationNumber,
      'course': course,
      'advisor_name': advisorName,
      'is_mandatory_internship': isMandatoryInternship,
      'class_shift': classShift,
      'internship_shift_1': internshipShift1,
      'internship_shift_2': internshipShift2,
      'birth_date': birthDate.toIso8601String(),
      'contract_start_date': contractStartDate.toIso8601String(),
      'contract_end_date': contractEndDate.toIso8601String(),
      'total_hours_required': totalHoursRequired,
      'total_hours_completed': totalHoursCompleted,
      'weekly_hours_target': weeklyHoursTarget,
      'profile_picture_url': profilePictureUrl,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
      'supervisor_id': supervisorId,
    };
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      fullName: fullName,
      registrationNumber: registrationNumber,
      course: course,
      advisorName: advisorName,
      isMandatoryInternship: isMandatoryInternship,
      classShift: classShift,
      internshipShift1: internshipShift1,
      internshipShift2: internshipShift2,
      birthDate: birthDate,
      contractStartDate: contractStartDate,
      contractEndDate: contractEndDate,
      totalHoursRequired: totalHoursRequired,
      totalHoursCompleted: totalHoursCompleted,
      weeklyHoursTarget: weeklyHoursTarget,
      profilePictureUrl: profilePictureUrl,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      supervisorId: supervisorId,
    );
  }
}
