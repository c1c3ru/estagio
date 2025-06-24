import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/domain/usecases/student/check_in_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/check_out_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/create_time_log_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/delete_student_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/delete_time_log_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/get_student_by_id_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/get_student_by_user_id_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/get_student_details_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/get_student_time_logs_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/get_students_by_supervisor_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/update_student_profile_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/update_student_usecase.dart';
import 'package:gestao_de_estagio/domain/usecases/student/update_time_log_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// DataSources
import 'data/datasources/local/cache_manager.dart';
import 'data/datasources/local/in_memory_preferences_manager.dart';
import 'data/datasources/local/preferences_manager.dart';
import 'data/datasources/local/preferences_manager_mock.dart';
import 'data/datasources/supabase/auth_datasource.dart';
import 'data/datasources/supabase/contract_datasource.dart';
import 'data/datasources/supabase/notification_datasource.dart';
import 'data/datasources/supabase/student_datasource.dart';
import 'data/datasources/supabase/supervisor_datasource.dart';
import 'data/datasources/supabase/time_log_datasource.dart';
// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/student_repository.dart';
import 'data/repositories/supervisor_repository.dart';
import 'data/repositories/time_log_repository.dart';
import 'data/repositories/contract_repository.dart';
import 'data/repositories/notification_repository.dart';
// Interfaces
import 'domain/repositories/i_auth_datasource.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_student_repository.dart';
import 'domain/repositories/i_supervisor_repository.dart';
import 'domain/repositories/i_time_log_repository.dart';
import 'domain/repositories/i_contract_repository.dart';
import 'domain/repositories/i_notification_repository.dart';
// Usecases Auth
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/reset_password_usecase.dart';
import 'domain/usecases/auth/update_profile_usecase.dart';
import 'domain/usecases/auth/get_auth_state_changes_usecase.dart';
// Usecases Student
import 'domain/usecases/student/get_all_students_usecase.dart';
import 'domain/usecases/student/create_student_usecase.dart';
import 'domain/usecases/student/get_student_dashboard_usecase.dart';
// Usecases Supervisor
import 'domain/usecases/supervisor/get_all_supervisors_usecase.dart';
import 'domain/usecases/supervisor/get_supervisor_details_usecase.dart';
import 'domain/usecases/supervisor/get_all_students_for_supervisor_usecase.dart';
import 'domain/usecases/supervisor/get_student_details_for_supervisor_usecase.dart';
import 'domain/usecases/supervisor/create_student_by_supervisor_usecase.dart';
import 'domain/usecases/supervisor/update_student_by_supervisor_usecase.dart';
import 'domain/usecases/supervisor/delete_student_by_supervisor_usecase.dart';
import 'domain/usecases/supervisor/get_all_time_logs_for_supervisor_usecase.dart';
import 'domain/usecases/supervisor/approve_or_reject_time_log_usecase.dart';
import 'domain/usecases/contract/get_all_contracts_usecase.dart';
import 'domain/usecases/contract/create_contract_usecase.dart';
import 'domain/usecases/contract/update_contract_usecase.dart';
import 'domain/usecases/contract/delete_contract_usecase.dart';
import 'domain/usecases/supervisor/create_supervisor_usecase.dart';
import 'domain/usecases/supervisor/update_supervisor_usecase.dart';
import 'domain/usecases/supervisor/delete_supervisor_usecase.dart';
// Usecases TimeLog
import 'domain/usecases/time_log/clock_in_usecase.dart';
import 'domain/usecases/time_log/clock_out_usecase.dart';
import 'domain/usecases/time_log/get_time_logs_by_student_usecase.dart';
import 'domain/usecases/time_log/get_active_time_log_usecase.dart';
import 'domain/usecases/time_log/get_total_hours_by_student_usecase.dart';
// Usecases Contract
import 'domain/usecases/contract/get_contracts_for_student_usecase.dart';
import 'domain/usecases/contract/get_contracts_by_student_usecase.dart';
import 'domain/usecases/contract/get_contracts_by_supervisor_usecase.dart';
import 'domain/usecases/contract/get_active_contract_by_student_usecase.dart';
import 'domain/usecases/contract/get_contract_statistics_usecase.dart';
// BLoCs
import 'features/auth/bloc/auth_bloc.dart';
import 'features/student/bloc/student_bloc.dart';
import 'features/supervisor/bloc/supervisor_bloc.dart';
import 'features/shared/bloc/time_log_bloc.dart';
import 'features/shared/bloc/contract_bloc.dart';
import 'features/shared/bloc/notification_bloc.dart';
// Guards
import 'core/guards/auth_guard.dart';
// Pages
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/forgot_password_page.dart';
// Módulos
import 'features/auth/auth_module.dart';
import 'features/supervisor/supervisor_module.dart';
import 'features/student/student_module.dart';

