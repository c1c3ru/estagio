import '../entities/time_log_entity.dart';

abstract class ITimeLogRepository {
  Future<List<TimeLogEntity>> getTimeLogsByStudent(String studentId);
  Future<TimeLogEntity?> getActiveTimeLog(String studentId);
  Future<TimeLogEntity> clockIn(String studentId,
      {String? description, String? notes});
  Future<TimeLogEntity> clockOut(String timeLogId, {String? notes});
  Future<TimeLogEntity> createTimeLog(TimeLogEntity timeLog);
  Future<TimeLogEntity> updateTimeLog(TimeLogEntity timeLog);
  Future<void> deleteTimeLog(String id);
  Future<Map<String, dynamic>> getTotalHoursByStudent(
      String studentId, DateTime startDate, DateTime endDate);
  Future<Duration> getTotalHoursByPeriod(
      String studentId, DateTime start, DateTime end);
}
