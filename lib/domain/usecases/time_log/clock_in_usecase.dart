import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';

class ClockInUsecase {
  final ITimeLogRepository _timeLogRepository;

  ClockInUsecase(this._timeLogRepository);

  Future<TimeLogEntity> call(String studentId, {String? notes}) async {
    try {
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }

      // Verificar se já existe um registro ativo
      final activeLog = await _timeLogRepository.getActiveTimeLog(studentId);
      if (activeLog != null) {
        throw Exception('Já existe um registro de entrada ativo. Registre a saída primeiro.');
      }

      return await _timeLogRepository.clockIn(studentId, notes: notes);
    } catch (e) {
      throw Exception('Erro ao registrar entrada: $e');
    }
  }
}

