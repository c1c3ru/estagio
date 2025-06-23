enum ClassShift {
  morning,
  afternoon,
  night;

  String get displayName {
    switch (this) {
      case ClassShift.morning:
        return 'Manhã';
      case ClassShift.afternoon:
        return 'Tarde';
      case ClassShift.night:
        return 'Noite';
    }
  }
}
