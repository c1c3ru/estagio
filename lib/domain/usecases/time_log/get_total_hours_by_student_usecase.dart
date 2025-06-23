import '../../repositories/i_time_log_repository.dart';

class GetTotalHoursByStudentUsecase {
  final ITimeLogRepository _timeLogRepository;

  GetTotalHoursByStudentUsecase(this._timeLogRepository);

  Future<Map<String, dynamic>> call(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      
      if (startDate.isAfter(endDate)) {
        throw Exception('Data de início deve ser anterior à data de fim');
      }
      
      return await _timeLogRepository.getTotalHoursByStudent(
        studentId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Erro ao calcular horas totais: $e');
    }
  }
}

