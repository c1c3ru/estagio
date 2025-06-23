import '../../repositories/i_student_repository.dart';

class DeleteStudentUsecase {
  final IStudentRepository _studentRepository;

  DeleteStudentUsecase(this._studentRepository);

  Future<void> call(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      
      await _studentRepository.deleteStudent(id);
    } catch (e) {
      throw Exception('Erro ao excluir estudante: $e');
    }
  }
}

