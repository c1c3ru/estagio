import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import 'package:flutter_modular/flutter_modular.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    print('🟢 StudentHomePage: initState chamado');

    // Obter o ID do usuário autenticado
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      print('🟢 StudentHomePage: Usuário autenticado ID: $userId');
      // Carregar dados do dashboard
      BlocProvider.of<StudentBloc>(context)
          .add(LoadStudentDashboardDataEvent(userId: userId));
    } else {
      print('🟢 StudentHomePage: Usuário não autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🟢 StudentHomePage: BUILD chamado');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Garante que a navegação seja feita fora do build
          Future.microtask(() => Modular.to.navigate('/login/'));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Página Inicial do Estudante'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<AuthBloc>(context)
                    .add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            print('🟢 StudentHomePage: BlocBuilder - Estado: $state');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Página Inicial do Estudante',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estado atual: ${state.runtimeType}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  if (state is StudentLoading)
                    const CircularProgressIndicator()
                  else if (state is StudentDashboardLoadSuccess)
                    Column(
                      children: [
                        // Indicador de dados mock (se aplicável)
                        if (state.student.fullName == 'Cicero Silva' &&
                            state.student.registrationNumber == '202300123456')
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Usando dados de demonstração. Execute o script SQL no Supabase para dados reais.',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Text(
                          'Bem-vindo, ${state.student.fullName}!',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Card com informações básicas
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informações do Estudante',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Matrícula: ${state.student.registrationNumber}'),
                                Text('Curso: ${state.student.course}'),
                                Text(
                                    'Orientador: ${state.student.advisorName}'),
                                Text(
                                    'Turno das Aulas: ${state.student.classShift.displayName}'),
                                Text(
                                    'Turno do Estágio: ${state.student.internshipShift.displayName}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card com progresso do estágio
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Progresso do Estágio',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Horas Concluídas: ${state.student.totalHoursCompleted}'),
                                Text(
                                    'Horas Necessárias: ${state.student.totalHoursRequired}'),
                                Text(
                                    'Meta Semanal: ${state.student.weeklyHoursTarget} horas'),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: state.student.progressPercentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${state.student.progressPercentage.toStringAsFixed(1)}% concluído',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card com estatísticas de tempo
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estatísticas de Tempo',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Esta Semana: ${state.timeStats.hoursThisWeek} horas'),
                                Text(
                                    'Este Mês: ${state.timeStats.hoursThisMonth} horas'),
                                if (state.timeStats.activeTimeLog != null)
                                  const Text(
                                    'Status: Trabalhando agora',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold),
                                  )
                                else
                                  const Text(
                                    'Status: Não está trabalhando',
                                    style: TextStyle(
                                        color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Menu de funcionalidades
                      ],
                    )
                  else if (state is StudentOperationFailure)
                    Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Erro ao carregar dados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (state.message.contains('test_data.sql'))
                          Column(
                            children: [
                              const Text(
                                'Para resolver este problema:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '1. Vá para o Supabase Dashboard\n'
                                '2. Acesse o SQL Editor\n'
                                '3. Execute o script test_data.sql\n'
                                '4. Tente novamente',
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<StudentBloc>(context).add(
                                      const LoadStudentDashboardDataEvent(
                                          userId:
                                              'd941ae1d-e83f-4215-bdc7-da5f9cf139c0'));
                                },
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              final authState =
                                  BlocProvider.of<AuthBloc>(context).state;
                              if (authState is AuthAuthenticated) {
                                BlocProvider.of<StudentBloc>(context).add(
                                    LoadStudentDashboardDataEvent(
                                        userId: authState.user.id));
                              }
                            },
                            child: const Text('Tentar novamente'),
                          ),
                      ],
                    )
                  else
                    const Text(
                      'Carregando dados...',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: 0, // Início
          onTap: (index) {
            switch (index) {
              case 0:
                // Já está na home
                break;
              case 1:
                Modular.to.pushNamed('/student/contracts');
                break;
              case 2:
                Modular.to.pushNamed('/student/time-log');
                break;
              case 3:
                Modular.to.pushNamed('/student/colleagues');
                break;
              case 4:
                Modular.to.pushNamed('/student/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Contratos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Registrar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Colegas',
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
