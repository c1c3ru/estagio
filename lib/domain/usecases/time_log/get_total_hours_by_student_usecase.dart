import 'package:dartz/dartz.dart';
import '../../repositories/i_time_log_repository.dart';
import '../../../core/errors/app_exceptions.dart';

class GetTotalHoursByStudentUsecase {
  final ITimeLogRepository _timeLogRepository;

  GetTotalHoursByStudentUsecase(this._timeLogRepository);

  Future<Either<AppFailure, Map<String, dynamic>>> call(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (studentId.isEmpty) {
        return const Left(
            ValidationFailure('ID do estudante não pode estar vazio'));
      }

      if (startDate.isAfter(endDate)) {
        return const Left(ValidationFailure(
            'Data de início deve ser anterior à data de fim'));
      }

      return await _timeLogRepository.getTotalHoursByStudent(
        studentId,
        startDate,
        endDate,
      );
    } catch (e) {
      return Left(AppFailure.unexpected('Erro ao calcular horas totais: $e'));
    }
  }
}
