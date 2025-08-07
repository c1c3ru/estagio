import 'package:dartz/dartz.dart';
import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class GetActiveTimeLogUsecase {
  final ITimeLogRepository _timeLogRepository;

  GetActiveTimeLogUsecase(this._timeLogRepository);

  Future<Either<AppFailure, TimeLogEntity?>> call(String studentId) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('ID do estudante não pode estar vazio'));
    }
    return await _timeLogRepository.getActiveTimeLog(studentId);
  }
}
