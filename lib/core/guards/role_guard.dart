// lib/core/guards/role_guard.dart
import 'dart:async';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart';

/// Um RouteGuard que verifica se o utilizador autenticado tem um dos papéis permitidos.
/// Se não estiver autenticado ou não tiver o papel correto, redireciona.
class RoleGuard extends RouteGuard {
  final List<UserRole> allowedRoles;

  RoleGuard(this.allowedRoles)
      : super(
            redirectTo:
                '/auth/unauthorized'); // Rota para não autorizado ou de volta ao login

  @override
  FutureOr<bool> canActivate(String path, ParallelRoute route) {
    final authBloc = Modular.get<AuthBloc>();
    final currentState = authBloc.state;

    if (currentState is AuthSuccess) {
      // Utilizador está autenticado, verifica o papel
      final UserRole currentUserRole = currentState.user.role;

      if (allowedRoles.contains(currentUserRole)) {
        // O papel do utilizador está na lista de papéis permitidos
        return true;
      } else {
        // Papel não permitido, redireciona para '/auth/unauthorized'
        // Ou, se preferir, redirecione para uma rota base segura como '/auth/login'
        // ou para um dashboard específico do papel atual do utilizador se fizer sentido.
        Modular.to.navigate(
            '/auth/unauthorized'); // Exemplo de rota para não autorizado
        return false;
      }
    } else {
      // Não autenticado, redireciona para login (o AuthGuard já faria isso se aplicado antes)
      // Mas é bom ter a verificação aqui também como segurança.
      Modular.to.navigate('/auth/login');
      return false;
    }
  }
}

// Rota e Página de Exemplo para Não Autorizado (a ser criada no AuthModule)
// Modular.to.navigate('/auth/unauthorized');
//
// Exemplo de como definir a rota no AuthModule:
// r.child('/unauthorized', child: (_) => const UnauthorizedPage());
//
// E a UnauthorizedPage:
// class UnauthorizedPage extends StatelessWidget {
//   const UnauthorizedPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Acesso Negado')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.lock_outline, size: 60, color: Colors.red),
//             const SizedBox(height: 20),
//             const Text('Você não tem permissão para aceder a esta página.', textAlign: TextAlign.center),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Modular.to.navigate('/auth/login'), // Ou para a home do utilizador
//               child: const Text('Voltar ao Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
