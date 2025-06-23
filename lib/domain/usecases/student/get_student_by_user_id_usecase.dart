import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';

class GetStudentByUserIdUsecase {
  final IStudentRepository _studentRepository;

  GetStudentByUserIdUsecase(this._studentRepository);

  Future<StudentEntity?> call(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('ID do usuário não pode estar vazio');
      }
      return await _studentRepository.getStudentByUserId(userId);
    } catch (e) {
      throw Exception('Erro ao buscar estudante por usuário: $e');
    }
  }
}