class AppModule extends Module {
  final SharedPreferences? sharedPreferences;

  AppModule({this.sharedPreferences});

  @override
  List<Module> get imports => [];

  @override
  void binds(Injector i) {
    // =====================================================================
    // Dependencies Externas e Gerenciadores Locais
    // =====================================================================
    i.addLazySingleton<SupabaseClient>(() => Supabase.instance.client);
    i.addLazySingleton<CacheManager>(() => CacheManager());

    if (sharedPreferences != null) {
      i.addInstance<SharedPreferences>(sharedPreferences!);
      i.addLazySingleton<PreferencesManager>(() => PreferencesManager(i()));
    } else {
      i.addLazySingleton<InMemoryPreferencesManager>(
          () => InMemoryPreferencesManager());
      i.addLazySingleton<PreferencesManager>(() => PreferencesManagerMock(i()));
    }

    // =====================================================================
    // Camada de Dados (DataSources e Repositories)
    // =====================================================================
    i.addLazySingleton<IAuthDatasource>(() => AuthDatasource(i()));
    i.addLazySingleton<StudentDatasource>(() => StudentDatasource(i()));
    i.addLazySingleton<SupervisorDatasource>(() => SupervisorDatasource(i()));
    i.addLazySingleton<TimeLogDatasource>(() => TimeLogDatasource(i()));
    i.addLazySingleton<ContractDatasource>(() => ContractDatasource(i()));
    i.addLazySingleton<NotificationDatasource>(
        () => NotificationDatasource(i()));

    i.addLazySingleton<IAuthRepository>(
        () => AuthRepository(authDatasource: i(), preferencesManager: i()));
    i.addLazySingleton<IStudentRepository>(() => StudentRepository(i(), i()));
    i.addLazySingleton<ISupervisorRepository>(
        () => SupervisorRepository(i(), i(), i()));
    i.addLazySingleton<ITimeLogRepository>(() => TimeLogRepository(i()));
    i.addLazySingleton<IContractRepository>(() => ContractRepository(i()));
    i.addLazySingleton<INotificationRepository>(
        () => NotificationRepository(i()));

    // =====================================================================
    // Camada de Domínio (UseCases)
    // =====================================================================
    i.addLazySingleton(() => LoginUsecase(i()));
    i.addLazySingleton(() => RegisterUsecase(i()));
    i.addLazySingleton(() => LogoutUsecase(i()));
    i.addLazySingleton(() => GetCurrentUserUsecase(i()));
    i.addLazySingleton(() => ResetPasswordUsecase(i()));
    i.addLazySingleton(() => UpdateProfileUsecase(i()));
    i.addLazySingleton(() => GetAuthStateChangesUsecase(i()));
    i.addLazySingleton(() => GetAllStudentsUsecase(i()));
    i.addLazySingleton(() => CreateStudentUsecase(i()));
    i.addLazySingleton(() => GetStudentDashboardUsecase(i()));
    i.addLazySingleton(() => GetAllSupervisorsUsecase(i()));
    i.addLazySingleton(() => GetSupervisorDetailsUsecase(i()));
    i.addLazySingleton(() => GetAllStudentsForSupervisorUsecase(i()));
    i.addLazySingleton(() => GetStudentDetailsForSupervisorUsecase(i()));
    i.addLazySingleton(() => CreateStudentBySupervisorUsecase(i()));
    i.addLazySingleton(() => UpdateStudentBySupervisorUsecase(i()));
    i.addLazySingleton(() => DeleteStudentBySupervisorUsecase(i()));
    i.addLazySingleton(() => GetAllTimeLogsForSupervisorUsecase(i()));
    i.addLazySingleton(() => ApproveOrRejectTimeLogUsecase(i()));
    i.addLazySingleton(() => GetAllContractsUsecase(i()));
    i.addLazySingleton(() => CreateContractUsecase(i()));
    i.addLazySingleton(() => UpdateContractUsecase(i()));
    i.addLazySingleton(() => DeleteContractUsecase(i()));
    i.addLazySingleton(() => CreateSupervisorUsecase(i()));
    i.addLazySingleton(() => UpdateSupervisorUsecase(i()));
    i.addLazySingleton(() => DeleteSupervisorUsecase(i()));
    i.addLazySingleton(() => ClockInUsecase(i()));
    i.addLazySingleton(() => ClockOutUsecase(i()));
    i.addLazySingleton(() => GetTimeLogsByStudentUsecase(i()));
    i.addLazySingleton(() => GetActiveTimeLogUsecase(i()));
    i.addLazySingleton(() => GetTotalHoursByStudentUsecase(i()));
    i.addLazySingleton(() => GetContractsForStudentUsecase(i()));
    i.addLazySingleton(() => GetContractsByStudentUsecase(i()));
    i.addLazySingleton(() => GetContractsBySupervisorUsecase(i()));
    i.addLazySingleton(() => GetActiveContractByStudentUsecase(i()));
    i.addLazySingleton(() => GetContractStatisticsUsecase(i()));
    i.addLazySingleton(() => GetStudentByIdUsecase(i()));
    i.addLazySingleton(() => GetStudentByUserIdUsecase(i()));
    i.addLazySingleton(() => UpdateStudentUsecase(i()));
    i.addLazySingleton(() => GetStudentDetailsUsecase(i()));
    i.addLazySingleton(() => UpdateStudentProfileUsecase(i()));
    i.addLazySingleton(() => CheckInUsecase(i()));
    i.addLazySingleton(() => CheckOutUsecase(i()));
    i.addLazySingleton(() => GetStudentTimeLogsUsecase(i()));
    i.addLazySingleton(() => CreateTimeLogUsecase(i()));
    i.addLazySingleton(() => UpdateTimeLogUsecase(i()));
    i.addLazySingleton(() => DeleteTimeLogUsecase(i()));
    i.addLazySingleton(() => DeleteStudentUsecase(i()));
    i.addLazySingleton(() => GetStudentsBySupervisorUsecase(i()));

    // =====================================================================
    // Camada de Apresentação (BLoCs e Guards)
    // =====================================================================
    i.addLazySingleton(() => AuthBloc(
          loginUseCase: i(),
          logoutUseCase: i(),
          registerUseCase: i(),
          getCurrentUserUseCase: i(),
          getAuthStateChangesUseCase: i(),
          updateProfileUseCase: i(),
          resetPasswordUseCase: i(),
        ));
    i.addLazySingleton(() => StudentBloc(
          getStudentDashboardUsecase: i(),
        ));
    i.addLazySingleton(() => SupervisorBloc(
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
          deleteContractUsecase: i(),
          registerAuthUserUsecase: i(),
          getAllSupervisorsUsecase: i(),
          createSupervisorUsecase: i(),
          updateSupervisorUsecase: i(),
          deleteSupervisorUsecase: i(),
        ));
    i.addLazySingleton(() => TimeLogBloc(
          clockInUsecase: i(),
          clockOutUsecase: i(),
          getTimeLogsByStudentUsecase: i(),
          getActiveTimeLogUsecase: i(),
          getTotalHoursByStudentUsecase: i(),
        ));
    i.addLazySingleton(() => ContractBloc(
          getContractsByStudentUsecase: i(),
          getContractsBySupervisorUsecase: i(),
          getActiveContractByStudentUsecase: i(),
          createContractUsecase: i(),
          updateContractUsecase: i(),
          deleteContractUsecase: i(),
          getContractStatisticsUsecase: i(),
        ));
    i.addLazySingleton(() => NotificationBloc(
          notificationRepository: i(),
          authRepository: i(),
        ));
    i.addLazySingleton<AuthGuard>(() => AuthGuard(i()));
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const LoginPage());
    r.module('/auth', module: AuthModule());
    r.module('/student',
        module: StudentModule(), guards: [Modular.get<AuthGuard>()]);
    r.module('/supervisor',
        module: SupervisorModule(), guards: [Modular.get<AuthGuard>()]);
  }
}
