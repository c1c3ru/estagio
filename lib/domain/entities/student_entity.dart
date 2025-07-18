import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
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

  const StudentEntity({
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

  @override
  List<Object?> get props => [
        id,
        fullName,
        registrationNumber,
        course,
        advisorName,
        isMandatoryInternship,
        classShift,
        internshipShift1,
        internshipShift2,
        birthDate,
        contractStartDate,
        contractEndDate,
        totalHoursRequired,
        totalHoursCompleted,
        weeklyHoursTarget,
        profilePictureUrl,
        phoneNumber,
        createdAt,
        updatedAt,
        status,
        supervisorId,
      ];

  StudentEntity copyWith({
    String? id,
    String? fullName,
    String? registrationNumber,
    String? course,
    String? advisorName,
    bool? isMandatoryInternship,
    String? classShift,
    String? internshipShift1,
    String? internshipShift2,
    DateTime? birthDate,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    double? totalHoursRequired,
    double? totalHoursCompleted,
    double? weeklyHoursTarget,
    String? profilePictureUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? supervisorId,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      course: course ?? this.course,
      advisorName: advisorName ?? this.advisorName,
      isMandatoryInternship:
          isMandatoryInternship ?? this.isMandatoryInternship,
      classShift: classShift ?? this.classShift,
      internshipShift1: internshipShift1 ?? this.internshipShift1,
      internshipShift2: internshipShift2 ?? this.internshipShift2,
      birthDate: birthDate ?? this.birthDate,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      totalHoursRequired: totalHoursRequired ?? this.totalHoursRequired,
      totalHoursCompleted: totalHoursCompleted ?? this.totalHoursCompleted,
      weeklyHoursTarget: weeklyHoursTarget ?? this.weeklyHoursTarget,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      supervisorId: supervisorId ?? this.supervisorId,
    );
  }

  @override
  String toString() {
    return 'StudentEntity(id: $id, fullName: $fullName, registrationNumber: $registrationNumber, course: $course, advisorName: $advisorName, isMandatoryInternship: $isMandatoryInternship, classShift: $classShift, internshipShift1: $internshipShift1, internshipShift2: $internshipShift2, birthDate: $birthDate, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, totalHoursRequired: $totalHoursRequired, totalHoursCompleted: $totalHoursCompleted, weeklyHoursTarget: $weeklyHoursTarget, profilePictureUrl: $profilePictureUrl, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, supervisorId: $supervisorId)';
  }
}
