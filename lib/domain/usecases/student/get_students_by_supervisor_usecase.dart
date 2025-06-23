import '../../repositories/i_student_repository.dart';
import '../../entities/student_entity.dart';

class GetStudentsBySupervisorUsecase {
  final IStudentRepository _studentRepository;

  GetStudentsBySupervisorUsecase(this._studentRepository);

  Future<List<StudentEntity>> call(String supervisorId) async {
    try {
      if (supervisorId.isEmpty) {
        throw Exception('ID do supervisor não pode estar vazio');
      }
      
      return await _studentRepository.getStudentsBySupervisor(supervisorId);
    } catch (e) {
      throw Exception('Erro ao buscar estudantes do supervisor: $e');
    }
  }
}

