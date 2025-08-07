import 'package:dartz/dartz.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_time_log_repository.dart';

class ClockOutUsecase {
  final ITimeLogRepository _repository;

  ClockOutUsecase(this._repository);

  Future<Either<AppFailure, Unit>> call({
    required String studentId,
    String? notes,
  }) async {
    try {
      final activeTimeLogResult = await _repository.getActiveTimeLog(studentId);

      return activeTimeLogResult.fold(
        (failure) => Left(failure),
        (activeTimeLog) async {
          if (activeTimeLog == null) {
            return const Left(
              ValidationFailure(
                  'Não há registro de ponto ativo para encerrar.'),
            );
          }

          final now = DateTime.now();
          final updatedTimeLog = activeTimeLog.copyWith(
            checkOutTime:
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            description: notes ?? activeTimeLog.description,
          );

          final updateResult = await _repository.updateTimeLog(updatedTimeLog);
          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(unit),
          );
        },
      );
    } on AppFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
          AppFailure(message: 'Erro ao registrar saída: ${e.toString()}'));
    }
  }
}
