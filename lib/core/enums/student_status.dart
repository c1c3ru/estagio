enum StudentStatus {
  active,
  inactive,
  pending,
  completed,
  terminated;

  String get displayName {
    switch (this) {
      case StudentStatus.active:
        return 'Ativo';
      case StudentStatus.inactive:
        return 'Inativo';
      case StudentStatus.pending:
        return 'Pendente';
      case StudentStatus.completed:
        return 'Concluído';
      case StudentStatus.terminated:
        return 'Encerrado';
    }
  }
}
