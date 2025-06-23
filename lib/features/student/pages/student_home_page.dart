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
import '../../../features/shared/bloc/contract_bloc.dart';
import '../../../domain/entities/contract_entity.dart';
import '../../../core/enums/contract_status.dart';
import '../../../domain/usecases/supervisor/get_all_supervisors_usecase.dart';
import '../../../domain/entities/supervisor_entity.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();

    // Obter o ID do usuário autenticado
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthSuccess) {
      final userId = authState.user.id;
      // Carregar dados do dashboard
      BlocProvider.of<StudentBloc>(context)
          .add(LoadStudentDashboardDataEvent(userId: userId));
    }
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
          title: const Text('Página Inicial do Estudante'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
              },
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Modular.to.pop(),
          ),
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
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

                        // Após o card de progresso do estágio
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: AppColors.primary.withOpacity(0.08),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.calendar_view_week,
                                          color: AppColors.primary),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${state.timeStats.hoursThisWeek.toStringAsFixed(1)} h',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      const Text('Esta semana',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Card(
                                color: AppColors.success.withOpacity(0.08),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          color: AppColors.success),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${state.timeStats.hoursThisMonth.toStringAsFixed(1)} h',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      const Text('Este mês',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

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

                        // Card para criar novo contrato
                        Card(
                          color: AppColors.primary.withOpacity(0.08),
                          child: ListTile(
                            leading: const Icon(Icons.add_box,
                                color: AppColors.primary, size: 36),
                            title: const Text('Novo Contrato',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text(
                                'Clique para cadastrar um novo contrato'),
                            onTap: () async {
                              if (!mounted) return;
                              await showDialog(
                                context: context,
                                builder: (context) => _NovoContratoDialog(
                                    studentId: state.student.id),
                              );
                              // Após fechar o modal, recarrega os dados
                              BlocProvider.of<StudentBloc>(context).add(
                                LoadStudentDashboardDataEvent(
                                    userId: state.student.id),
                              );
                            },
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
                                  if (!mounted) return;
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
                              if (!mounted) return;
                              final authState =
                                  BlocProvider.of<AuthBloc>(context).state;
                              if (authState is AuthSuccess) {
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
                final authState = BlocProvider.of<AuthBloc>(context).state;
                if (authState is AuthSuccess) {
                  Modular.to.pushNamed('/student/contracts',
                      arguments: {"studentId": authState.user.id});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuário não autenticado!')),
                  );
                }
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

class _NovoContratoDialog extends StatefulWidget {
  final String studentId;
  const _NovoContratoDialog({required this.studentId});

  @override
  State<_NovoContratoDialog> createState() => _NovoContratoDialogState();
}

class _NovoContratoDialogState extends State<_NovoContratoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _totalHoursController = TextEditingController();
  final _weeklyHoursController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;

  List<SupervisorEntity> _supervisores = [];
  SupervisorEntity? _supervisorSelecionado;
  bool _loadingSupervisores = true;

  @override
  void initState() {
    super.initState();
    _buscarSupervisores();
  }

  Future<void> _buscarSupervisores() async {
    setState(() => _loadingSupervisores = true);
    final usecase = Modular.get<GetAllSupervisorsUsecase>();
    final result = await usecase();
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao buscar supervisores: ${failure.message}'),
              backgroundColor: Colors.red),
        );
        setState(() => _supervisores = []);
      },
      (list) => setState(() => _supervisores = list),
    );
    setState(() => _loadingSupervisores = false);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _totalHoursController.dispose();
    _weeklyHoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null ||
        _supervisorSelecionado == null) return;
    setState(() => _loading = true);
    try {
      final contract = ContractEntity(
        id: '',
        studentId: widget.studentId,
        supervisorId: _supervisorSelecionado!.id,
        company: _companyController.text.trim(),
        position: _positionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        totalHoursRequired: double.tryParse(_totalHoursController.text) ?? 0,
        weeklyHoursTarget: double.tryParse(_weeklyHoursController.text) ?? 0,
        status: ContractStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
      final bloc = BlocProvider.of<ContractBloc>(context);
      bloc.add(ContractCreateRequested(contract: contract));
      await for (final state in bloc.stream) {
        if (state is ContractCreateSuccess) {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Contrato criado com sucesso!'),
                backgroundColor: Colors.green),
          );
          break;
        } else if (state is ContractInsertError) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro ao criar contrato: ${state.message}'),
                backgroundColor: Colors.red),
          );
          break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao criar contrato: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Contrato'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingSupervisores)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else
                DropdownButtonFormField<SupervisorEntity>(
                  value: _supervisorSelecionado,
                  items: _supervisores
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.position} - ${s.id}'),
                          ))
                      .toList(),
                  onChanged: (s) => setState(() => _supervisorSelecionado = s),
                  decoration: const InputDecoration(labelText: 'Supervisor'),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Empresa'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Cargo'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      child: Text(_startDate == null
                          ? 'Data Início'
                          : 'Início: ${_startDate!.toLocal().toString().split(' ')[0]}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      child: Text(_endDate == null
                          ? 'Data Fim'
                          : 'Fim: ${_endDate!.toLocal().toString().split(' ')[0]}'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _totalHoursController,
                decoration: const InputDecoration(labelText: 'Horas Totais'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _weeklyHoursController,
                decoration:
                    const InputDecoration(labelText: 'Meta Semanal (horas)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Salvar'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
