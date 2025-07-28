import 'package:dartz/dartz.dart';
import '../../repositories/i_time_log_repository.dart';
import '../../entities/time_log_entity.dart';
import '../../../core/errors/app_exceptions.dart';

class GetTimeLogsByStudentUsecase {
  final ITimeLogRepository _timeLogRepository;

  GetTimeLogsByStudentUsecase(this._timeLogRepository);

  Future<Either<AppFailure, List<TimeLogEntity>>> call(String studentId) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('ID do estudante não pode estar vazio'));
    }
    return await _timeLogRepository.getTimeLogsByStudent(studentId);
  }
}
