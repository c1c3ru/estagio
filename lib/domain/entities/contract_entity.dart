import 'package:equatable/equatable.dart';
import '../../core/enums/contract_status.dart';

class ContractEntity extends Equatable {
  final String id;
  final String studentId;
  final String supervisorId;
  final String company;
  final String position;
  final String? description;
  final double? salary;
  final DateTime startDate;
  final DateTime endDate;
  final double totalHoursRequired;
  final double weeklyHoursTarget;
  final ContractStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? _contractType;
  final String? _documentUrl;

  const ContractEntity({
    required this.id,
    required this.studentId,
    required this.supervisorId,
    required this.company,
    required this.position,
    this.description,
    this.salary,
    required this.startDate,
    required this.endDate,
    required this.totalHoursRequired,
    required this.weeklyHoursTarget,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    String? contractType,
    String? documentUrl,
  })  : _contractType = contractType,
        _documentUrl = documentUrl;

  String? get contractType => _contractType;
  String? get documentUrl => _documentUrl;

  @override
  List<Object?> get props => [
        id,
        studentId,
        supervisorId,
        company,
        position,
        description,
        salary,
        startDate,
        endDate,
        totalHoursRequired,
        weeklyHoursTarget,
        status,
        createdAt,
        updatedAt,
        _contractType,
        _documentUrl,
      ];

  ContractEntity copyWith({
    String? id,
    String? studentId,
    String? supervisorId,
    String? company,
    String? position,
    String? description,
    double? salary,
    DateTime? startDate,
    DateTime? endDate,
    double? totalHoursRequired,
    double? weeklyHoursTarget,
    ContractStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contractType,
    String? documentUrl,
  }) {
    return ContractEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalHoursRequired: totalHoursRequired ?? this.totalHoursRequired,
      weeklyHoursTarget: weeklyHoursTarget ?? this.weeklyHoursTarget,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contractType: contractType ?? _contractType,
      documentUrl: documentUrl ?? _documentUrl,
    );
  }

  bool get isActive => status == ContractStatus.active;

  Duration get totalDuration => endDate.difference(startDate);

  int get totalExpectedHours {
    final weeks = totalDuration.inDays / 7;
    return (weeks * weeklyHoursTarget).round();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContractEntity &&
        other.id == id &&
        other.studentId == studentId &&
        other.supervisorId == supervisorId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other._contractType == _contractType &&
        other._documentUrl == _documentUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        supervisorId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        _contractType.hashCode ^
        _documentUrl.hashCode;
  }

  @override
  String toString() {
    return 'ContractEntity(id: $id, studentId: $studentId, supervisorId: $supervisorId, company: $company, position: $position, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, contractType: $_contractType, documentUrl: $_documentUrl)';
  }
}
