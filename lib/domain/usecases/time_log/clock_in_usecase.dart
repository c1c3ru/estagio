import 'package:dartz/dartz.dart';
import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class ClockInUsecase {
  final ITimeLogRepository _timeLogRepository;

  ClockInUsecase(this._timeLogRepository);

  Future<Either<AppFailure, TimeLogEntity>> call(String studentId,
      {String? notes}) async {
    try {
      if (studentId.isEmpty) {
        return const Left(
            ValidationFailure('ID do estudante não pode estar vazio'));
      }

      // Verificar se já existe um registro ativo
      final activeLogResult =
          await _timeLogRepository.getActiveTimeLog(studentId);
      return activeLogResult.fold(
        (failure) => Left(failure),
        (activeLog) {
          if (activeLog != null) {
            return const Left(ValidationFailure(
                'Já existe um registro de entrada ativo. Registre a saída primeiro.'));
          }
          return _timeLogRepository.clockIn(studentId, notes: notes);
        },
      );
    } catch (e) {
      return Left(AppFailure.unexpected('Erro ao registrar entrada: $e'));
    }
  }
}
