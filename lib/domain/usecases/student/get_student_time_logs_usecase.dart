// lib/domain/usecases/student/get_student_time_logs_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_student_repository.dart';

class GetStudentTimeLogsUsecase {
  final IStudentRepository _repository;

  GetStudentTimeLogsUsecase(this._repository);

  Future<Either<AppFailure, List<TimeLogEntity>>> call({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (studentId.isEmpty) {
      return const Left(
          ValidationFailure('O ID do estudante não pode estar vazio.'));
    }
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return const Left(ValidationFailure(
          'A data de início não pode ser posterior à data de fim.'));
    }
    return await _repository.getStudentTimeLogs(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
