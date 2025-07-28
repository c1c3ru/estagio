import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../widgets/student_list_widget.dart';
import '../widgets/student_form_dialog.dart';
import '../../../domain/entities/filter_students_params.dart';
import '../../../core/enums/student_status.dart';
import 'package:flutter/foundation.dart';
import '../../../core/animations.dart';

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
    BlocProvider.of<SupervisorBloc>(context, listen: false)
        .add(LoadSupervisorDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Garante que a navegação seja feita fora do build
          Future.microtask(() => Modular.to.navigate('/login'));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard do Supervisor'),
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
                BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
              },
            ),
          ],
        ),
        body: BlocListener<SupervisorBloc, SupervisorState>(
          listener: (context, state) {
            if (state is SupervisorOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is SupervisorOperationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<SupervisorBloc, SupervisorState>(
            builder: (context, state) {
              if (kDebugMode) {
                print(
                    '🟡 SupervisorHomePage: Estado atual: ${state.runtimeType}');
              }

              if (state is SupervisorLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SupervisorDashboardLoadSuccess) {
                if (kDebugMode) {
                  print(
                      '🟡 SupervisorHomePage: Renderizando dashboard com ${state.students.length} estudantes');
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Lottie.asset(
                        AssetAnimations.supervisorPageAnimation,
                        height: 120,
                        repeat: true,
                      ),
                      const SizedBox(height: 16),
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
                        'Estatísticas de Contratos',
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total',
                              value: '${state.contracts.length}',
                              icon: Icons.description,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Ativos',
                              value:
                                  '${state.contracts.where((c) => c.endDate.isAfter(DateTime.now())).length}',
                              icon: Icons.check_circle_outline,
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
                              title: 'A vencer (30d)',
                              value: '${state.stats.expiringContractsSoon}',
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Encerrados',
                              value:
                                  '${state.contracts.where((c) => c.endDate.isBefore(DateTime.now())).length}',
                              icon: Icons.cancel_outlined,
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
                                Modular.to.pushNamed('/supervisor/students');
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
                                Modular.to
                                    .pushNamed('/supervisor/time-approval');
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
                                Modular.to.pushNamed('/supervisor/contracts');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estudantes', style: AppTextStyles.h6),
                          IconButton(
                            icon: const Icon(Icons.filter_alt_outlined),
                            tooltip: 'Filtrar',
                            onPressed: () async {
                              if (!mounted) return;
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => _StudentFilterSheet(
                                  onApply: (params) {
                                    BlocProvider.of<SupervisorBloc>(context,
                                            listen: false)
                                        .add(FilterStudentsEvent(
                                            params: params));
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StudentListWidget(
                        students: state.students,
                        onEdit: (student) async {
                          if (!mounted) return;
                          await showDialog(
                            context: context,
                            builder: (context) => StudentFormDialog(
                              isEdit: true,
                              initialStudent: student,
                              onSubmit: (editedStudent, _, __) {
                                BlocProvider.of<SupervisorBloc>(context,
                                        listen: false)
                                    .add(
                                  UpdateStudentBySupervisorEvent(
                                      studentData: editedStudent),
                                );
                              },
                            ),
                          );
                        },
                        onDelete: (student) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remover estudante'),
                              content: Text(
                                  'Tem certeza que deseja remover o estudante "${student.fullName}"? Esta ação não pode ser desfeita.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Remover',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (!mounted) return;
                          if (confirm == true) {
                            BlocProvider.of<SupervisorBloc>(context,
                                    listen: false)
                                .add(DeleteStudentBySupervisorEvent(
                                    studentId: student.id));
                          }
                        },
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!mounted) return;
            await showDialog(
              context: context,
              builder: (context) => StudentFormDialog(
                isEdit: false,
                onSubmit: (student, email, password) {
                  BlocProvider.of<SupervisorBloc>(context, listen: false).add(
                    CreateStudentBySupervisorEvent(
                      studentData: student,
                      initialEmail: email,
                      initialPassword: password ?? '',
                    ),
                  );
                },
              ),
            );
          },
          backgroundColor: AppColors.primary,
          tooltip: 'Adicionar Estudante',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: 0, // Página inicial
          onTap: (index) {
            switch (index) {
              case 0: // Início
                Modular.to.navigate('/supervisor/');
                break;
              case 1: // Aprovar Horas
                Modular.to.navigate('/supervisor/time-approval');
                break;
              case 2: // Perfil
                Modular.to.navigate('/supervisor/profile');
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
              label: 'Aprovar Horas',
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

class _StudentFilterSheet extends StatefulWidget {
  final void Function(FilterStudentsParams params) onApply;
  const _StudentFilterSheet({required this.onApply});

  @override
  State<_StudentFilterSheet> createState() => _StudentFilterSheetState();
}

class _StudentFilterSheetState extends State<_StudentFilterSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  StudentStatus? _selectedStatus;
  bool? _hasActiveContract;
  DateTime? _startDateFrom;
  DateTime? _startDateTo;
  DateTime? _endDateFrom;
  DateTime? _endDateTo;

  Future<void> _pickDate(BuildContext context, DateTime? initial,
      Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filtros Avançados',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Nome ou matrícula',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<StudentStatus?>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem<StudentStatus?>(
                      value: null, child: Text('Todos')),
                  ...StudentStatus.values
                      .map((status) => DropdownMenuItem<StudentStatus?>(
                            value: status,
                            child: Text(status.displayName),
                          )),
                ],
                onChanged: (v) => setState(() => _selectedStatus = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<bool>(
                value: _hasActiveContract,
                decoration: const InputDecoration(labelText: 'Contrato ativo'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(value: true, child: Text('Apenas ativos')),
                  DropdownMenuItem(
                      value: false, child: Text('Apenas encerrados')),
                ],
                onChanged: (v) => setState(() => _hasActiveContract = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: 'Início de (contrato)'),
                      controller: TextEditingController(
                          text: _startDateFrom != null
                              ? _formatDate(_startDateFrom!)
                              : ''),
                      onTap: () => _pickDate(context, _startDateFrom,
                          (d) => setState(() => _startDateFrom = d)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Início até'),
                      controller: TextEditingController(
                          text: _startDateTo != null
                              ? _formatDate(_startDateTo!)
                              : ''),
                      onTap: () => _pickDate(context, _startDateTo,
                          (d) => setState(() => _startDateTo = d)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Término de'),
                      controller: TextEditingController(
                          text: _endDateFrom != null
                              ? _formatDate(_endDateFrom!)
                              : ''),
                      onTap: () => _pickDate(context, _endDateFrom,
                          (d) => setState(() => _endDateFrom = d)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Término até'),
                      controller: TextEditingController(
                          text: _endDateTo != null
                              ? _formatDate(_endDateTo!)
                              : ''),
                      onTap: () => _pickDate(context, _endDateTo,
                          (d) => setState(() => _endDateTo = d)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        FilterStudentsParams(
                          searchTerm: _searchController.text.isNotEmpty
                              ? _searchController.text
                              : null,
                          status: _selectedStatus,
                          hasActiveContract: _hasActiveContract,
                          contractStartDateFrom: _startDateFrom,
                          contractStartDateTo: _startDateTo,
                          contractEndDateFrom: _endDateFrom,
                          contractEndDateTo: _endDateTo,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
