// lib/features/auth/auth_module.dart
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/features/auth/pages/login_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/register_type_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/email_confirmation_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/forgot_password_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/supervisor_register_page.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';

class AuthModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // Supabase Client já registrado globalmente no AppModule
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider.value(
        value: Modular.get<AuthBloc>(),
        child: const LoginPage(),
      ),
    );
    r.child('/register', child: (context) => BlocProvider.value(
      value: Modular.get<AuthBloc>(),
      child: const RegisterTypePage(),
    ));
    r.child('/forgot-password', child: (context) => BlocProvider.value(
      value: Modular.get<AuthBloc>(),
      child: const ForgotPasswordPage(),
    ));
    r.child('/register-supervisor', child: (context) => BlocProvider.value(
      value: Modular.get<AuthBloc>(),
      child: const SupervisorRegisterPage(),
    ));
    r.child('/email-confirmation',
        child: (context) => BlocProvider.value(
          value: Modular.get<AuthBloc>(),
          child: EmailConfirmationPage(
            email: r.args.data as String,
          ),
        ));
  }
}
