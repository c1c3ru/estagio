import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';

class GetActiveTimeLogUsecase {
  final ITimeLogRepository _timeLogRepository;

  GetActiveTimeLogUsecase(this._timeLogRepository);

  Future<TimeLogEntity?> call(String studentId) async {
    try {
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      
      return await _timeLogRepository.getActiveTimeLog(studentId);
    } catch (e) {
      throw Exception('Erro ao buscar registro ativo: $e');
    }
  }
}

