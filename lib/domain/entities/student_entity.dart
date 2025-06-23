import 'package:gestao_de_estagio/core/enums/class_shift.dart';
import 'package:gestao_de_estagio/core/enums/internship_shift.dart';
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/core/enums/student_status.dart';

import 'package:gestao_de_estagio/domain/entities/user_entity.dart';

class StudentEntity extends UserEntity {
  final String userId;
  final DateTime? birthDate;
  final String course;
  final String advisorName;
  final String registrationNumber;
  final bool isMandatoryInternship;
  final ClassShift classShift;
  final InternshipShift internshipShift;
  final String? supervisorId;
  final double totalHoursCompleted;
  final double totalHoursRequired;
  final double weeklyHoursTarget;
  final DateTime contractStartDate;
  final DateTime contractEndDate;
  final bool isOnTrack;
  final StudentStatus status;

  const StudentEntity({
    required super.id,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.profilePictureUrl,
    required super.role,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
    required this.userId,
    this.birthDate,
    required this.course,
    required this.advisorName,
    required this.registrationNumber,
    required this.isMandatoryInternship,
    required this.classShift,
    required this.internshipShift,
    this.supervisorId,
    required this.totalHoursCompleted,
    required this.totalHoursRequired,
    required this.weeklyHoursTarget,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.isOnTrack,
    required this.status,
  });

  double get progressPercentage {
    if (totalHoursRequired <= 0) return 0;
    return (totalHoursCompleted / totalHoursRequired) * 100;
  }

  double get remainingHours {
    final remaining = totalHoursRequired - totalHoursCompleted;
    return remaining > 0 ? remaining : 0;
  }

  bool get hasValidBirthDate => birthDate != null;

  int get age {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  StudentEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    DateTime? birthDate,
    String? course,
    String? advisorName,
    String? registrationNumber,
    bool? isMandatoryInternship,
    ClassShift? classShift,
    InternshipShift? internshipShift,
    String? supervisorId,
    double? totalHoursCompleted,
    double? totalHoursRequired,
    double? weeklyHoursTarget,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    bool? isOnTrack,
    StudentStatus? status,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      birthDate: birthDate ?? this.birthDate,
      course: course ?? this.course,
      advisorName: advisorName ?? this.advisorName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isMandatoryInternship:
          isMandatoryInternship ?? this.isMandatoryInternship,
      classShift: classShift ?? this.classShift,
      internshipShift: internshipShift ?? this.internshipShift,
      supervisorId: supervisorId ?? this.supervisorId,
      totalHoursCompleted: totalHoursCompleted ?? this.totalHoursCompleted,
      totalHoursRequired: totalHoursRequired ?? this.totalHoursRequired,
      weeklyHoursTarget: weeklyHoursTarget ?? this.weeklyHoursTarget,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      isOnTrack: isOnTrack ?? this.isOnTrack,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        userId,
        birthDate,
        course,
        advisorName,
        registrationNumber,
        isMandatoryInternship,
        classShift,
        internshipShift,
        supervisorId,
        totalHoursCompleted,
        totalHoursRequired,
        weeklyHoursTarget,
        contractStartDate,
        contractEndDate,
        isOnTrack,
        status,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentEntity &&
        super == other &&
        other.userId == userId &&
        other.birthDate == birthDate &&
        other.course == course &&
        other.advisorName == advisorName &&
        other.registrationNumber == registrationNumber &&
        other.isMandatoryInternship == isMandatoryInternship &&
        other.classShift == classShift &&
        other.internshipShift == internshipShift &&
        other.supervisorId == supervisorId &&
        other.totalHoursCompleted == totalHoursCompleted &&
        other.totalHoursRequired == totalHoursRequired &&
        other.weeklyHoursTarget == weeklyHoursTarget &&
        other.contractStartDate == contractStartDate &&
        other.contractEndDate == contractEndDate &&
        other.isOnTrack == isOnTrack &&
        other.status == status;
  }

  @override
  int get hashCode {
    return super.hashCode ^
        userId.hashCode ^
        birthDate.hashCode ^
        course.hashCode ^
        advisorName.hashCode ^
        registrationNumber.hashCode ^
        isMandatoryInternship.hashCode ^
        classShift.hashCode ^
        internshipShift.hashCode ^
        supervisorId.hashCode ^
        totalHoursCompleted.hashCode ^
        totalHoursRequired.hashCode ^
        weeklyHoursTarget.hashCode ^
        contractStartDate.hashCode ^
        contractEndDate.hashCode ^
        isOnTrack.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'StudentEntity(id: $id, email: $email, fullName: $fullName, userId: $userId, course: $course, registrationNumber: $registrationNumber, status: $status)';
  }
}
