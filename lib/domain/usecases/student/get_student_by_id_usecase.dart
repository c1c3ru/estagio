import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';

class GetStudentByIdUsecase {
  final IStudentRepository _studentRepository;

  GetStudentByIdUsecase(this._studentRepository);

  Future<StudentEntity?> call(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      return await _studentRepository.getStudentById(id);
    } catch (e) {
      throw Exception('Erro ao buscar estudante: $e');
    }
  }
}

