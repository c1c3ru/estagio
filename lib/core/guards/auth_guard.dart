import 'package:flutter_modular/flutter_modular.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

class AuthGuard extends RouteGuard {
  final AuthBloc _authBloc;

  AuthGuard(this._authBloc);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    final currentState = _authBloc.state;
    return currentState is AuthSuccess;
  }
}
