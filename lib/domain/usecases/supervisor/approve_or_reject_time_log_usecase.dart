// lib/domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../entities/time_log_entity.dart';
import '../../repositories/i_supervisor_repository.dart';

class ApproveOrRejectTimeLogParams extends Equatable {
  final String timeLogId;
  final bool approved;
  final String supervisorId;
  final String? rejectionReason;

  const ApproveOrRejectTimeLogParams({
    required this.timeLogId,
    required this.approved,
    required this.supervisorId,
    this.rejectionReason,
  });

  @override
  List<Object?> get props =>
      [timeLogId, approved, supervisorId, rejectionReason];
}

class ApproveOrRejectTimeLogUsecase {
  final ISupervisorRepository _repository;

  ApproveOrRejectTimeLogUsecase(this._repository);

  Future<Either<AppFailure, TimeLogEntity>> call(
      ApproveOrRejectTimeLogParams params) async {
    try {
      return await _repository.approveOrRejectTimeLog(
        timeLogId: params.timeLogId,
        approved: params.approved,
        supervisorId: params.supervisorId,
        rejectionReason: params.rejectionReason,
      );
    } on AppException catch (e) {
      return Left(AppFailure(message: e.message));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}
