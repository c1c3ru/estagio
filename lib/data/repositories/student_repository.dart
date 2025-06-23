import '../../domain/repositories/i_student_repository.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/time_log_entity.dart';
import '../../core/errors/app_exceptions.dart';
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
  Future<StudentEntity?> getStudentById(String id) async {
    try {
      final studentData = await _studentDatasource.getStudentById(id);
      if (studentData == null) return null;
      return StudentModel.fromJson(studentData).toEntity();
    } catch (e) {
      throw Exception('Erro no repositório ao buscar estudante: $e');
    }
  }

  @override
  Future<StudentEntity?> getStudentByUserId(String userId) async {
    try {
      final studentData = await _studentDatasource.getStudentByUserId(userId);
      if (studentData == null) return null;
      return StudentModel.fromJson(studentData).toEntity();
    } catch (e) {
      throw Exception(
          'Erro no repositório ao buscar estudante por usuário: $e');
    }
  }

  @override
  Future<StudentEntity> createStudent(StudentEntity student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);
      final createdData =
          await _studentDatasource.createStudent(studentModel.toJson());
      return StudentModel.fromJson(createdData).toEntity();
    } catch (e) {
      throw Exception('Erro no repositório ao criar estudante: $e');
    }
  }

  @override
  Future<StudentEntity> updateStudent(StudentEntity student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);
      final updatedData = await _studentDatasource.updateStudent(
        student.id,
        studentModel.toJson(),
      );
      return StudentModel.fromJson(updatedData).toEntity();
    } catch (e) {
      throw Exception('Erro no repositório ao atualizar estudante: $e');
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    try {
      await _studentDatasource.deleteStudent(id);
    } catch (e) {
      throw Exception('Erro no repositório ao excluir estudante: $e');
    }
  }

  @override
  Future<List<StudentEntity>> getStudentsBySupervisor(
      String supervisorId) async {
    try {
      final studentsData =
          await _studentDatasource.getStudentsBySupervisor(supervisorId);
      return studentsData
          .map((data) => StudentModel.fromJson(data).toEntity())
          .toList();
    } catch (e) {
      throw Exception(
          'Erro no repositório ao buscar estudantes do supervisor: $e');
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> checkIn(
      {required String studentId, String? notes}) async {
    try {
      // Implementação temporária
      return const Left(
          ServerFailure(message: 'Método checkIn não implementado'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> checkOut(
      {required String studentId,
      required String activeTimeLogId,
      String? description}) async {
    try {
      // Implementação temporária
      return const Left(
          ServerFailure(message: 'Método checkOut não implementado'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      // Implementação temporária
      return const Left(
          ServerFailure(message: 'Método createTimeLog não implementado'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteTimeLog(String timeLogId) async {
    try {
      // Implementação temporária
      return const Left(
          ServerFailure(message: 'Método deleteTimeLog não implementado'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> getStudentDetails(
      String userId) async {
    try {
      final student = await getStudentByUserId(userId);
      if (student == null) {
        return const Left(ServerFailure(message: 'Estudante não encontrado'));
      }
      return Right(student);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
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
    try {
      final updatedStudent = await updateStudent(student);
      return Right(updatedStudent);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> updateTimeLog(
      TimeLogEntity timeLog) async {
    try {
      // Implementação temporária
      return const Left(
          ServerFailure(message: 'Método updateTimeLog não implementado'));
    } catch (e) {
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
