import '../../domain/entities/student_entity.dart';
import '../../core/enums/class_shift.dart';
import '../../core/enums/internship_shift.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/student_status.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.profilePictureUrl,
    required super.role,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
    required super.userId,
    super.birthDate,
    required super.course,
    required super.advisorName,
    required super.registrationNumber,
    required super.isMandatoryInternship,
    required super.classShift,
    required super.internshipShift,
    super.supervisorId,
    required super.totalHoursCompleted,
    required super.totalHoursRequired,
    required super.weeklyHoursTarget,
    required super.contractStartDate,
    required super.contractEndDate,
    required super.isOnTrack,
    required super.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final userData = json['users'] as Map<String, dynamic>? ?? json;

    return StudentModel(
      id: json['id'] as String,
      email: userData['email'] as String? ?? '',
      fullName: userData['full_name'] as String? ?? '',
      phoneNumber: userData['phone_number'] as String?,
      profilePictureUrl: userData['profile_picture_url'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == (userData['role'] as String? ?? 'student'),
        orElse: () => UserRole.student,
      ),
      isActive: userData['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(userData['created_at'] as String),
      updatedAt: userData['updated_at'] != null
          ? DateTime.parse(userData['updated_at'] as String)
          : null,
      userId: json['user_id'] as String? ?? json['id'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      course: json['course'] as String? ?? '',
      advisorName: json['advisor_name'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      isMandatoryInternship: json['is_mandatory_internship'] as bool? ?? false,
      classShift: ClassShift.values.firstWhere(
        (e) => e.name == json['class_shift'],
        orElse: () => ClassShift.morning,
      ),
      internshipShift: InternshipShift.values.firstWhere(
        (e) => e.name == json['internship_shift'],
        orElse: () => InternshipShift.morning,
      ),
      supervisorId: json['supervisor_id'] as String?,
      totalHoursCompleted:
          (json['total_hours_completed'] as num?)?.toDouble() ?? 0.0,
      totalHoursRequired:
          (json['total_hours_required'] as num?)?.toDouble() ?? 0.0,
      weeklyHoursTarget:
          (json['weekly_hours_target'] as num?)?.toDouble() ?? 0.0,
      contractStartDate: DateTime.parse(json['contract_start_date'] as String),
      contractEndDate: DateTime.parse(json['contract_end_date'] as String),
      isOnTrack: json['is_on_track'] as bool? ?? true,
      status: StudentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StudentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'role': role.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'birth_date': birthDate?.toIso8601String(),
      'course': course,
      'advisor_name': advisorName,
      'registration_number': registrationNumber,
      'is_mandatory_internship': isMandatoryInternship,
      'class_shift': classShift.name,
      'internship_shift': internshipShift.name,
      'supervisor_id': supervisorId,
      'total_hours_completed': totalHoursCompleted,
      'total_hours_required': totalHoursRequired,
      'weekly_hours_target': weeklyHoursTarget,
      'contract_start_date': contractStartDate.toIso8601String(),
      'contract_end_date': contractEndDate.toIso8601String(),
      'is_on_track': isOnTrack,
      'status': status.name,
    };
  }

  StudentEntity toEntity() => this;

  factory StudentModel.fromEntity(StudentEntity entity) {
    return StudentModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      profilePictureUrl: entity.profilePictureUrl,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
      birthDate: entity.birthDate,
      course: entity.course,
      advisorName: entity.advisorName,
      registrationNumber: entity.registrationNumber,
      isMandatoryInternship: entity.isMandatoryInternship,
      classShift: entity.classShift,
      internshipShift: entity.internshipShift,
      supervisorId: entity.supervisorId,
      totalHoursCompleted: entity.totalHoursCompleted,
      totalHoursRequired: entity.totalHoursRequired,
      weeklyHoursTarget: entity.weeklyHoursTarget,
      contractStartDate: entity.contractStartDate,
      contractEndDate: entity.contractEndDate,
      isOnTrack: entity.isOnTrack,
      status: entity.status,
    );
  }
}
