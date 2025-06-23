import 'package:equatable/equatable.dart';
import 'package:gestao_de_estagio/core/enums/student_status.dart';

class FilterStudentsParams extends Equatable {
  final String? searchTerm;
  final StudentStatus? status;
  final bool? hasActiveContract;
  final DateTime? contractStartDateFrom;
  final DateTime? contractStartDateTo;
  final DateTime? contractEndDateFrom;
  final DateTime? contractEndDateTo;

  const FilterStudentsParams({
    this.searchTerm,
    this.status,
    this.hasActiveContract,
    this.contractStartDateFrom,
    this.contractStartDateTo,
    this.contractEndDateFrom,
    this.contractEndDateTo,
  });

  @override
  List<Object?> get props => [
        searchTerm,
        status,
        hasActiveContract,
        contractStartDateFrom,
        contractStartDateTo,
        contractEndDateFrom,
        contractEndDateTo,
      ];
}
