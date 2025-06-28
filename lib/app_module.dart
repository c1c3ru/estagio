import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'package:gestao_de_estagio/domain/usecases/contract/get_contracts_for_student_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Data Sources
import 'data/datasources/supabase/auth_datasource.dart';
import 'data/datasources/supabase/student_datasource.dart';
import 'data/datasources/supabase/supervisor_datasource.dart';
import 'data/datasources/supabase/time_log_datasource.dart';
import 'data/datasources/supabase/contract_datasource.dart';
import 'data/datasources/supabase/notification_datasource.dart';
import 'data/datasources/local/preferences_manager.dart';
import 'data/datasources/local/cache_manager.dart';
import 'data/datasources/local/local_storage_service.dart';
import 'domain/repositories/i_auth_datasource.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/student_repository.dart';
import 'data/repositories/supervisor_repository.dart';
import 'data/repositories/time_log_repository.dart';
import 'data/repositories/contract_repository.dart';
import 'data/repositories/notification_repository.dart';

// Domain Repositories
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_student_repository.dart';
import 'domain/repositories/i_supervisor_repository.dart';
import 'domain/repositories/i_time_log_repository.dart';
import 'domain/repositories/i_contract_repository.dart';
import 'domain/repositories/i_notification_repository.dart';

// Use Cases - Auth
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/update_profile_usecase.dart';
import 'domain/usecases/auth/get_auth_state_changes_usecase.dart';

// Use Cases - Student
import 'domain/usecases/student/get_all_students_usecase.dart';
import 'domain/usecases/student/get_student_by_id_usecase.dart';
import 'domain/usecases/student/get_student_by_user_id_usecase.dart';
import 'domain/usecases/student/create_student_usecase.dart';
import 'domain/usecases/student/update_student_usecase.dart';
import 'domain/usecases/student/get_student_details_usecase.dart';
import 'domain/usecases/student/update_student_profile_usecase.dart';
import 'domain/usecases/student/check_in_usecase.dart';
import 'domain/usecases/student/check_out_usecase.dart';
import 'domain/usecases/student/get_student_time_logs_usecase.dart';
import 'domain/usecases/student/create_time_log_usecase.dart';
import 'domain/usecases/student/update_time_log_usecase.dart';
import 'domain/usecases/student/delete_time_log_usecase.dart';

import 'domain/usecases/student/delete_student_usecase.dart';
import 'domain/usecases/student/get_students_by_supervisor_usecase.dart';
import 'domain/usecases/student/get_student_dashboard_usecase.dart';

// Use Cases - Supervisor
import 'domain/usecases/supervisor/get_all_supervisors_usecase.dart';
import 'domain/usecases/supervisor/get_supervisor_by_id_usecase.dart';
import 'domain/usecases/supervisor/get_supervisor_by_user_id_usecase.dart';
import 'domain/usecases/supervisor/create_supervisor_usecase.dart';
import 'domain/usecases/supervisor/update_supervisor_usecase.dart';
import 'domain/usecases/supervisor/delete_supervisor_usecase.dart';
import 'domain/usecases/supervisor/get_supervisor_details_usecase.dart';
import 'domain/usecases/supervisor/get_all_students_for_supervisor_usecase.dart';
import 'domain/usecases/supervisor/get_student_details_for_supervisor_usecase.dart';
import 'domain/usecases/supervisor/create_student_by_supervisor_usecase.dart';
import 'domain/usecases/supervisor/update_student_by_supervisor_usecase.dart';
import 'domain/usecases/supervisor/delete_student_by_supervisor_usecase.dart';
import 'domain/usecases/supervisor/get_all_time_logs_for_supervisor_usecase.dart';
import 'domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart';

// Use Cases - TimeLog
import 'domain/usecases/time_log/clock_in_usecase.dart';
import 'domain/usecases/time_log/clock_out_usecase.dart';
import 'domain/usecases/time_log/get_time_logs_by_student_usecase.dart';
import 'domain/usecases/time_log/get_active_time_log_usecase.dart';
import 'domain/usecases/time_log/get_total_hours_by_student_usecase.dart';

