import 'package:dartz/dartz.dart';
import 'package:gestao_de_estagio/domain/entities/filter_students_params.dart';
import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/supervisor_entity.dart';
import '../../domain/repositories/i_supervisor_repository.dart';
import '../datasources/supabase/supervisor_datasource.dart';
import '../models/student_model.dart';
import '../models/supervisor_model.dart';
import '../../domain/entities/time_log_entity.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/i_time_log_repository.dart';
import '../../domain/repositories/i_contract_repository.dart';

class SupervisorRepository implements ISupervisorRepository {
  final SupervisorDatasource _supervisorDatasource;
  final ITimeLogRepository _timeLogRepository;
  final IContractRepository _contractRepository;

  SupervisorRepository(this._supervisorDatasource, this._timeLogRepository,
      this._contractRepository);

  @override
  Future<Either<AppFailure, List<SupervisorEntity>>> getAllSupervisors() async {
    try {
      final supervisorsData = await _supervisorDatasource.getAllSupervisors();
      final supervisors = supervisorsData
          .map((data) => SupervisorModel.fromJson(data).toEntity())
          .toList();
      return Right(supervisors);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar supervisores: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SupervisorEntity>> getSupervisorById(
      String id) async {
    try {
      final supervisorData = await _supervisorDatasource.getSupervisorById(id);
      if (supervisorData == null) {
        return const Left(ServerFailure(message: 'Supervisor não encontrado'));
      }
      return Right(SupervisorModel.fromJson(supervisorData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SupervisorEntity?>> getSupervisorByUserId(
      String userId) async {
    try {
      final supervisorData =
          await _supervisorDatasource.getSupervisorByUserId(userId);
      if (supervisorData == null) {
        return const Right(null);
      }
      return Right(SupervisorModel.fromJson(supervisorData).toEntity());
    } catch (e) {
      return Left(
          ServerFailure(message: 'Erro ao buscar supervisor por usuário: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SupervisorEntity>> createSupervisor(
      SupervisorEntity supervisor) async {
    try {
      final supervisorModel = SupervisorModel.fromEntity(supervisor);
      final createdData = await _supervisorDatasource
          .createSupervisor(supervisorModel.toJson());
      return Right(SupervisorModel.fromJson(createdData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao criar supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SupervisorEntity>> updateSupervisor(
      SupervisorEntity supervisor) async {
    try {
      final supervisorModel = SupervisorModel.fromEntity(supervisor);
      final updatedData = await _supervisorDatasource.updateSupervisor(
        supervisor.id,
        supervisorModel.toJson(),
      );
      return Right(SupervisorModel.fromJson(updatedData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao atualizar supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteSupervisor(String id) async {
    try {
      await _supervisorDatasource.deleteSupervisor(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao excluir supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<StudentEntity>>> getAllStudentsForSupervisor(
      String supervisorId) async {
    try {
      final studentsData = await _supervisorDatasource.getAllStudents(
          supervisorId: supervisorId);
      final students = studentsData
          .map((data) => StudentModel.fromJson(data).toEntity())
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erro ao buscar estudantes do supervisor: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> getStudentDetailsForSupervisor(
      String studentId) async {
    try {
      final studentData = await _supervisorDatasource.getStudentById(studentId);
      if (studentData == null) {
        return const Left(ServerFailure(message: 'Estudante não encontrado'));
      }
      return Right(StudentModel.fromJson(studentData).toEntity());
    } catch (e) {
      return Left(
          ServerFailure(message: 'Erro ao buscar detalhes do estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> updateStudentBySupervisor(
      StudentEntity student) async {
    try {
      final studentModel = student as StudentModel;
      final updatedData = await _supervisorDatasource.updateStudent(
        student.id,
        studentModel.toJson(),
      );
      return Right(StudentModel.fromJson(updatedData).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao atualizar estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, TimeLogEntity>> approveOrRejectTimeLog(
      {required String timeLogId,
      required bool approved,
      required String supervisorId,
      String? rejectionReason}) async {
    try {
      final timeLog = await _supervisorDatasource.approveOrRejectTimeLog(
        timeLogId: timeLogId,
        approved: approved,
        supervisorId: supervisorId,
        rejectionReason: rejectionReason,
      );
      return Right(TimeLogEntity.fromJson(timeLog));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, StudentEntity>> createStudent(
      StudentEntity student) async {
    try {
      final studentModel = student as StudentModel;
      final createdStudent =
          await _supervisorDatasource.createStudent(studentModel.toJson());
      return Right(StudentModel.fromJson(createdStudent).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao criar estudante: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteStudent(String studentId) async {
    try {
      await _supervisorDatasource.deleteStudent(studentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<StudentEntity>>> getAllStudents({
    String? supervisorId,
    FilterStudentsParams? filters,
  }) async {
    try {
      final students = await _supervisorDatasource.getAllStudents(
        supervisorId: supervisorId,
        filters: filters,
      );
      return Right(
          students.map((s) => StudentModel.fromJson(s).toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<TimeLogEntity>>> getAllTimeLogs({
    String? studentId,
    bool pendingOnly = false,
  }) async {
    try {
      final timeLogs = await _supervisorDatasource.getAllTimeLogs(
        studentId: studentId,
        pendingOnly: pendingOnly,
      );
      return Right(timeLogs.map((t) => TimeLogEntity.fromJson(t)).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, SupervisorEntity>> getSupervisorDetails(
      String supervisorId) async {
    try {
      final supervisor =
          await _supervisorDatasource.getSupervisorById(supervisorId);
      if (supervisor == null) {
        return const Left(ServerFailure(message: 'Supervisor não encontrado'));
      }
      return Right(SupervisorModel.fromJson(supervisor).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<
          Either<AppFailure,
              (StudentEntity, List<TimeLogEntity>, List<ContractEntity>)>>
      getStudentDetails(String studentId) async {
    try {
      final studentData = await _supervisorDatasource.getStudentById(studentId);
      if (studentData == null) {
        return const Left(ServerFailure(message: 'Estudante não encontrado'));
      }

      final student = StudentModel.fromJson(studentData).toEntity();

      final timeLogsResult = await _timeLogRepository.getTimeLogsByStudent(studentId);
      if (timeLogsResult.isLeft()) {
        return Left(timeLogsResult.swap().getOrElse(() => ServerFailure(message: 'Erro ao buscar time logs')));
      }
      final timeLogs = timeLogsResult.getOrElse(() => []);

      final contractsResult =
          await _contractRepository.getContractsByStudent(studentId);

      return contractsResult.fold(
        (failure) => Left(failure),
        (contracts) => Right((student, timeLogs, contracts)),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
