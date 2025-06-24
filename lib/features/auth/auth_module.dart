// lib/features/auth/auth_module.dart
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/auth/pages/forgot_password_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/login_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/register_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/email_confirmation_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // Supabase Client
    i.addInstance(Supabase.instance.client);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const LoginPage());
    r.child('/register', child: (context) => const RegisterPage());
    r.child('/forgot-password', child: (context) => const ForgotPasswordPage());
    r.child('/email-confirmation',
        child: (context) => EmailConfirmationPage(
              email: r.args.data as String,
            ));
  }
}
