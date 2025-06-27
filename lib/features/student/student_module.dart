// lib/features/student/student_module.dart
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/features/student/bloc/student_bloc.dart';
import 'package:gestao_de_estagio/features/student/pages/student_home_page.dart';
import 'package:gestao_de_estagio/features/student/pages/student_profile_page.dart';
import 'package:gestao_de_estagio/features/student/pages/student_time_log_page.dart';
import 'package:gestao_de_estagio/features/student/pages/contract_page.dart';
import 'package:gestao_de_estagio/features/student/pages/student_colleagues_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Para SupabaseClient

// Shared Bloc
import '../../features/shared/bloc/contract_bloc.dart';

// Datasources
import '../../data/datasources/supabase/student_datasource.dart';
import '../../data/datasources/supabase/time_log_datasource.dart';
import '../../data/datasources/supabase/contract_datasource.dart';

// Repositories (Implementações)
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/time_log_repository.dart';
import '../../data/repositories/contract_repository.dart';

// Repository Interfaces (do Domínio)
import '../../domain/repositories/i_student_repository.dart';
import '../../domain/repositories/i_time_log_repository.dart';
import '../../domain/repositories/i_contract_repository.dart';

// Usecases
// Student Usecases
import '../../domain/usecases/student/get_student_details_usecase.dart';
import '../../domain/usecases/student/update_student_profile_usecase.dart';
import '../../domain/usecases/student/check_in_usecase.dart';
import '../../domain/usecases/student/check_out_usecase.dart';
// TimeLog Usecases (usados pelo StudentBloc, podem ser do Student ou TimeLog)
import '../../domain/usecases/student/get_student_time_logs_usecase.dart';
import '../../domain/usecases/student/create_time_log_usecase.dart';
import '../../domain/usecases/student/update_time_log_usecase.dart';
import '../../domain/usecases/student/delete_time_log_usecase.dart';
// Contract Usecases
import '../../domain/usecases/contract/get_contracts_for_student_usecase.dart';
import '../../domain/usecases/contract/get_contracts_by_student_usecase.dart';
import '../../domain/usecases/contract/get_contracts_by_supervisor_usecase.dart';
import '../../domain/usecases/contract/get_active_contract_by_student_usecase.dart';
import '../../domain/usecases/contract/create_contract_usecase.dart';
import '../../domain/usecases/contract/update_contract_usecase.dart';
import '../../domain/usecases/contract/delete_contract_usecase.dart';
import '../../domain/usecases/contract/get_contract_statistics_usecase.dart';
// Student CRUD Usecases
import '../../domain/usecases/student/get_all_students_usecase.dart';
import '../../domain/usecases/student/get_student_by_id_usecase.dart';
import '../../domain/usecases/student/get_student_by_user_id_usecase.dart';
import '../../domain/usecases/student/create_student_usecase.dart';
import '../../domain/usecases/student/update_student_usecase.dart';
import '../../domain/usecases/student/delete_student_usecase.dart';
import '../../domain/usecases/student/get_students_by_supervisor_usecase.dart';
import '../../domain/usecases/student/get_student_dashboard_usecase.dart';

