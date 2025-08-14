// lib/features/student/student_module.dart

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Pages
import 'pages/student_home_page.dart';
import 'pages/student_time_log_page.dart';
import 'pages/student_profile_page.dart';
import 'pages/student_colleagues_page.dart';
import 'pages/contract_page.dart';
import 'pages/student_reports_page.dart';

// BLoCs
import 'bloc/student_bloc.dart';
import '../../features/shared/bloc/contract_bloc.dart';

class StudentModule extends Module {
  @override
  void binds(Injector i) {
    // Todos os binds estão registrados globalmente no AppModule
  }

  @override
  void routes(RouteManager r) {
    // A rota base para este módulo é '/student' (definido no AppModule)

    // Rota para o dashboard/home do estudante (ex: /student/home ou /student/)
    r.child(
      Modular
          .initialRoute, // Equivalente a '/' dentro deste módulo, resultando em '/student/'
      child: (_) => BlocProvider.value(
        value: Modular.get<StudentBloc>(),
        child: const StudentHomePage(),
      ),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de registo de horas (Time Log)
    r.child(
      '/time-log',
      child: (_) => BlocProvider.value(
        value: Modular.get<StudentBloc>(),
        child: const StudentTimeLogPage(),
      ),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de perfil do estudante
    r.child(
      '/profile',
      child: (_) => BlocProvider.value(
        value: Modular.get<StudentBloc>(),
        child: const StudentProfilePage(),
      ),
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
      child: (_) => BlocProvider.value(
        value: Modular.get<StudentBloc>(),
        child: const StudentColleaguesPage(),
      ),
      transition: TransitionType.fadeIn,
    );

    // Rota para a página de relatórios
    r.child(
      '/reports',
      child: (_) => BlocProvider.value(
        value: Modular.get<StudentBloc>(),
        child: const StudentReportsPage(),
      ),
      transition: TransitionType.fadeIn,
    );
  }
}
