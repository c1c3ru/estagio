enum ClassShift {
  morning,
  afternoon,
  evening,
  fullTime,
  ead;

  String get displayName {
    switch (this) {
      case ClassShift.morning:
        return 'Manhã';
      case ClassShift.afternoon:
        return 'Tarde';
      case ClassShift.evening:
        return 'Noite';
      case ClassShift.fullTime:
        return 'Integral';
      case ClassShift.ead:
        return 'EAD';
    }
  }

  String get value {
    switch (this) {
      case ClassShift.fullTime:
        return 'full_time';
      default:
        return name;
    }
  }

  static ClassShift fromString(String value) {
    return ClassShift.values.firstWhere(
      (shift) => shift.value == value,
      orElse: () => ClassShift.morning,
    );
  }
}
