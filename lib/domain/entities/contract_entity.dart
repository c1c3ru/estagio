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
    );
  }

  @override
  String toString() {
    return 'ContractEntity(id: $id, studentId: $studentId, supervisorId: $supervisorId, contractType: $contractType, status: $status, startDate: $startDate, endDate: $endDate, description: $description, documentUrl: $documentUrl, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
