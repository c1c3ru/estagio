import '../../domain/repositories/i_student_repository.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/time_log_entity.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../datasources/supabase/student_datasource.dart';
import '../datasources/supabase/time_log_datasource.dart';
import '../models/student_model.dart';
import '../models/time_log_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class StudentRepository implements IStudentRepository {
  final StudentDatasource _studentDatasource;
  final TimeLogDatasource _timeLogDatasource;

  StudentRepository(this._studentDatasource, this._timeLogDatasource);

  @override
  Future<Either<AppFailure, List<StudentEntity>>> getAllStudents() async {
    try {
      final studentsData = await _studentDatasource.getAllStudents();
      final students = studentsData
          .map((data) => StudentModel.fromJson(data).toEntity())
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar estudantes: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity?>> getStudentById(String id) async {
    try {
      final studentData = await _studentDatasource.getStudentById(id);
      if (studentData == null) return const Right(null);
      return Right(StudentModel.fromJson(studentData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity?>> getStudentByUserId(String userId) async {
    try {
      final studentData = await _studentDatasource.getStudentByUserId(userId);
      if (studentData == null) return const Right(null);
      return Right(StudentModel.fromJson(studentData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar estudante por usuário: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> createStudent(StudentEntity student) async {
    try {
      final studentModel = student as StudentModel;
      final createdData =
          await _studentDatasource.createStudent(studentModel.toJson());
      return Right(StudentModel.fromJson(createdData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao criar estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> updateStudent(StudentEntity student) async {
    try {
      final studentModel = student as StudentModel;
      final updatedData = await _studentDatasource.updateStudent(
        student.id,
        studentModel.toJson(),
      );
      return Right(StudentModel.fromJson(updatedData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao atualizar estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteStudent(String id) async {
    try {
      await _studentDatasource.deleteStudent(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao excluir estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<StudentEntity>>> getStudentsBySupervisor(
      String supervisorId) async {
    try {
      final studentsData =
          await _studentDatasource.getStudentsBySupervisor(supervisorId);
      final students = studentsData
          .map((data) => StudentModel.fromJson(data).toEntity())
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar estudantes do supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> checkIn(
      {required String studentId, String? notes}) async {
    try {
      final now = DateTime.now();
      final timeLogData = {
        'student_id': studentId,
        'log_date': now.toIso8601String().split('T')[0],
        'check_in_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'description': notes,
        'approved': false,
        'created_at': now.toIso8601String(),
      };
      
      final createdData = await _timeLogDatasource.createTimeLog(timeLogData);
      AppLogger.repository('Check-in realizado com sucesso para estudante: $studentId');
      return Right(TimeLogModel.fromJson(createdData).toEntity());
    } catch (e) {
      AppLogger.error('Erro ao realizar check-in', error: e);
      return Left(ServerFailure(message: 'Erro ao realizar check-in: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> checkOut(
      {required String studentId,
      required String activeTimeLogId,
      String? description}) async {
    try {
      final now = DateTime.now();
      final timeLogData = {
        'id': activeTimeLogId,
        'check_out_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'description': description,
        'updated_at': now.toIso8601String(),
      };
      
      final updatedData = await _timeLogDatasource.updateTimeLog(activeTimeLogId, timeLogData);
      AppLogger.repository('Check-out realizado com sucesso para estudante: $studentId');
      return Right(TimeLogModel.fromJson(updatedData).toEntity());
    } catch (e) {
      AppLogger.error('Erro ao realizar check-out', error: e);
      return Left(ServerFailure(message: 'Erro ao realizar check-out: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> createTimeLog(
      {required String studentId,
      required DateTime logDate,
      required TimeOfDay checkInTime,
      TimeOfDay? checkOutTime,
      String? description}) async {
    try {
      final timeLogData = {
        'student_id': studentId,
        'log_date': logDate.toIso8601String().split('T')[0],
        'check_in_time': '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}',
        'check_out_time': checkOutTime != null 
            ? '${checkOutTime.hour.toString().padLeft(2, '0')}:${checkOutTime.minute.toString().padLeft(2, '0')}'
            : null,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final createdData = await _timeLogDatasource.createTimeLog(timeLogData);
      return Right(TimeLogModel.fromJson(createdData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao criar registro de tempo: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteTimeLog(String timeLogId) async {
    try {
      await _timeLogDatasource.deleteTimeLog(timeLogId);
      AppLogger.repository('Time log deletado com sucesso: $timeLogId');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Erro ao deletar time log', error: e);
      return Left(ServerFailure(message: 'Erro ao deletar registro de tempo: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> getStudentDetails(
      String userId) async {
    final result = await getStudentByUserId(userId);
    return result.fold(
      (failure) => Left(failure),
      (student) {
        if (student == null) {
          return const Left(ServerFailure(message: 'Estudante não encontrado'));
        }
        return Right(student);
      },
    );
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getStudentTimeLogs({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final List<Map<String, dynamic>> timeLogsData;
      if (startDate != null && endDate != null) {
        timeLogsData = await _timeLogDatasource.getTimeLogsByDateRange(
            studentId, startDate, endDate);
      } else {
        timeLogsData = await _timeLogDatasource.getTimeLogsByStudent(studentId);
      }

      final timeLogs = timeLogsData
          .map((data) => TimeLogModel.fromJson(data).toEntity())
          .toList();
      return Right(timeLogs);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro no repositório ao buscar logs de tempo: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> updateStudentProfile(
      StudentEntity student) async {
    return await updateStudent(student);
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> updateTimeLog(
      TimeLogEntity timeLog) async {
    try {
      // Implementação temporária
      AppLogger.repository('Método updateTimeLog não implementado foi chamado.');
return const Left(NotImplementedFailure(message: 'Método updateTimeLog não está disponível na versão atual'));
    } catch (e) {
      AppLogger.error('Erro inesperado em updateTimeLog', error: e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, Map<String, dynamic>>> getStudentDashboard(
      String studentId) async {
    try {
      // Usar o datasource real para buscar dados do dashboard
      final dashboardData =
          await _studentDatasource.getStudentDashboard(studentId);
      return Right(dashboardData);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
