enum UserRole {
  student('student', 'Estudante'),
  supervisor('supervisor', 'Supervisor');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }

  @override
  String toString() => value;
}

