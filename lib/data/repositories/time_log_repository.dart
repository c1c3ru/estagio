// ignore_for_file: override_on_non_overriding_member

import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/repositories/i_time_log_repository.dart';
import '../../domain/entities/time_log_entity.dart';
import '../datasources/supabase/time_log_datasource.dart';
import '../models/time_log_model.dart';

class TimeLogRepository implements ITimeLogRepository {
  final TimeLogDatasource _timeLogDatasource;

  TimeLogRepository(this._timeLogDatasource);

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getAllTimeLogs() async {
    try {
      final timeLogsData = await _timeLogDatasource.getAllTimeLogs();
      final timeLogs = timeLogsData
          .map((data) => TimeLogModel.fromJson(data).toEntity())
          .toList();
      return Right(timeLogs);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar registros de horas: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> getTimeLogById(String id) async {
    try {
      final timeLogData = await _timeLogDatasource.getTimeLogById(id);
      if (timeLogData == null) {
        return Left(ServerFailure(message: 'Registro de horas não encontrado'));
      }
      final timeLog = TimeLogModel.fromJson(timeLogData).toEntity();
      return Right(timeLog);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar registro de horas: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getTimeLogsByStudent(String studentId) async {
    try {
      final timeLogsData =
          await _timeLogDatasource.getTimeLogsByStudent(studentId);
      final timeLogs = timeLogsData
          .map((data) => TimeLogModel.fromJson(data).toEntity())
          .toList();
      return Right(timeLogs);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar registros do estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getTimeLogsByDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final timeLogsData = await _timeLogDatasource.getTimeLogsByDateRange(
        studentId,
        startDate,
        endDate,
      );
      final timeLogs = timeLogsData
          .map((data) => TimeLogModel.fromJson(data).toEntity())
          .toList();
      return Right(timeLogs);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar registros por período: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity?>> getActiveTimeLog(String studentId) async {
    try {
      final timeLogData = await _timeLogDatasource.getActiveTimeLog(studentId);
      if (timeLogData == null) return const Right(null);
      final timeLog = TimeLogModel.fromJson(timeLogData).toEntity();
      return Right(timeLog);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar registro ativo: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> createTimeLog(TimeLogEntity timeLog) async {
    try {
      final timeLogModel = timeLog as TimeLogModel;
      final createdData =
          await _timeLogDatasource.createTimeLog(timeLogModel.toJson());
      final createdTimeLog = TimeLogModel.fromJson(createdData).toEntity();
      return Right(createdTimeLog);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao criar registro de horas: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> updateTimeLog(TimeLogEntity timeLog) async {
    try {
      final timeLogModel = timeLog as TimeLogModel;
      final updatedData = await _timeLogDatasource.updateTimeLog(
        timeLog.id,
        timeLogModel.toJson(),
      );
      final updatedTimeLog = TimeLogModel.fromJson(updatedData).toEntity();
      return Right(updatedTimeLog);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao atualizar registro de horas: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteTimeLog(String id) async {
    try {
      await _timeLogDatasource.deleteTimeLog(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao excluir registro de horas: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> clockIn(String studentId,
      {String? description, String? notes}) async {
    try {
      final timeLogData = await _timeLogDatasource.clockIn(studentId,
          notes: notes ?? description);
      final timeLog = TimeLogModel.fromJson(timeLogData).toEntity();
      return Right(timeLog);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao registrar entrada: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> clockOut(String studentId, {String? notes}) async {
    try {
      final timeLogData =
          await _timeLogDatasource.clockOut(studentId, notes: notes);
      final timeLog = TimeLogModel.fromJson(timeLogData).toEntity();
      return Right(timeLog);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao registrar saída: $e'));
    }
  }

  @override
  Future<Either<AppFailure, Duration>> getTotalHoursByPeriod(
      String studentId, DateTime start, DateTime end) async {
    try {
      final result = await _timeLogDatasource.getTotalHoursByPeriod(studentId, start, end);
      return Right(result);
    } catch (e) {
      return Left(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getTimeLogsBySupervisor(
      String supervisorId) async {
    try {
      final timeLogsData =
          await _timeLogDatasource.getTimeLogsBySupervisor(supervisorId);
      final timeLogs = timeLogsData
          .map((data) => TimeLogModel.fromJson(data).toEntity())
          .toList();
      return Right(timeLogs);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar registros do supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> updateTimeLogStatus({
    required String timeLogId,
    required bool approved,
    String? rejectionReason,
  }) async {
    try {
      // Primeiro, buscar o time log atual
      final currentTimeLogResult = await getTimeLogById(timeLogId);
      if (currentTimeLogResult.isLeft()) {
        return currentTimeLogResult;
      }

      final currentTimeLog = currentTimeLogResult.getOrElse(() => throw Exception('TimeLog not found'));
      
      // Atualizar o status
      final updatedTimeLog = currentTimeLog.copyWith(
        approved: approved,
        rejectionReason: rejectionReason,
        updatedAt: DateTime.now(),
      );

      final result = await _timeLogDatasource.updateTimeLog(updatedTimeLog);
      return Right(result);
    } catch (e) {
      return Left(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getPendingTimeLogsBySupervisor(String supervisorId) async {
    try {
      // Buscar todos os time logs pendentes para estudantes supervisionados por este supervisor
      // Esta implementação dependeria de como a relação supervisor-estudante é mantida
      // Por enquanto, vamos implementar uma versão básica
      final result = await _timeLogDatasource.getPendingTimeLogs();
      return Right(result);
    } catch (e) {
      return Left(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getTimeLogsByDateRange({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _timeLogDatasource.getTimeLogsByDateRange(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(AppFailure.unexpected(e.toString()));
    }
  }
}
