import 'package:dartz/dartz.dart';
import '../../core/errors/app_exceptions.dart';
import '../entities/time_log_entity.dart';

abstract class ITimeLogRepository {
  Future<Either<AppFailure, List<TimeLogEntity>>> getTimeLogsByStudent(String studentId);
  Future<Either<AppFailure, TimeLogEntity?>> getActiveTimeLog(String studentId);
  Future<Either<AppFailure, TimeLogEntity>> clockIn(String studentId,
      {String? description, String? notes});
  Future<Either<AppFailure, TimeLogEntity>> clockOut(String timeLogId, {String? notes});
  Future<Either<AppFailure, TimeLogEntity>> createTimeLog(TimeLogEntity timeLog);
  Future<Either<AppFailure, TimeLogEntity>> updateTimeLog(TimeLogEntity timeLog);
  Future<Either<AppFailure, void>> deleteTimeLog(String id);
  Future<Either<AppFailure, Map<String, dynamic>>> getTotalHoursByStudent(
      String studentId, DateTime startDate, DateTime endDate);
  Future<Either<AppFailure, Duration>> getTotalHoursByPeriod(
      String studentId, DateTime start, DateTime end);
}
