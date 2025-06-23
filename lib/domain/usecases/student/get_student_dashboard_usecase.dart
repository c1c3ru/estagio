import 'package:dartz/dartz.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../repositories/i_student_repository.dart';

class GetStudentDashboardUsecase {
  final IStudentRepository _repository;

  GetStudentDashboardUsecase(this._repository);

  Future<Either<AppFailure, Map<String, dynamic>>> call(
      String studentId) async {
    return _repository.getStudentDashboard(studentId);
  }
}