// Use Cases - Contract
import 'domain/usecases/contract/get_contracts_by_student_usecase.dart';
import 'domain/usecases/contract/get_contracts_by_supervisor_usecase.dart';
import 'domain/usecases/contract/get_active_contract_by_student_usecase.dart';
import 'domain/usecases/contract/create_contract_usecase.dart';
import 'domain/usecases/contract/update_contract_usecase.dart';
import 'domain/usecases/contract/delete_contract_usecase.dart';
import 'domain/usecases/contract/get_contract_statistics_usecase.dart';
import 'domain/usecases/contract/get_all_contracts_usecase.dart';

// BLoCs
import 'features/auth/bloc/auth_bloc.dart';
import 'features/student/bloc/student_bloc.dart';
import 'features/supervisor/bloc/supervisor_bloc.dart';
import 'features/shared/bloc/time_log_bloc.dart';
import 'features/shared/bloc/contract_bloc.dart';
import 'features/shared/bloc/notification_bloc.dart';

// Pages
import 'features/auth/pages/login_page.dart';
import 'features/shared/pages/notification_page.dart';
import 'features/auth/pages/register_type_page.dart';
import 'features/auth/pages/supervisor_register_page.dart';
import 'features/student/pages/student_register_page.dart';
import 'features/auth/pages/unauthorized_page.dart';
import 'features/auth/pages/email_confirmation_page.dart';

// Modules
import 'features/student/student_module.dart';
import 'features/supervisor/supervisor_module.dart';

