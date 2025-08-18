import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/shared/bloc/time_log_bloc.dart';
import 'features/shared/bloc/contract_bloc.dart';
import 'core/theme/theme_service.dart';
import 'core/services/notification_service.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final AuthBloc _authBloc;
  late final TimeLogBloc _timeLogBloc;
  late final ContractBloc _contractBloc;
  StreamSubscription? _notificationSub;
  
  @override
  void initState() {
    super.initState();
    _authBloc = Modular.get<AuthBloc>();
    _timeLogBloc = Modular.get<TimeLogBloc>();
    _contractBloc = Modular.get<ContractBloc>();
    
    // Inicializar apenas uma vez
    _authBloc.add(const AuthInitializeRequested());

    // Inicializa serviço de notificações e escuta eventos para atualizar UI do estudante
    final notificationService = NotificationService();
    notificationService.initialize().then((_) {
      _notificationSub?.cancel();
      _notificationSub = notificationService.notificationStream.listen((n) {
        // Se a notificação estiver relacionada a TimeLog aprovado/rejeitado,
        // dispare o reload dos registros do aluno correspondente
        final type = n.type;
        final payload = n.payload ?? const {};
        final studentId = payload['studentId'] as String?;

        final isTimeLogUpdate = type == NotificationType.timeLogApproved ||
            type == NotificationType.timeLogRejected ||
            (payload['action'] == 'view_timelog');

        if (isTimeLogUpdate && studentId != null && studentId.isNotEmpty) {
          _timeLogBloc.add(
            TimeLogLoadByStudentRequested(studentId: studentId),
          );
        }
      });
    });
  }
  
  @override
  void dispose() {
    // Não fechar os BLoCs aqui pois eles são gerenciados pelo Modular
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<TimeLogBloc>.value(value: _timeLogBloc),
        BlocProvider<ContractBloc>.value(value: _contractBloc),
      ],
      child: ChangeNotifierProvider<ThemeService>.value(
        value: ThemeService(),
        child: Consumer<ThemeService>(
          builder: (context, themeService, _) {
            return MaterialApp.router(
              title: 'Student Supervisor App',
              theme: themeService.lightTheme,
              darkTheme: themeService.darkTheme,
              themeMode: themeService.themeMode,
              routerConfig: Modular.routerConfig,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('pt', 'BR'),
                Locale('en', 'US'),
              ],
            );
          },
        ),
      ),
    );
  }
}
