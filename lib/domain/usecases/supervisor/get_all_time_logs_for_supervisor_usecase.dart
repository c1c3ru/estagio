// lib/domain/usecases/supervisor/get_all_time_logs_for_supervisor_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_supervisor_repository.dart';

class GetAllTimeLogsParams extends Equatable {
  final String? studentId;
  final bool pendingOnly;

  const GetAllTimeLogsParams({
    this.studentId,
    this.pendingOnly = false,
  });

  @override
  List<Object?> get props => [studentId, pendingOnly];
}

class GetAllTimeLogsForSupervisorUsecase {
  final ISupervisorRepository _repository;

  GetAllTimeLogsForSupervisorUsecase(this._repository);

  Future<Either<AppFailure, List<TimeLogEntity>>> call(
      GetAllTimeLogsParams params) async {
    try {
      return await _repository.getAllTimeLogs(
        studentId: params.studentId,
        pendingOnly: params.pendingOnly,
      );
    } on AppException catch (e) {
      return Left(AppFailure(message: e.message));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}
