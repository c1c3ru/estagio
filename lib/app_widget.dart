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
    try {
      return BlocProvider(
        create: (context) {
          final authBloc = Modular.get<AuthBloc>();
          // Inicializar o AuthBloc
          authBloc.add(const AuthInitializeRequested());
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
            // Garantir que sempre temos algo para renderizar
            final widgetToShow = child ??
                const Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Carregando aplicação...'),
                        SizedBox(height: 8),
                        Text(
                            'Se esta tela persistir, verifique o console para erros'),
                      ],
                    ),
                  ),
                );

            return widgetToShow;
          },
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('🔴 AppWidget: Erro durante build: $e');
        print('🔴 Stack trace: $stackTrace');
      }
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erro ao inicializar app: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Tentar recarregar
                    Modular.to.navigate('/login');
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
