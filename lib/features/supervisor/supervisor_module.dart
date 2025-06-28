// lib/features/supervisor/supervisor_module.dart

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Pages
import 'pages/supervisor_home_page.dart';
import 'pages/supervisor_time_approval_page.dart';
import 'pages/supervisor_profile_page.dart';
import 'pages/student_details_page.dart';
import 'pages/student_edit_page.dart';

// BLoCs
import 'bloc/supervisor_bloc.dart';

class SupervisorModule extends Module {
  @override
  void binds(Injector i) {
    // Todos os binds estão registrados globalmente no AppModule
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
