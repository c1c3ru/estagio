import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';

class GetTimeLogsByStudentUsecase {
  final ITimeLogRepository _timeLogRepository;

  GetTimeLogsByStudentUsecase(this._timeLogRepository);

  Future<List<TimeLogEntity>> call(String studentId) async {
    try {
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      
      return await _timeLogRepository.getTimeLogsByStudent(studentId);
    } catch (e) {
      throw Exception('Erro ao buscar registros do estudante: $e');
    }
  }
}

