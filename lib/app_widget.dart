import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🟡 AppWidget: BUILD chamado');
    }
    return BlocProvider(
      create: (context) {
        if (kDebugMode) {
          print('🟡 AppWidget: Criando AuthBloc...');
        }
        final authBloc = Modular.get<AuthBloc>();
        if (kDebugMode) {
          print('🟡 AppWidget: AuthBloc obtido com sucesso');
        }
        // Inicializar o AuthBloc
        authBloc.add(const AuthInitializeRequested());
        if (kDebugMode) {
          print('🟡 AppWidget: AuthInitializeRequested adicionado');
        }
        return authBloc;
      },
      child: MaterialApp.router(
        title: 'Student Supervisor App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: Modular.routerConfig,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: child ??
                const Center(
                  child: CircularProgressIndicator(),
                ),
          );
        },
      ),
    );
  }
}
