import 'package:dartz/dartz.dart';

import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import 'package:gestao_de_estagio/domain/entities/filter_students_params.dart';
import 'package:gestao_de_estagio/domain/entities/student_entity.dart';

import 'package:gestao_de_estagio/domain/entities/time_log_entity.dart';

import '../entities/supervisor_entity.dart';
import '../entities/contract_entity.dart';

abstract class ISupervisorRepository {
  Future<Either<AppFailure, List<SupervisorEntity>>> getAllSupervisors();
  Future<Either<AppFailure, SupervisorEntity>> getSupervisorById(String id);
  Future<Either<AppFailure, SupervisorEntity?>> getSupervisorByUserId(
      String userId);
  Future<Either<AppFailure, SupervisorEntity>> createSupervisor(
      SupervisorEntity supervisor);
  Future<Either<AppFailure, SupervisorEntity>> updateSupervisor(
      SupervisorEntity supervisor);
  Future<Either<AppFailure, void>> deleteSupervisor(String id);
  Future<Either<AppFailure, StudentEntity>> getStudentDetailsForSupervisor(
      String studentId);
  Future<Either<AppFailure, StudentEntity>> updateStudentBySupervisor(
      StudentEntity student);
  Future<Either<AppFailure, List<StudentEntity>>> getAllStudentsForSupervisor(
      String supervisorId);
  Future<Either<AppFailure, StudentEntity>> createStudent(
      StudentEntity student);

  Future<Either<AppFailure, List<TimeLogEntity>>> getAllTimeLogs({
    String? studentId,
    bool pendingOnly = false,
  });

  Future<Either<AppFailure, TimeLogEntity>> approveOrRejectTimeLog({
    required String timeLogId,
    required bool approved,
    required String supervisorId,
    String? rejectionReason,
  });

  Future<Either<AppFailure, void>> deleteStudent(String studentId);

  Future<Either<AppFailure, List<StudentEntity>>> getAllStudents(
      {String? supervisorId, FilterStudentsParams? filters});

  Future<Either<AppFailure, SupervisorEntity>> getSupervisorDetails(
      String supervisorId);

  Future<
          Either<AppFailure,
              (StudentEntity, List<TimeLogEntity>, List<ContractEntity>)>>
      getStudentDetails(String studentId);

  // Garante que existe um perfil de supervisor para o usuário autenticado;
  // se não existir, cria um com dados mínimos.
  Future<Either<AppFailure, SupervisorEntity>> ensureSupervisorProfile({
    required String userId,
    required String fullName,
  });
}
