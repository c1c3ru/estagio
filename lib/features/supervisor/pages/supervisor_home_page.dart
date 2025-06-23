import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({super.key});

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> {
  @override
  void initState() {
    super.initState();
    // Carregar dados do dashboard
    Modular.get<SupervisorBloc>().add(LoadSupervisorDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Garante que a navegação seja feita fora do build
          Future.microtask(() => Modular.to.navigate('/login/'));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Área do Supervisor'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Modular.to.pushNamed('/notifications');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<AuthBloc>(context)
                    .add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<SupervisorBloc, SupervisorState>(
          builder: (context, state) {
            if (state is SupervisorLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SupervisorDashboardLoadSuccess) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(
                                    Icons.supervisor_account,
                                    color: AppColors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Bem-vindo, Supervisor!',
                                        style: AppTextStyles.h6,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Dashboard Ativo',
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics Cards
                    const Text(
                      'Estatísticas',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Estudantes',
                            value: '${state.stats.totalStudents}',
                            icon: Icons.people,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Ativos',
                            value: '${state.stats.activeStudents}',
                            icon: Icons.access_time,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Contratos',
                            value: '${state.contracts.length}',
                            icon: Icons.description,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Pendentes',
                            value: '${state.pendingApprovals.length}',
                            icon: Icons.pending,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    const Text(
                      'Ações Rápidas',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(
                                Icons.people,
                                color: AppColors.primary,
                              ),
                            ),
                            title: const Text('Gerenciar Estudantes'),
                            subtitle:
                                const Text('Visualizar e editar estudantes'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navegar para lista de estudantes
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Funcionalidade em desenvolvimento'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.secondaryLight,
                              child: Icon(
                                Icons.access_time,
                                color: AppColors.secondary,
                              ),
                            ),
                            title: const Text('Aprovar Horas'),
                            subtitle: Text(
                                '${state.pendingApprovals.length} registos pendentes'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Modular.to.pushNamed('/supervisor/time-approval');
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.warning.withOpacity(0.2),
                              child: const Icon(
                                Icons.description,
                                color: AppColors.warning,
                              ),
                            ),
                            title: const Text('Contratos'),
                            subtitle: Text(
                                '${state.contracts.length} contratos ativos'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navegar para contratos
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Funcionalidade em desenvolvimento'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is SupervisorOperationFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar dados',
                      style: AppTextStyles.h6.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Modular.get<SupervisorBloc>()
                            .add(LoadSupervisorDashboardDataEvent());
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: 0, // Página inicial
          onTap: (index) {
            switch (index) {
              case 0: // Início
                // Já estamos na página inicial
                break;
              case 1: // Estudantes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Gerenciamento de estudantes em desenvolvimento'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                break;
              case 2: // Relatórios
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Relatórios em desenvolvimento'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                break;
              case 3: // Perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil do supervisor em desenvolvimento'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Estudantes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Relatórios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                Text(
                  value,
                  style: AppTextStyles.h4.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
