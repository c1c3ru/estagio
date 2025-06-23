import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

import 'package:gestao_de_estagio/domain/entities/time_log_entity.dart';

import '../entities/student_entity.dart';

abstract class IStudentRepository {
  Future<Either<AppFailure, List<StudentEntity>>> getAllStudents();
  Future<StudentEntity?> getStudentById(String id);
  Future<StudentEntity?> getStudentByUserId(String userId);
  Future<StudentEntity> createStudent(StudentEntity student);
  Future<StudentEntity> updateStudent(StudentEntity student);
  Future<void> deleteStudent(String id);
  Future<List<StudentEntity>> getStudentsBySupervisor(String supervisorId);

  Future<Either<AppFailure, TimeLogEntity>> checkIn(
      {required String studentId, String? notes});

  Future<Either<AppFailure, TimeLogEntity>> checkOut(
      {required String studentId,
      required String activeTimeLogId,
      String? description});

  Future<Either<AppFailure, TimeLogEntity>> createTimeLog(
      {required String studentId,
      required DateTime logDate,
      required TimeOfDay checkInTime,
      TimeOfDay? checkOutTime,
      String? description});

  Future<Either<AppFailure, void>> deleteTimeLog(String timeLogId);

  Future<Either<AppFailure, StudentEntity>> getStudentDetails(String userId);

  Future<Either<AppFailure, List<TimeLogEntity>>> getStudentTimeLogs(
      {required String studentId, DateTime? startDate, DateTime? endDate});

  Future<Either<AppFailure, StudentEntity>> updateStudentProfile(
      StudentEntity student);

  Future<Either<AppFailure, TimeLogEntity>> updateTimeLog(
      TimeLogEntity timeLog);

  Future<Either<AppFailure, Map<String, dynamic>>> getStudentDashboard(
      String studentId);
}
