import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';

class ClockOutUsecase {
  final ITimeLogRepository _timeLogRepository;

  ClockOutUsecase(this._timeLogRepository);

  Future<TimeLogEntity> call(String studentId, {String? notes}) async {
    try {
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }

      // Verificar se existe um registro ativo
      final activeLog = await _timeLogRepository.getActiveTimeLog(studentId);
      if (activeLog == null) {
        throw Exception('Nenhum registro de entrada ativo encontrado. Registre a entrada primeiro.');
      }

      return await _timeLogRepository.clockOut(studentId, notes: notes);
    } catch (e) {
      throw Exception('Erro ao registrar saída: $e');
    }
  }
}

