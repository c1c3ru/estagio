import 'package:gestao_de_estagio/core/enums/user_role.dart';

abstract class IAuthDatasource {
  Stream<Map<String, dynamic>?> getAuthStateChanges();

  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
    bool? isMandatoryInternship,
    String? supervisorId,
    String? course,
    String? advisorName,
    String? classShift,
    String? internshipShift,
    String? birthDate,
    String? contractStartDate,
    String? contractEndDate,
  });

  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<void> signOut();

  Future<Map<String, dynamic>?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profilePictureUrl,
  });
}
