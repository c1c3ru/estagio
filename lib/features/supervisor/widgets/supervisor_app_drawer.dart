import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_event.dart';

// É uma boa prática gerir as suas rotas num ficheiro dedicado.
// Exemplo: lib/core/routes/app_routes.dart
class SupervisorRoutes {
  static const String dashboard = '/supervisor/';
  static const String team = '/supervisor/team';
  static const String reports = '/supervisor/reports';
  static const String login = '/login';

  // Lista das rotas principais para facilitar a indexação em barras de navegação
  static const List<String> mainRoutes = [dashboard, team, reports];
}

/// Calcula o índice do item de navegação ativo com base no caminho da rota atual.
int _calculateCurrentIndex(String currentPath) {
  // Encontra o índice da rota principal que corresponde ao início do caminho atual.
  // Isto garante que as sub-rotas (ex: /team/student-details) ainda selecionam o separador principal (ex: /team).
  final index = SupervisorRoutes.mainRoutes
      .indexWhere((route) => currentPath.startsWith(route));

  // Retorna o índice encontrado, ou 0 (Dashboard) se nenhuma correspondência for encontrada.
  return index != -1 ? index : 0;
}

// Para usar, adicione `drawer: const SupervisorAppDrawer()` ao seu Scaffold.
class SupervisorAppDrawer extends StatelessWidget {
  const SupervisorAppDrawer({super.key, required int currentIndex});

  @override
  Widget build(BuildContext context) {
    // Pode obter os dados do utilizador atualmente autenticado a partir de um BLoC ou de outro gestor de estado.
    // final user = Modular.get<AuthBloc>().state.user;
    const String supervisorName = 'Nome do Supervisor';
    const String supervisorEmail = 'supervisor@email.com';
    final int currentIndex =
        _calculateCurrentIndex(Modular.routerDelegate.path);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text(
              supervisorName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(supervisorEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              // Pode usar uma NetworkImage para a foto de perfil do utilizador
              // backgroundImage: NetworkImage(user.profilePictureUrl ?? ''),
              child: Text(
                'S', // Inicial de placeholder
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A), // Usando um tom de azul específico
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            isSelected: currentIndex == 0,
            onTap: () => Modular.to.navigate('/supervisor/'),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Perfil',
            isSelected: currentIndex == 1,
            onTap: () => Modular.to.navigate('/supervisor/profile'),
          ),
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Sair',
            isSelected: false,
            onTap: () {
              Modular.get<AuthBloc>().add(LogoutRequested());
              Modular.to.navigate('/login');
            },
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir os itens do menu, reduzindo a duplicação de código.
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? Colors.blue.shade800 : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
    );
  }
}

// Para usar, adicione `bottomNavigationBar: const SupervisorBottomNavBar()` ao seu Scaffold.
class SupervisorBottomNavBar extends StatelessWidget {
  const SupervisorBottomNavBar({super.key, required int currentIndex});

  @override
  Widget build(BuildContext context) {
    final int currentIndex =
        _calculateCurrentIndex(Modular.routerDelegate.path);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Modular.to.navigate('/supervisor/');
            break;
          case 1:
            Modular.to.navigate('/supervisor/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
