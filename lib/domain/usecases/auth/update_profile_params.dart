class UpdateProfileParams {
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
  });
}
