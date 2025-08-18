import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../domain/repositories/i_student_repository.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_data_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../../../core/theme/app_theme_extensions.dart';

class SupervisorReportsPage extends StatefulWidget {
  const SupervisorReportsPage({super.key});

  @override
  State<SupervisorReportsPage> createState() => _SupervisorReportsPageState();
}

class _SupervisorReportsPageState extends State<SupervisorReportsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Sempre carregar dados do dashboard
    Modular.get<SupervisorBloc>().add(LoadSupervisorDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de Supervisão'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            '/supervisor/',
            (route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.batch_prediction),
            onPressed: _generateBulkReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Performance'),
            Tab(text: 'Contratos'),
            Tab(text: 'Análises'),
          ],
        ),
      ),
      body: BlocProvider.value(
        value: Modular.get<SupervisorBloc>(),
        child: BlocBuilder<SupervisorBloc, SupervisorState>(
          builder: (context, state) {
            if (_isLoading || state is SupervisorLoading) {
              return const LoadingIndicator();
            }
            
            if (state is SupervisorDashboardLoadSuccess) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildPerformanceTab(state),
                  _buildContractsTab(state),
                  _buildAnalysisTab(state),
                ],
              );
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: context.tokens.spaceLg),
                  const Text('Erro ao carregar dados dos relatórios'),
                  SizedBox(height: context.tokens.spaceLg),
                  ElevatedButton(
                    onPressed: () {
                      Modular.get<SupervisorBloc>().add(LoadSupervisorDashboardDataEvent());
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPerformanceTab(SupervisorDashboardLoadSuccess state) {
    if (state.students.isEmpty) {
      return const EmptyDataWidget(
        message: 'Nenhum estudante encontrado para gerar relatórios de performance.',
      );
    }
    
    return ListView(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo de Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.tokens.spaceLg),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total de Estudantes',
                        '${state.students.length}',
                        Icons.people,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: context.tokens.spaceMd),
                    Expanded(
                      child: _buildStatCard(
                        'Estudantes Ativos',
                        '${state.stats.activeStudents}',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.tokens.spaceLg),
        Card(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lista de Estudantes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.tokens.spaceMd),
                ...state.students.map((student) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      student.fullName.isNotEmpty 
                          ? student.fullName.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(student.fullName),
                  subtitle: Text('${student.course} - ${student.registrationNumber}'),
                  trailing: FutureBuilder<Map<String, dynamic>>(
                    future: Modular.get<IStudentRepository>()
                        .getStudentDashboard(student.id)
                        .then((either) => either.getOrElse(() => {})),
                    builder: (context, snapshot) {
                      final approved = (snapshot.data?['timeStats']?['approvedHoursTotal'] as num?)
                              ?.toInt() ??
                          student.totalHoursCompleted.toInt();
                      return Text(
                        '$approved/${student.totalHoursRequired.toInt()}h',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContractsTab(SupervisorDashboardLoadSuccess state) {
    if (state.contracts.isEmpty) {
      return const EmptyDataWidget(
        message: 'Nenhum contrato encontrado para gerar relatórios.',
      );
    }
    
    return ListView(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo de Contratos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.tokens.spaceLg),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total de Contratos',
                        '${state.contracts.length}',
                        Icons.description,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: context.tokens.spaceMd),
                    Expanded(
                      child: _buildStatCard(
                        'A Vencer em 30d',
                        '${state.stats.expiringContractsSoon}',
                        Icons.warning,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.tokens.spaceLg),
        Card(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contratos Recentes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.tokens.spaceMd),
                ...state.contracts.take(5).map((contract) {
                  final student = state.students.where((s) => s.id == contract.studentId).isNotEmpty
                      ? state.students.firstWhere((s) => s.id == contract.studentId)
                      : null;
                  return ListTile(
                    leading: Icon(
                      Icons.description,
                      color: _getContractStatusColor(contract.status),
                    ),
                    title: Text(student?.fullName ?? 'Estudante não encontrado'),
                    subtitle: Text(
                      'Status: ${contract.status}\n'
                      'Período: ${_formatDate(contract.startDate)} - ${_formatDate(contract.endDate)}',
                    ),
                    isThreeLine: true,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab(SupervisorDashboardLoadSuccess state) {
    if (state.students.isEmpty && state.contracts.isEmpty) {
      return const EmptyDataWidget(
        message: 'Nenhum dado disponível para gerar análises.',
      );
    }
    
    return ListView(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Análise Geral',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.tokens.spaceLg),
                _buildStatCard(
                  'Aprovações Pendentes',
                  '${state.pendingApprovals.length}',
                  Icons.pending_actions,
                  AppColors.warning,
                ),
                SizedBox(height: context.tokens.spaceLg),
                const Text(
                  'Distribuição por Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.tokens.spaceMd),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.success),
                  title: const Text('Estudantes Ativos'),
                  trailing: Text('${state.stats.activeStudents}'),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: AppColors.error),
                  title: const Text('Estudantes Inativos'),
                  trailing: Text('${state.stats.inactiveStudents}'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.tokens.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: context.tokens.spaceSm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: context.tokens.spaceXs),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getContractStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending_approval':
        return AppColors.warning;
      case 'expired':
      case 'terminated':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Estudante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('João Silva'),
              onTap: () => Navigator.pop(context, 'João Silva'),
            ),
            ListTile(
              title: const Text('Maria Santos'),
              onTap: () => Navigator.pop(context, 'Maria Santos'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Aplicar'),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _generateBulkReports() async {
    setState(() => _isLoading = true);
    try {
      // Simular geração de relatórios em lote
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatórios gerados com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar relatórios: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}