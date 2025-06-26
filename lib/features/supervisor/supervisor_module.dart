// lib/features/supervisor/supervisor_module.dart

import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/student_details_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/student_edit_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/supervisor_dashboard_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/supervisor_home_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/supervisor_time_approval_page.dart';
import 'package:gestao_de_estagio/features/supervisor/pages/supervisor_profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Para SupabaseClient

// Datasources
import '../../data/datasources/supabase/supervisor_datasource.dart';
import '../../data/datasources/supabase/student_datasource.dart';
import '../../data/datasources/supabase/time_log_datasource.dart';
import '../../data/datasources/supabase/contract_datasource.dart';

// Repositories (Implementações)
import '../../data/repositories/supervisor_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/time_log_repository.dart';
import '../../data/repositories/contract_repository.dart';

// Repository Interfaces (do Domínio)
import '../../domain/repositories/i_supervisor_repository.dart';
import '../../domain/repositories/i_student_repository.dart';
import '../../domain/repositories/i_time_log_repository.dart';
import '../../domain/repositories/i_contract_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';

// Usecases
import '../../domain/usecases/supervisor/get_supervisor_details_usecase.dart';
import '../../domain/usecases/supervisor/get_all_students_for_supervisor_usecase.dart';
import '../../domain/usecases/supervisor/get_student_details_for_supervisor_usecase.dart';
import '../../domain/usecases/supervisor/create_student_by_supervisor_usecase.dart';
import '../../domain/usecases/supervisor/update_student_by_supervisor_usecase.dart';
import '../../domain/usecases/supervisor/delete_student_by_supervisor_usecase.dart';
import '../../domain/usecases/supervisor/get_all_time_logs_for_supervisor_usecase.dart';
import '../../domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart';
import '../../domain/usecases/contract/get_all_contracts_usecase.dart';
import '../../domain/usecases/contract/create_contract_usecase.dart';
import '../../domain/usecases/contract/update_contract_usecase.dart';
import '../../domain/usecases/contract/delete_contract_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/supervisor/update_supervisor_usecase.dart';

class SupervisorModule extends Module {
  @override
  void binds(Injector i) {
    // --- Repositories ---
    i.add<IStudentRepository>(() => StudentRepository(
        i.get<StudentDatasource>(), i.get<TimeLogDatasource>()));
    i.add<ITimeLogRepository>(
        () => TimeLogRepository(i.get<TimeLogDatasource>()));
    i.add<IContractRepository>(
        () => ContractRepository(i.get<ContractDatasource>()));
    i.add<ISupervisorRepository>(() => SupervisorRepository(
          i.get<SupervisorDatasource>(),
          i.get<ITimeLogRepository>(),
          i.get<IContractRepository>(),
        ));

    // --- Usecases ---
    i.add<RegisterUsecase>(() => RegisterUsecase(i.get<IAuthRepository>()));
    i.add<GetSupervisorDetailsUsecase>(
        () => GetSupervisorDetailsUsecase(i.get<ISupervisorRepository>()));
    i.add<GetAllStudentsForSupervisorUsecase>(() =>
        GetAllStudentsForSupervisorUsecase(i.get<ISupervisorRepository>()));
    i.add<GetStudentDetailsForSupervisorUsecase>(() =>
        GetStudentDetailsForSupervisorUsecase(i.get<ISupervisorRepository>()));
    i.add<CreateStudentBySupervisorUsecase>(
        () => CreateStudentBySupervisorUsecase(i.get<ISupervisorRepository>()));
    i.add<UpdateStudentBySupervisorUsecase>(
        () => UpdateStudentBySupervisorUsecase(i.get<ISupervisorRepository>()));
    i.add<DeleteStudentBySupervisorUsecase>(
        () => DeleteStudentBySupervisorUsecase(i.get<ISupervisorRepository>()));
    i.add<GetAllTimeLogsForSupervisorUsecase>(() =>
        GetAllTimeLogsForSupervisorUsecase(i.get<ISupervisorRepository>()));
    i.add<ApproveOrRejectTimeLogUsecase>(
        () => ApproveOrRejectTimeLogUsecase(i.get<ISupervisorRepository>()));
    i.add<GetAllContractsUsecase>(
        () => GetAllContractsUsecase(i.get<IContractRepository>()));
    i.add<CreateContractUsecase>(
        () => CreateContractUsecase(i.get<IContractRepository>()));
    i.add<UpdateContractUsecase>(
        () => UpdateContractUsecase(i.get<IContractRepository>()));
    i.add<DeleteContractUsecase>(
        () => DeleteContractUsecase(i.get<IContractRepository>()));
    i.add<UpdateSupervisorUsecase>(
        () => UpdateSupervisorUsecase(i.get<ISupervisorRepository>()));

    // --- BLoC ---
    i.add<SupervisorBloc>(() => SupervisorBloc(
          getSupervisorDetailsUsecase: i.get<GetSupervisorDetailsUsecase>(),
          getAllStudentsForSupervisorUsecase:
              i.get<GetAllStudentsForSupervisorUsecase>(),
          getStudentDetailsForSupervisorUsecase:
              i.get<GetStudentDetailsForSupervisorUsecase>(),
          createStudentBySupervisorUsecase:
              i.get<CreateStudentBySupervisorUsecase>(),
          updateStudentBySupervisorUsecase:
              i.get<UpdateStudentBySupervisorUsecase>(),
          deleteStudentBySupervisorUsecase:
              i.get<DeleteStudentBySupervisorUsecase>(),
          getAllTimeLogsForSupervisorUsecase:
              i.get<GetAllTimeLogsForSupervisorUsecase>(),
          approveOrRejectTimeLogUsecase: i.get<ApproveOrRejectTimeLogUsecase>(),
          getAllContractsUsecase: i.get<GetAllContractsUsecase>(),
          createContractUsecase: i.get<CreateContractUsecase>(),
          updateContractUsecase: i.get<UpdateContractUsecase>(),
          deleteContractUsecase: i.get<DeleteContractUsecase>(),
          registerAuthUserUsecase: i.get<RegisterUsecase>(),
        ));
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Modular.initialRoute,
      child: (_) => BlocProvider(
        create: (_) => Modular.get<SupervisorBloc>(),
        child: const SupervisorHomePage(),
      ),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/time-approval',
      child: (_) => BlocProvider(
        create: (_) => Modular.get<SupervisorBloc>(),
        child: const SupervisorTimeApprovalPage(),
      ),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/profile',
      child: (_) => BlocProvider(
        create: (_) => Modular.get<SupervisorBloc>(),
        child: const SupervisorProfilePage(),
      ),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/student-details/:studentId',
      child: (_) =>
          StudentDetailsPage(studentId: r.args.params['studentId'] as String),
      transition: TransitionType.rightToLeft,
    );
    r.child(
      '/student-edit/:studentId',
      child: (_) =>
          StudentEditPage(studentId: r.args.params['studentId'] as String),
      transition: TransitionType.rightToLeft,
    );
    r.child(
      '/student-create',
      child: (_) => const StudentEditPage(),
      transition: TransitionType.rightToLeft,
    );
  }
}
