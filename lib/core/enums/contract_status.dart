enum ContractStatus {
  active,
  pendingApproval,
  expired,
  terminated,
  completed;

  String get displayName {
    switch (this) {
      case ContractStatus.active:
        return 'Ativo';
      case ContractStatus.pendingApproval:
        return 'Aguardando Aprovação';
      case ContractStatus.expired:
        return 'Expirado';
      case ContractStatus.terminated:
        return 'Encerrado';
      case ContractStatus.completed:
        return 'Concluído';
    }
  }

  String get value => name;

  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContractStatus.pendingApproval,
    );
  }
}
