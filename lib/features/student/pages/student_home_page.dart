import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/animations/lottie_animations.dart';
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
import '../../../domain/entities/student_entity.dart';
import '../../../domain/usecases/supervisor/get_all_supervisors_usecase.dart';
import '../../../domain/entities/supervisor_entity.dart';
import '../widgets/time_tracker_widget.dart';
import '../../../data/datasources/supabase/contract_datasource.dart';
import '../../../domain/entities/time_log_entity.dart';
import '../../../core/utils/app_logger.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool _dashboardRequested = false;
  // Cache dos últimos dados válidos do dashboard
  StudentEntity? _cachedStudent;
  StudentTimeStats? _cachedTimeStats;
  List<ContractEntity> _cachedContracts = const [];
  @override
  void initState() {
    super.initState();

    // Usar WidgetsBinding para garantir que o widget está montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    if (mounted) {
      final authState = BlocProvider.of<AuthBloc>(context).state;
      AppLogger.ui('StudentHomePage: Auth state: ${authState.runtimeType}');
      if (authState is AuthSuccess) {
        final userId = authState.user.id;
        AppLogger.ui('StudentHomePage: Disparando LoadStudentDashboardDataEvent para userId: $userId');
        if (!_dashboardRequested) {
          _dashboardRequested = true;
          BlocProvider.of<StudentBloc>(context)
              .add(LoadStudentDashboardDataEvent(userId: userId));
        } else {
          AppLogger.ui('StudentHomePage: dashboard já solicitado, ignorando.');
        }
      } else {
        AppLogger.ui('StudentHomePage: Auth state não é AuthSuccess: ${authState.runtimeType}');
      }
    }
  }

  String _formatDatePtBr(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _mapContractStatus(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
      case 'ativo':
        return 'Ativo';
      case 'pending':
      case 'pendente':
        return 'Pendente';
      case 'terminated':
      case 'encerrado':
      case 'finalizado':
        return 'Encerrado';
      case 'suspended':
      case 'suspenso':
        return 'Suspenso';
      default:
        return status ?? '—';
    }
  }

  String _mapContractType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'internship':
      case 'estagio':
      case 'estágio':
        return 'Estágio';
      case 'apprenticeship':
        return 'Aprendizagem';
      case 'volunteer':
      case 'voluntario':
      case 'voluntário':
        return 'Voluntário';
      default:
        return type ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated && mounted) {
          Modular.to.navigate('/login');
        } else if (state is AuthSuccess && mounted) {
          if (!_dashboardRequested) {
            AppLogger.ui('StudentHomePage: AuthSuccess detectado, solicitando dashboard (uma vez)');
            _dashboardRequested = true;
            final userId = state.user.id;
            BlocProvider.of<StudentBloc>(context)
                .add(LoadStudentDashboardDataEvent(userId: userId));
          } else {
            AppLogger.ui('StudentHomePage: AuthSuccess recebido, porém dashboard já foi solicitado.');
          }
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
        ),
        body: BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentDashboardLoadSuccess) {
              // Atualiza o cache com dados válidos
              _cachedStudent = state.student;
              _cachedTimeStats = state.timeStats;
              _cachedContracts = state.contracts;
            }
          },
          child: BlocBuilder<StudentBloc, StudentState>(
            builder: (context, state) {
              final bool isLoading = state is StudentLoading && _cachedStudent == null;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Usa dados do estado se disponíveis, senão cai no cache
              final student = state is StudentDashboardLoadSuccess
                  ? state.student
                  : _cachedStudent;

              if (student == null) {
                return const Center(
                  child: Column(
                    children: [
                      LottieEmptyStateWidget(
                        message:
                            'Complete seu cadastro para ver suas informações aqui.',
                        size: 180,
                      ),
                    ],
                  ),
                );
              }

              final timeStats = state is StudentDashboardLoadSuccess
                  ? state.timeStats
                  : _cachedTimeStats;

              final contracts = state is StudentDashboardLoadSuccess
                  ? state.contracts
                  : _cachedContracts;

              return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLottieAnimation(
                        assetPath: LottieAssetPaths.student,
                        height: 150,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Página Inicial do Estudante',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Bem-vindo, ${student.fullName}!',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Card com informações básicas
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Informações do estudante (30%) dentro do Card
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Informações do Estudante',
                                          style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Matrícula: ${student.registrationNumber}'),
                                        Text('Curso: ${student.course}'),
                                        Text('Orientador: ${student.advisorName}'),
                                        Text('Turno das Aulas: ${student.classShift}'),
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
                                        Text('Esta Semana: ${timeStats?.hoursThisWeek ?? 0.0} horas'),
                                        Text('Este Mês: ${timeStats?.hoursThisMonth ?? 0.0} horas'),
                                        if (timeStats?.activeTimeLog != null)
                                          const Text(
                                            'Status: Trabalhando agora',
                                            style: TextStyle(
                                                color: AppColors.success,
                                                fontWeight: FontWeight.bold),
                                          )
                                        else
                                          const Text(
                                            'Status: Não está trabalhando',
                                            style: TextStyle(color: AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Card com informações do contrato ativo
                                if (contracts.isNotEmpty)
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Contrato Ativo',
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Tipo: ${_mapContractType(contracts.first.contractType)} | Status: ${_mapContractStatus(contracts.first.status)}'),
                                          Text('Início: ${_formatDatePtBr(contracts.first.startDate)}'),
                                          Text('Fim: ${_formatDatePtBr(contracts.first.endDate)}'),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Card(
                                    color: AppColors.primary.withOpacity(0.08),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.add_box,
                                        color: AppColors.primary,
                                        size: 36,
                                      ),
                                      title: const Text(
                                        'Novo Contrato',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle:
                                          const Text('Clique para cadastrar um novo contrato'),
                                      onTap: () async {
                                        if (!mounted) return;
                                        final bloc = BlocProvider.of<StudentBloc>(context);
                                        await showDialog(
                                          context: context,
                                          builder: (context) => BlocProvider.value(
                                            value: Modular.get<ContractBloc>(),
                                            child: _NovoContratoDialog(studentId: student.id),
                                          ),
                                        );
                                        if (!mounted) return;
                                        // Após fechar o modal, recarrega os dados
                                        bloc.add(
                                          LoadStudentDashboardDataEvent(userId: student.id),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Widget de registro de horas
                                BlocSelector<StudentBloc, StudentState, TimeLogEntity?>(
                                  selector: (state) =>
                                      state is StudentDashboardLoadSuccess
                                          ? state.timeStats.activeTimeLog
                                          : null,
                                  builder: (context, activeTimeLog) {
                                    return TimeTrackerWidget(
                                      currentUserId: student.id,
                                      activeTimeLogInitial: activeTimeLog,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Logo IFCE (70%) fora do Card
                          Expanded(
                            flex: 7,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.asset(
                                'assets/images/ifce_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Menu de funcionalidades
                    ],
                  ),
                );
            },
          ),
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
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;

  List<SupervisorEntity> _supervisores = [];
  SupervisorEntity? _supervisorSelecionado;
  bool _loadingSupervisores = true;
  bool _initialized = false;
  bool _hasActiveContract = false;
  bool _checkingContract = true;

  @override
  void initState() {
    super.initState();
    if (!_initialized) {
      _initialized = true;
      _buscarSupervisores();
      _verificarContratoAtivo();
    }
  }

  Future<void> _buscarSupervisores() async {
    if (!mounted) return;
    setState(() => _loadingSupervisores = true);
    final usecase = Modular.get<GetAllSupervisorsUsecase>();
    final result = await usecase();
    if (!mounted) return;
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Erro ao buscar supervisores: ${failure.message}'),
                backgroundColor: Colors.red),
          );
          setState(() => _supervisores = []);
        }
      },
      (list) {
        if (mounted) {
          setState(() => _supervisores = list);
        }
      },
    );
    if (mounted) {
      setState(() => _loadingSupervisores = false);
    }
  }

  Future<void> _verificarContratoAtivo() async {
    if (!mounted) return;
    setState(() => _checkingContract = true);
    try {
      final datasource = Modular.get<ContractDatasource>();
      final result =
          await datasource.getActiveContractByStudent(widget.studentId);
      if (mounted) {
        setState(() {
          _hasActiveContract = result != null;
          _checkingContract = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasActiveContract = false;
          _checkingContract = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null ||
        _supervisorSelecionado == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preencha todos os campos obrigatórios!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (widget.studentId.isEmpty || _supervisorSelecionado!.id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID do estudante ou do supervisor está vazio!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (mounted) setState(() => _loading = true);
    try {
      final contract = ContractEntity(
        id: '',
        studentId: widget.studentId,
        supervisorId: _supervisorSelecionado!.id,
        contractType: 'mandatory_internship',
        status: 'active',
        startDate: _startDate!,
        endDate: _endDate!,
        description: _descriptionController.text.trim().isEmpty
            ? 'Contrato de estágio obrigatório'
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: null,
      );
      final bloc = BlocProvider.of<ContractBloc>(context);
      bloc.add(ContractCreateRequested(contract: contract));

      // Aguardar apenas o primeiro estado relevante
      final completer = Completer<void>();
      late StreamSubscription subscription;

      subscription = bloc.stream.listen((state) {
        if (state is ContractCreateSuccess) {
          subscription.cancel();
          if (mounted) {
            // Mostrar SnackBar antes de fechar o modal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Contrato criado com sucesso!'),
                  backgroundColor: Colors.green),
            );
            // Fechar modal após um pequeno delay
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          }
          completer.complete();
        } else if (state is ContractInsertError) {
          subscription.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Erro ao criar contrato: ${state.message}'),
                  backgroundColor: Colors.red),
            );
          }
          completer.complete();
        }
      });

      await completer.future;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao criar contrato: $e'),
              backgroundColor: Colors.red),
        );
      }
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
              if (_checkingContract)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (_hasActiveContract)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Você já possui um contrato ativo. Finalize o contrato atual antes de criar um novo.',
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
              if (_loadingSupervisores)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else
                Flexible(
                  child: DropdownButtonFormField<SupervisorEntity>(
                    value: _supervisorSelecionado,
                    items: _supervisores
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.position != null && s.position!.isNotEmpty
                                    ? '${s.fullName} - ${s.position}'
                                    : s.fullName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (s) =>
                        setState(() => _supervisorSelecionado = s),
                    decoration: const InputDecoration(labelText: 'Supervisor'),
                    validator: (v) => v == null ? 'Obrigatório' : null,
                  ),
                ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Contrato',
                  hintText: 'Ex: Estágio em Desenvolvimento de Software',
                ),
                maxLines: 2,
              ),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (BuildContext context) {
                        return TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              locale: const Locale('pt', 'BR'),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                          child: Text(_startDate == null
                              ? 'Data Início'
                              : 'Início: ${_formatDatePtBr(_startDate!)}'),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (BuildContext context) {
                        return TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              locale: const Locale('pt', 'BR'),
                            );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                          child: Text(_endDate == null
                              ? 'Data Fim'
                              : 'Fim: ${_formatDatePtBr(_endDate!)}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _hasActiveContract ? null : _submit,
                  child: const Text('Salvar'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDatePtBr(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
