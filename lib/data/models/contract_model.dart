import '../../domain/entities/contract_entity.dart';
import '../../core/enums/contract_status.dart';

class ContractModel {
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

  ContractModel({
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
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      supervisorId: json['supervisor_id'] as String?,
      contractType: json['contract_type'] as String? ?? 'internship',
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      description: json['description'] as String?,
      documentUrl: json['document_url'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'student_id': studentId,
      'supervisor_id': supervisorId,
      'contract_type': contractType,
      'status': status,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
    
    if (id.isNotEmpty) json['id'] = id;
    if (description != null) json['description'] = description;
    if (documentUrl != null) json['document_url'] = documentUrl;
    if (createdBy != null) json['created_by'] = createdBy;
    if (updatedAt != null) json['updated_at'] = updatedAt!.toIso8601String();
    
    return json;
  }

  ContractEntity toEntity() {
    return ContractEntity(
      id: id,
      studentId: studentId,
      supervisorId: supervisorId,
      contractType: contractType,
      status: status,
      startDate: startDate,
      endDate: endDate,
      description: description,
      documentUrl: documentUrl,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ContractModel.fromEntity(ContractEntity entity) {
    return ContractModel(
      id: entity.id,
      studentId: entity.studentId,
      supervisorId: entity.supervisorId,
      contractType: entity.contractType,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
      documentUrl: entity.documentUrl,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ContractModel copyWith({
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
  }) {
    return ContractModel(
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
        other.contractType == contractType &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.description == description &&
        other.documentUrl == documentUrl &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        supervisorId.hashCode ^
        contractType.hashCode ^
        status.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        description.hashCode ^
        documentUrl.hashCode ^
        createdBy.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ContractModel(id: $id, studentId: $studentId, supervisorId: $supervisorId, contractType: $contractType, status: $status, startDate: $startDate, endDate: $endDate, description: $description, documentUrl: $documentUrl, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