class StudentModule extends Module {
  @override
  void binds(Injector i) {
    // Datasources - usar as implementações diretamente
    i.add<StudentDatasource>(() => StudentDatasource(i.get<SupabaseClient>()));
    i.add<TimeLogDatasource>(() => TimeLogDatasource(i.get<SupabaseClient>()));
    i.add<ContractDatasource>(
        () => ContractDatasource(i.get<SupabaseClient>()));

    // Repositories
    i.add<IStudentRepository>(() => StudentRepository(
          i.get<StudentDatasource>(),
          i.get<TimeLogDatasource>(), // StudentRepository usa TimeLogDatasource
        ));

    // Registar ITimeLogRepository e IContractRepository se os usecases do StudentBloc
    // dependerem diretamente deles, e não apenas através do IStudentRepository.
    i.add<ITimeLogRepository>(
        () => TimeLogRepository(i.get<TimeLogDatasource>()));
    i.add<IContractRepository>(
        () => ContractRepository(i.get<ContractDatasource>()));

    // Usecases
    i.add<GetStudentDetailsUsecase>(
        () => GetStudentDetailsUsecase(i.get<IStudentRepository>()));
    i.add<UpdateStudentProfileUsecase>(
        () => UpdateStudentProfileUsecase(i.get<IStudentRepository>()));
    i.add<CheckInUsecase>(() => CheckInUsecase(i.get<IStudentRepository>()));
    i.add<CheckOutUsecase>(() => CheckOutUsecase(i.get<IStudentRepository>()));

    // Usecases de TimeLog (usando IStudentRepository ou ITimeLogRepository)
    i.add<GetStudentTimeLogsUsecase>(
        () => GetStudentTimeLogsUsecase(i.get<IStudentRepository>()));
    i.add<CreateTimeLogUsecase>(
        () => CreateTimeLogUsecase(i.get<IStudentRepository>()));
    i.add<UpdateTimeLogUsecase>(
        () => UpdateTimeLogUsecase(i.get<IStudentRepository>()));
    i.add<DeleteTimeLogUsecase>(
        () => DeleteTimeLogUsecase(i.get<IStudentRepository>()));

    // Usecases de Contrato
    i.add<GetContractsForStudentUsecase>(
        () => GetContractsForStudentUsecase(i.get<IContractRepository>()));
    i.add<GetContractsByStudentUsecase>(
        () => GetContractsByStudentUsecase(i.get<IContractRepository>()));
    i.add<GetContractsBySupervisorUsecase>(
        () => GetContractsBySupervisorUsecase(i.get<IContractRepository>()));
    i.add<GetActiveContractByStudentUsecase>(
        () => GetActiveContractByStudentUsecase(i.get<IContractRepository>()));
    i.add<CreateContractUsecase>(
        () => CreateContractUsecase(i.get<IContractRepository>()));
    i.add<UpdateContractUsecase>(
        () => UpdateContractUsecase(i.get<IContractRepository>()));
    i.add<DeleteContractUsecase>(
        () => DeleteContractUsecase(i.get<IContractRepository>()));
    i.add<GetContractStatisticsUsecase>(
        () => GetContractStatisticsUsecase(i.get<IContractRepository>()));

    // Student CRUD Usecases
    i.add<GetAllStudentsUsecase>(
        () => GetAllStudentsUsecase(i.get<IStudentRepository>()));
    i.add<GetStudentByIdUsecase>(
        () => GetStudentByIdUsecase(i.get<IStudentRepository>()));
    i.add<GetStudentByUserIdUsecase>(
        () => GetStudentByUserIdUsecase(i.get<IStudentRepository>()));
    i.add<CreateStudentUsecase>(
        () => CreateStudentUsecase(i.get<IStudentRepository>()));
    i.add<UpdateStudentUsecase>(
        () => UpdateStudentUsecase(i.get<IStudentRepository>()));
    i.add<DeleteStudentUsecase>(
        () => DeleteStudentUsecase(i.get<IStudentRepository>()));
    i.add<GetStudentsBySupervisorUsecase>(
        () => GetStudentsBySupervisorUsecase(i.get<IStudentRepository>()));
    i.add<GetStudentDashboardUsecase>(
        () => GetStudentDashboardUsecase(i.get<IStudentRepository>()));

    // BLoC
    i.add<StudentBloc>(() => StudentBloc(
          getStudentDashboardUsecase: i.get<GetStudentDashboardUsecase>(),
        ));

    // Adicionar ContractBloc para ContractPage
    i.add<ContractBloc>(() => ContractBloc(
          getContractsByStudentUsecase: i.get<GetContractsByStudentUsecase>(),
          getContractsBySupervisorUsecase:
              i.get<GetContractsBySupervisorUsecase>(),
          getActiveContractByStudentUsecase:
              i.get<GetActiveContractByStudentUsecase>(),
          createContractUsecase: i.get<CreateContractUsecase>(),
          updateContractUsecase: i.get<UpdateContractUsecase>(),
          deleteContractUsecase: i.get<DeleteContractUsecase>(),
          getContractStatisticsUsecase: i.get<GetContractStatisticsUsecase>(),
        ));
  }

  @override
  void routes(RouteManager r) {
    // A rota base para este módulo é '/student' (definido no AppModule)

    // Rota para o dashboard/home do estudante (ex: /student/home ou /student/)
    r.child(
      Modular
          .initialRoute, // Equivalente a '/' dentro deste módulo, resultando em '/student/'
      child: (_) => BlocProvider(
        create: (_) => Modular.get<StudentBloc>(),
        child: const StudentHomePage(),
      ),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de registo de horas (Time Log)
    r.child(
      '/time-log',
      child: (_) => const StudentTimeLogPage(),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de perfil do estudante
    r.child(
      '/profile',
      child: (_) => const StudentProfilePage(),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de contratos
    r.child(
      '/contracts',
      child: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: Modular.get<StudentBloc>()),
          BlocProvider.value(value: Modular.get<ContractBloc>()),
        ],
        child: ContractPage(
          studentId: (r.args.data != null &&
                  r.args.data is Map &&
                  r.args.data['studentId'] != null &&
                  (r.args.data['studentId'] as String).isNotEmpty)
              ? r.args.data['studentId'] as String
              : null,
        ),
      ),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de colegas online
    r.child(
      '/colleagues',
      child: (_) => const StudentColleaguesPage(),
      transition: TransitionType.fadeIn,
    );
  }
}
