import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/shared/bloc/time_log_bloc.dart';
import 'features/shared/bloc/contract_bloc.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final AuthBloc _authBloc;
  late final TimeLogBloc _timeLogBloc;
  late final ContractBloc _contractBloc;
  
  @override
  void initState() {
    super.initState();
    _authBloc = Modular.get<AuthBloc>();
    _timeLogBloc = Modular.get<TimeLogBloc>();
    _contractBloc = Modular.get<ContractBloc>();
    
    // Inicializar apenas uma vez
    _authBloc.add(const AuthInitializeRequested());
  }
  
  @override
  void dispose() {
    // Não fechar os BLoCs aqui pois eles são gerenciados pelo Modular
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
      child: MaterialApp.router(
        title: 'Student Supervisor App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: Modular.routerConfig,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
