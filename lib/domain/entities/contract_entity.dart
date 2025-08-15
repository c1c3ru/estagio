import 'package:equatable/equatable.dart';

class ContractEntity extends Equatable {
  final String id;
  final String studentId;
  final String? supervisorId;
  final String contractType;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final String? documentUrl;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool receivesScholarship;

  const ContractEntity({
    required this.id,
    required this.studentId,
    this.supervisorId,
    required this.contractType,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.description,
    this.documentUrl,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.receivesScholarship = false,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        supervisorId,
        contractType,
        status,
        startDate,
        endDate,
        description,
        documentUrl,
        createdBy,
        createdAt,
        updatedAt,
        receivesScholarship,
      ];

  ContractEntity copyWith({
    String? id,
    String? studentId,
    String? supervisorId,
    String? contractType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? documentUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? receivesScholarship,
  }) {
    return ContractEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      contractType: contractType ?? this.contractType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      documentUrl: documentUrl ?? this.documentUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receivesScholarship: receivesScholarship ?? this.receivesScholarship,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'supervisor_id': supervisorId,
      'contract_type': contractType,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'description': description,
      'document_url': documentUrl,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'receives_scholarship': receivesScholarship,
    };
  }
}