// Guards
import 'core/guards/auth_guard.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    // External Dependencies
    i.addLazySingleton<SupabaseClient>(() => Supabase.instance.client);

    // Data Sources
    i.addLazySingleton<IAuthDatasource>(() => AuthDatasource(i()));
    i.addLazySingleton<AuthDatasource>(() => AuthDatasource(i()));
    i.addLazySingleton<StudentDatasource>(() => StudentDatasource(i()));
    i.addLazySingleton<SupervisorDatasource>(() => SupervisorDatasource(i()));
    i.addLazySingleton<TimeLogDatasource>(() => TimeLogDatasource(i()));
    i.addLazySingleton<ContractDatasource>(() => ContractDatasource(i()));
    i.addLazySingleton<NotificationDatasource>(
        () => NotificationDatasource(i()));
    i.addLazySingleton<PreferencesManager>(() => PreferencesManager(null));
    i.addLazySingleton<CacheManager>(() => CacheManager());
    i.addLazySingleton<LocalStorageService>(
        () => LocalStorageService(i(), i()));

    // Repositories
    i.addLazySingleton<IAuthRepository>(() => AuthRepository(
          i(), // IAuthDatasource
          i(), // PreferencesManager
        ));
    i.addLazySingleton<IStudentRepository>(() => StudentRepository(i(), i()));
    i.addLazySingleton<ISupervisorRepository>(
        () => SupervisorRepository(i(), i(), i()));
    i.addLazySingleton<ITimeLogRepository>(() => TimeLogRepository(i()));
    i.addLazySingleton<IContractRepository>(() => ContractRepository(i()));
    i.addLazySingleton<INotificationRepository>(
        () => NotificationRepository(i()));

    // Use Cases - Auth
    i.addLazySingleton<LoginUsecase>(() => LoginUsecase(i()));
    i.addLazySingleton<RegisterUsecase>(() => RegisterUsecase(i()));
    i.addLazySingleton<LogoutUsecase>(() => LogoutUsecase(i()));
    i.addLazySingleton<GetCurrentUserUsecase>(() => GetCurrentUserUsecase(i()));
    i.addLazySingleton<UpdateProfileUsecase>(() => UpdateProfileUsecase(i()));
    i.addLazySingleton<GetAuthStateChangesUsecase>(
        () => GetAuthStateChangesUsecase(i()));

    // Use Cases - Student
    i.addLazySingleton<GetAllStudentsUsecase>(() => GetAllStudentsUsecase(i()));
    i.addLazySingleton<GetStudentByIdUsecase>(() => GetStudentByIdUsecase(i()));
    i.addLazySingleton<GetStudentByUserIdUsecase>(
        () => GetStudentByUserIdUsecase(i()));
    i.addLazySingleton<CreateStudentUsecase>(() => CreateStudentUsecase(i()));
    i.addLazySingleton<UpdateStudentUsecase>(() => UpdateStudentUsecase(i()));
    i.addLazySingleton<GetStudentDetailsUsecase>(
        () => GetStudentDetailsUsecase(i()));
    i.addLazySingleton<UpdateStudentProfileUsecase>(
        () => UpdateStudentProfileUsecase(i()));
    i.addLazySingleton<CheckInUsecase>(() => CheckInUsecase(i()));
    i.addLazySingleton<CheckOutUsecase>(() => CheckOutUsecase(i()));
    i.addLazySingleton<GetStudentTimeLogsUsecase>(
        () => GetStudentTimeLogsUsecase(i()));
    i.addLazySingleton<CreateTimeLogUsecase>(() => CreateTimeLogUsecase(i()));
    i.addLazySingleton<UpdateTimeLogUsecase>(() => UpdateTimeLogUsecase(i()));
    i.addLazySingleton<DeleteTimeLogUsecase>(() => DeleteTimeLogUsecase(i()));
    i.addLazySingleton<GetContractsForStudentUsecase>(
        () => GetContractsForStudentUsecase(i()));
    i.addLazySingleton<DeleteStudentUsecase>(() => DeleteStudentUsecase(i()));
    i.addLazySingleton<GetStudentsBySupervisorUsecase>(
        () => GetStudentsBySupervisorUsecase(i()));
    i.addLazySingleton<GetStudentDashboardUsecase>(
        () => GetStudentDashboardUsecase(i()));

    // Use Cases - Supervisor
    i.addLazySingleton<GetAllSupervisorsUsecase>(
        () => GetAllSupervisorsUsecase(i()));
    i.addLazySingleton<GetSupervisorByIdUsecase>(
        () => GetSupervisorByIdUsecase(i()));
    i.addLazySingleton<GetSupervisorByUserIdUsecase>(
        () => GetSupervisorByUserIdUsecase(i()));
    i.addLazySingleton<CreateSupervisorUsecase>(
        () => CreateSupervisorUsecase(i()));
    i.addLazySingleton<UpdateSupervisorUsecase>(
        () => UpdateSupervisorUsecase(i()));
    i.addLazySingleton<DeleteSupervisorUsecase>(
        () => DeleteSupervisorUsecase(i()));
    i.addLazySingleton<GetSupervisorDetailsUsecase>(
        () => GetSupervisorDetailsUsecase(i()));
    i.addLazySingleton<GetAllStudentsForSupervisorUsecase>(
        () => GetAllStudentsForSupervisorUsecase(i()));
    i.addLazySingleton<GetStudentDetailsForSupervisorUsecase>(
        () => GetStudentDetailsForSupervisorUsecase(i()));
    i.addLazySingleton<CreateStudentBySupervisorUsecase>(
        () => CreateStudentBySupervisorUsecase(i()));
    i.addLazySingleton<UpdateStudentBySupervisorUsecase>(
        () => UpdateStudentBySupervisorUsecase(i()));
    i.addLazySingleton<DeleteStudentBySupervisorUsecase>(
        () => DeleteStudentBySupervisorUsecase(i()));
    i.addLazySingleton<GetAllTimeLogsForSupervisorUsecase>(
        () => GetAllTimeLogsForSupervisorUsecase(i()));
    i.addLazySingleton<ApproveOrRejectTimeLogUsecase>(
        () => ApproveOrRejectTimeLogUsecase(i()));

    // Use Cases - TimeLog
    i.addLazySingleton<ClockInUsecase>(() => ClockInUsecase(i()));
    i.addLazySingleton<ClockOutUsecase>(() => ClockOutUsecase(i()));
    i.addLazySingleton<GetTimeLogsByStudentUsecase>(
        () => GetTimeLogsByStudentUsecase(i()));
    i.addLazySingleton<GetActiveTimeLogUsecase>(
        () => GetActiveTimeLogUsecase(i()));
    i.addLazySingleton<GetTotalHoursByStudentUsecase>(
        () => GetTotalHoursByStudentUsecase(i()));

    // Use Cases - Contract
    i.addLazySingleton<GetContractsByStudentUsecase>(
        () => GetContractsByStudentUsecase(i()));
    i.addLazySingleton<GetContractsBySupervisorUsecase>(
        () => GetContractsBySupervisorUsecase(i()));
    i.addLazySingleton<GetActiveContractByStudentUsecase>(
        () => GetActiveContractByStudentUsecase(i()));
    i.addLazySingleton<CreateContractUsecase>(() => CreateContractUsecase(i()));
    i.addLazySingleton<UpdateContractUsecase>(() => UpdateContractUsecase(i()));
    i.addLazySingleton<DeleteContractUsecase>(() => DeleteContractUsecase(i()));
    i.addLazySingleton<GetContractStatisticsUsecase>(
        () => GetContractStatisticsUsecase(i()));
    i.addLazySingleton<GetAllContractsUsecase>(
        () => GetAllContractsUsecase(i()));

    // BLoCs
    i.addLazySingleton<AuthBloc>(() => AuthBloc(
          loginUseCase: i(),
          registerUseCase: i(),
          logoutUseCase: i(),
          getCurrentUserUseCase: i(),
          updateProfileUseCase: i(),
          getAuthStateChangesUseCase: i(),
        ));

    i.addLazySingleton<StudentBloc>(() => StudentBloc(
          getStudentDashboardUsecase: i(),
        ));

    i.add<SupervisorBloc>(() => SupervisorBloc(
          getSupervisorDetailsUsecase: i(),
          getAllStudentsForSupervisorUsecase: i(),
          getStudentDetailsForSupervisorUsecase: i(),
          createStudentBySupervisorUsecase: i(),
          updateStudentBySupervisorUsecase: i(),
          deleteStudentBySupervisorUsecase: i(),
          getAllTimeLogsForSupervisorUsecase: i(),
          approveOrRejectTimeLogUsecase: i(),
          getAllContractsUsecase: i(),
          createContractUsecase: i(),
          updateContractUsecase: i(),
          registerAuthUserUsecase: i(),
          getAllSupervisorsUsecase: i(),
          createSupervisorUsecase: i(),
          updateSupervisorUsecase: i(),
          deleteSupervisorUsecase: i(),
          authBloc: i(),
        ));

    i.addLazySingleton<TimeLogBloc>(() => TimeLogBloc(
          clockInUsecase: i(),
          clockOutUsecase: i(),
          getTimeLogsByStudentUsecase: i(),
          getActiveTimeLogUsecase: i(),
          getTotalHoursByStudentUsecase: i(),
        ));

    i.addLazySingleton<ContractBloc>(() => ContractBloc(
          getContractsByStudentUsecase: i(),
          getContractsBySupervisorUsecase: i(),
          getActiveContractByStudentUsecase: i(),
          createContractUsecase: i(),
          updateContractUsecase: i(),
          deleteContractUsecase: i(),
          getContractStatisticsUsecase: i(),
        ));

    i.addLazySingleton<NotificationBloc>(() => NotificationBloc(
          notificationRepository: i(),
          authRepository: i(),
        ));

    // Guards
    i.addLazySingleton<AuthGuard>(() => AuthGuard(i<AuthBloc>()));
  }

  @override
  void routes(RouteManager r) {
    // Auth Routes
    r.child('/', child: (context) => const LoginPage());
    r.child('/login', child: (context) => const LoginPage());
    r.child('/auth/register-type',
        child: (context) => const RegisterTypePage());
    r.child('/auth/register-student',
        child: (context) => const StudentRegisterPage());
    r.child('/auth/register-supervisor',
        child: (context) => const SupervisorRegisterPage());
    r.child('/auth/unauthorized', child: (context) => const UnauthorizedPage());
    r.child('/auth/email-confirmation',
        child: (context) => EmailConfirmationPage(
              email: r.args.data as String,
            ));
    r.child('/auth/forgot-password',
        child: (context) => const Scaffold(
              body: Center(
                child:
                    Text('Página de recuperação de senha em desenvolvimento'),
              ),
            ));

    // Student Module Routes
    r.module('/student', module: StudentModule());

    // Supervisor Module Routes
    r.module('/supervisor', module: SupervisorModule());

    // Shared Routes
    r.child(
      "/notifications",
      child: (context) => BlocProvider(
        create: (_) => Modular.get<NotificationBloc>(),
        child: const NotificationPage(),
      ),
    );
  }
}
