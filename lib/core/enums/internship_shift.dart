enum InternshipShift {
  morning('morning', 'Manhã'),
  afternoon('afternoon', 'Tarde'),
  evening('evening', 'Noite');

  const InternshipShift(this.value, this.displayName);

  final String value;
  final String displayName;

  static InternshipShift fromString(String value) {
    return InternshipShift.values.firstWhere(
      (shift) => shift.value == value,
      orElse: () => InternshipShift.morning,
    );
  }

  @override
  String toString() => value;
}
