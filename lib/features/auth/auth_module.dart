// lib/features/auth/auth_module.dart
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/auth/pages/forgot_password_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/login_page.dart';
import 'package:gestao_de_estagio/features/auth/pages/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Datasources
import '../../data/datasources/supabase/auth_datasource.dart';
import '../../data/datasources/local/preferences_manager.dart';

// Repositories
import '../../data/repositories/auth_repository.dart';

// Usecases
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/get_auth_state_changes_usecase.dart';
import 'bloc/auth_bloc.dart';

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
  }
}
