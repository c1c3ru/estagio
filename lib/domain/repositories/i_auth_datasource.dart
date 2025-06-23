import 'package:gestao_de_estagio/core/enums/user_role.dart';

abstract class IAuthDatasource {
  Future<Map<String, dynamic>?> signInWithEmailAndPassword(
      String email, String password);

  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
  });

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

  Stream<Map<String, dynamic>?> getAuthStateChanges();
}
