import 'package:flutter_modular/flutter_modular.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

class AuthGuard extends RouteGuard {
  final AuthBloc _authBloc;

  AuthGuard(this._authBloc);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    // Check if user is authenticated
    final currentState = _authBloc.state;

    if (currentState is AuthSuccess) {
      return true;
    }

    // If not authenticated, redirect to login
    Modular.to.navigate('/login');
    return false;
  }
}
