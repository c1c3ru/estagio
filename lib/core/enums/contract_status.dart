enum ContractStatus {
  active,
  completed,
  inactive,
  cancelled,
  pending,
  expired,
  terminated,
  pendingApproval,
  unknown;

  String get displayName {
    switch (this) {
      case ContractStatus.active:
        return 'Ativo';
      case ContractStatus.completed:
        return 'Concluído';
      case ContractStatus.inactive:
        return 'Inativo';
      case ContractStatus.cancelled:
        return 'Cancelado';
      case ContractStatus.pending:
        return 'Pendente';
      case ContractStatus.expired:
        return 'Expirado';
      case ContractStatus.terminated:
        return 'Encerrado';
      case ContractStatus.pendingApproval:
        return 'Aguardando Aprovação';
      case ContractStatus.unknown:
        return 'Desconhecido';
    }
  }

  String get value => name;

  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContractStatus.pending,
    );
  }
}
