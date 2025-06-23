// lib/domain/usecases/student/update_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_student_repository.dart';

class UpdateTimeLogUsecase {
  final IStudentRepository _repository;

  UpdateTimeLogUsecase(this._repository);

  Future<Either<AppFailure, TimeLogEntity>> call(TimeLogEntity timeLog) async {
    // Validações no objeto timeLog podem ser feitas aqui.
    // Por exemplo, verificar se o ID não está vazio.
    if (timeLog.id.isEmpty) {
      return const Left(
          ValidationFailure('O ID do registo de tempo não pode estar vazio.'));
    }
    if (timeLog.checkOutTime != null) {
      final checkInDateTime = DateTime(
          timeLog.logDate.year,
          timeLog.logDate.month,
          timeLog.logDate.day,
          timeLog.checkInTime.hour,
          timeLog.checkInTime.minute);
      final checkOutDateTime = DateTime(
          timeLog.logDate.year,
          timeLog.logDate.month,
          timeLog.logDate.day,
          timeLog.checkOutTime!.hour,
          timeLog.checkOutTime!.minute);
      if (checkOutDateTime.isBefore(checkInDateTime)) {
        return const Left(ValidationFailure(
            'A hora de saída deve ser posterior à hora de entrada.'));
      }
    }
    return await _repository.updateTimeLog(timeLog);
  }
}
