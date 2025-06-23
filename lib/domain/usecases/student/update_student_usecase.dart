import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';

class UpdateStudentUsecase {
  final IStudentRepository _studentRepository;

  UpdateStudentUsecase(this._studentRepository);

  Future<StudentEntity> call(StudentEntity student) async {
    try {
      // Validações
      if (student.id.isEmpty) {
        throw Exception('ID do estudante é obrigatório');
      }

      if (student.registrationNumber.isEmpty) {
        throw Exception('Matrícula é obrigatória');
      }

      if (student.course.isEmpty) {
        throw Exception('Curso é obrigatório');
      }

      if (student.fullName.isEmpty) {
        throw Exception('Nome completo é obrigatório');
      }

      return await _studentRepository.updateStudent(student);
    } catch (e) {
      throw Exception('Erro ao atualizar estudante: $e');
    }
  }
}
