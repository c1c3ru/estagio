// lib/features/supervisor/pages/supervisor_reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/supervisor/bloc/supervisor_state.dart';
import '../../../core/services/report_service.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../domain/repositories/i_time_log_repository.dart';
import '../../../domain/repositories/i_contract_repository.dart';
import '../../../domain/repositories/i_student_repository.dart';
import '../../shared/widgets/chart_widgets.dart';
import '../bloc/supervisor_bloc.dart';

class SupervisorReportsPage extends StatefulWidget {
  const SupervisorReportsPage({super.key});

  @override
  State<SupervisorReportsPage> createState() => _SupervisorReportsPageState();
}

class _SupervisorReportsPageState extends State<SupervisorReportsPage>
    with SingleTickerProviderStateMixin {
  final ReportService _reportService = ReportService();
  // final FeedbackService _feedbackService = FeedbackService(); // REMOVIDO

  late TabController _tabController;

  StudentPerformanceReport? _performanceReport;
  ContractReport? _contractReport;
  bool _isLoading = false;

  String _selectedPeriod = '30'; // dias
  String _selectedStudent = 'all';
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supervisorBloc = context.read<SupervisorBloc>();
      String? supervisorId;
      if (supervisorBloc.state is SupervisorDashboardLoadSuccess) {
        supervisorId = (supervisorBloc.state as SupervisorDashboardLoadSuccess).supervisorProfile?.id;
      }


      if (supervisorId == null) {
        FeedbackService.showError(
          context,
          'Erro: ID do supervisor não encontrado',
        );
        return;
      }

      // Buscar dados dos repositórios
      final timeLogRepository = Modular.get<ITimeLogRepository>();
      final contractRepository = Modular.get<IContractRepository>();
      final studentRepository = Modular.get<IStudentRepository>();

      // Buscar estudantes do supervisor
      final studentsResult =
          await studentRepository.getStudentsBySupervisor(supervisorId!);

      studentsResult.fold(
        (failure) {
          FeedbackService.showError(
            context,
            'Erro ao carregar estudantes: ${failure.message}',
          );
        },
        (students) async {
          setState(() {
            _students = students.map((s) => {'id': s.id, 'fullName': s.fullName}).toList();
          });

          // Buscar registros de horas de todos os estudantes
          final timeLogsResult =
              await timeLogRepository.getTimeLogsBySupervisor(supervisorId!);
          final contractsResult =
              await contractRepository.getContractsBySupervisor(supervisorId!);

          timeLogsResult.fold(
            (failure) {
              FeedbackService.showError(
                context,
                'Erro ao carregar registros de horas: ${failure.message}',
              );
            },
            (timeLogs) async {
              contractsResult.fold(
                (failure) {
                  FeedbackService.showError(
                    context,
                    'Erro ao carregar contratos: ${failure.message}',
                  );
                },
                (contracts) async {
                  // Filtrar dados baseado no período selecionado
                  final cutoffDate = DateTime.now()
                      .subtract(Duration(days: int.parse(_selectedPeriod)));
                  final filteredTimeLogs = timeLogs
                      .where((log) =>
                          DateTime.parse(log.createdAt).isAfter(cutoffDate))
                      .toList();

                  // Filtrar por estudante se selecionado
                  final finalTimeLogs = _selectedStudent == 'all'
                      ? filteredTimeLogs
                      : filteredTimeLogs
                          .where((log) => log.studentId == _selectedStudent)
                          .toList();

                  final finalStudents = _selectedStudent == 'all'
                      ? _students
                      : _students
                          .where((s) => s['id'] == _selectedStudent)
                          .toList();

                  // Gerar relatórios
                  final performanceReport =
                      await _reportService.generateStudentPerformanceReport(
                    supervisorId: supervisorId,
                    students: finalStudents,
                    timeLogs: finalTimeLogs.map((log) => log.toJson()).toList(),
                    contracts:
                        contracts.map((contract) => contract.toJson()).toList(),
                  );

                  final contractReport =
                      await _reportService.generateContractReport(
                    contracts:
                        contracts.map((contract) => contract.toJson()).toList(),
                    supervisorId: supervisorId,
                  );

                  if (mounted) {
                    setState(() {
                      _performanceReport = performanceReport;
                      _contractReport = contractReport;
                    });
                  }
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(
          context,
          'Erro inesperado ao carregar relatórios: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportReport(String format, String reportType) async {
    if (_performanceReport == null && _contractReport == null) {
      FeedbackService.showError(
        context,
        'Nenhum relatório disponível para exportar',
      );
      return;
    }

    try {
      FeedbackService.showLoading(context, message: 'Exportando relatório...');

      String filePath;
      Map<String, dynamic> reportData;

      if (reportType == 'performance' && _performanceReport != null) {
        reportData = _performanceReport!.toJson();
      } else if (reportType == 'contract' && _contractReport != null) {
        reportData = _contractReport!.toJson();
      } else {
        Navigator.of(context).pop();
        FeedbackService.showError(
            context, 'Tipo de relatório inválido');
        return;
      }

      if (format == 'CSV') {
        filePath = await _reportService.exportToCSV(
          reportType: reportType,
          reportData: reportData,
          fileName: '${reportType}_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        filePath = await _reportService.exportToJSON(
          reportType: reportType,
          reportData: reportData,
          fileName: '${reportType}_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      Navigator.of(context).pop(); // Fechar loading

      await _reportService.shareReport(
        filePath,
        subject:
            'Relatório de ${reportType == 'performance' ? 'Performance' : 'Contratos'} - Supervisor',
      );

      FeedbackService.showSuccess(
        context,
        'Relatório exportado com sucesso!',
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fechar loading
      // ignore: use_build_context_synchronously
      if (!mounted) return;
      FeedbackService.showError(
        context,
        'Erro ao exportar relatório: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de Supervisão'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Performance'),
            Tab(icon: Icon(Icons.assignment), text: 'Contratos'),
            Tab(icon: Icon(Icons.analytics), text: 'Análises'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadReports,
            tooltip: 'Atualizar relatórios',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar relatório',
            onSelected: (value) {
              final parts = value.split('_');
              final format = parts[0];
              final reportType = parts[1];
              _exportReport(format, reportType);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'CSV_performance',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Performance CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'JSON_performance',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Performance JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'CSV_contract',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Contratos CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'JSON_contract',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Contratos JSON'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: '7', child: Text('Últimos 7 dias')),
                      DropdownMenuItem(
                          value: '30', child: Text('Últimos 30 dias')),
                      DropdownMenuItem(
                          value: '90', child: Text('Últimos 3 meses')),
                      DropdownMenuItem(value: '365', child: Text('Último ano')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _loadReports();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStudent,
                    decoration: const InputDecoration(
                      labelText: 'Estudante',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: 'all', child: Text('Todos os estudantes')),
                      ..._students.map((student) => DropdownMenuItem(
                            value: student['id'],
                            child: Text(student['name'] ?? 'Sem nome'),
                          )),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStudent = value;
                        });
                        _loadReports();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo das abas
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Carregando relatórios...'),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPerformanceTab(),
                      _buildContractsTab(),
                      _buildAnalyticsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_performanceReport == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum dado de performance disponível'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              StatsSummaryCard(
                title: 'Total de Estudantes',
                value: _performanceReport!.totalStudents.toString(),
                icon: Icons.people,
                color: Colors.blue,
                subtitle: 'Todos cadastrados',
              ),
              StatsSummaryCard(
                title: 'Estudantes Ativos',
                value: _performanceReport!.activeStudents.toString(),
                icon: Icons.verified,
                color: Colors.green,
                subtitle: 'Ativos atualmente',
              ),
              StatsSummaryCard(
                title: 'Total de Horas',
                value: _performanceReport!.totalHours.toStringAsFixed(1),
                icon: Icons.access_time,
                color: Colors.orange,
                subtitle: 'Somatório geral',
              ),
              StatsSummaryCard(
                title: 'Média por Estudante',
                value: _performanceReport!.averageHoursPerStudent
                    .toStringAsFixed(1),
                icon: Icons.trending_up,
                color: Colors.purple,
                subtitle: 'Horas médias',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lista de performance dos estudantes
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance dos Estudantes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _performanceReport!.studentPerformances.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final performance =
                          _performanceReport!.studentPerformances[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: performance.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          child: Icon(
                            performance.isActive
                                ? Icons.person
                                : Icons.person_outline,
                            color: performance.isActive
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          performance.studentName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${performance.totalHours.toStringAsFixed(1)}h em ${performance.totalDays} dias'),
                            Text(
                                'Média: ${performance.averageHoursPerDay.toStringAsFixed(1)}h/dia'),
                            if (performance.lastActivity != null)
                              Text(
                                'Última atividade: ${performance.lastActivity!.day.toString().padLeft(2, '0')}/${performance.lastActivity!.month.toString().padLeft(2, '0')}/${performance.lastActivity!.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: performance.isActive
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                performance.isActive ? 'Ativo' : 'Inativo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${performance.contractProgress.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: performance.contractProgress >= 80
                                    ? Colors.green
                                    : performance.contractProgress >= 50
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractsTab() {
    if (_contractReport == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum dado de contratos disponível'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo de contratos
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              StatsSummaryCard(
                title: 'Total de Contratos',
                value: _contractReport!.totalContracts.toString(),
                icon: Icons.assignment,
                color: Colors.blue,
                subtitle: 'Todos cadastrados',
              ),
              StatsSummaryCard(
                title: 'Contratos Ativos',
                value: _contractReport!.activeContracts.toString(),
                icon: Icons.assignment_turned_in,
                color: Colors.green,
                subtitle: 'Ativos atualmente',
              ),
              StatsSummaryCard(
                title: 'Concluídos',
                value: _contractReport!.completedContracts.toString(),
                icon: Icons.check_circle,
                color: Colors.teal,
                subtitle: 'Já finalizados',
              ),
              StatsSummaryCard(
                title: 'Expirando',
                value: _contractReport!.expiringContracts.toString(),
                icon: Icons.warning,
                color: Colors.orange,
                subtitle: 'Próximos a vencer',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Gráfico de pizza - distribuição de contratos
          DonutChart(
            data: [
              {'label': 'Ativos', 'value': _contractReport!.activeContracts.toDouble(), 'color': Colors.green},
              {'label': 'Concluídos', 'value': _contractReport!.completedContracts.toDouble(), 'color': Colors.blue},
              {'label': 'Expirados', 'value': _contractReport!.expiredContracts.toDouble(), 'color': Colors.red},
              {'label': 'Expirando', 'value': _contractReport!.expiringContracts.toDouble(), 'color': Colors.orange},
            ],
          ),

          const SizedBox(height: 16),

          // Gráfico de linha - contratos por mês
          if (_contractReport!.contractsByMonth.isNotEmpty)
            TimeSeriesLineChart(
              data: _contractReport!.contractsByMonth.entries.map((e) => {'label': e.key, 'value': e.value.toDouble()}).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_performanceReport == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum dado de análise disponível'),
          ],
        ),
      );
    }

    // Preparar dados para análises
    final hoursDistribution = <String, double>{};
    final progressDistribution = <String, double>{};

    for (final performance in _performanceReport!.studentPerformances) {
      // Distribuição de horas
      if (performance.totalHours < 20) {
        hoursDistribution['0-20h'] = (hoursDistribution['0-20h'] ?? 0) + 1;
      } else if (performance.totalHours < 50) {
        hoursDistribution['20-50h'] = (hoursDistribution['20-50h'] ?? 0) + 1;
      } else if (performance.totalHours < 100) {
        hoursDistribution['50-100h'] = (hoursDistribution['50-100h'] ?? 0) + 1;
      } else {
        hoursDistribution['100h+'] = (hoursDistribution['100h+'] ?? 0) + 1;
      }

      // Distribuição de progresso
      if (performance.contractProgress < 25) {
        progressDistribution['0-25%'] =
            (progressDistribution['0-25%'] ?? 0) + 1;
      } else if (performance.contractProgress < 50) {
        progressDistribution['25-50%'] =
            (progressDistribution['25-50%'] ?? 0) + 1;
      } else if (performance.contractProgress < 75) {
        progressDistribution['50-75%'] =
            (progressDistribution['50-75%'] ?? 0) + 1;
      } else {
        progressDistribution['75-100%'] =
            (progressDistribution['75-100%'] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distribuição de horas trabalhadas
          DonutChart(
            data: [
              {'label': '0-20h', 'value': hoursDistribution['0-20h'] ?? 0, 'color': Colors.red},
              {'label': '20-50h', 'value': hoursDistribution['20-50h'] ?? 0, 'color': Colors.orange},
              {'label': '50-100h', 'value': hoursDistribution['50-100h'] ?? 0, 'color': Colors.blue},
              {'label': '100h+', 'value': hoursDistribution['100h+'] ?? 0, 'color': Colors.green},
            ],
          ),

          const SizedBox(height: 16),

          // Distribuição de progresso dos contratos
          DonutChart(
            data: [
              {'label': '0-25%', 'value': progressDistribution['0-25%'] ?? 0, 'color': Colors.red},
              {'label': '25-50%', 'value': progressDistribution['25-50%'] ?? 0, 'color': Colors.orange},
              {'label': '50-75%', 'value': progressDistribution['50-75%'] ?? 0, 'color': Colors.yellow},
              {'label': '75-100%', 'value': progressDistribution['75-100%'] ?? 0, 'color': Colors.green},
            ],
          ),

          const SizedBox(height: 16),

          // Ranking dos melhores estudantes
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top 5 Estudantes por Horas Trabalhadas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        (_performanceReport!.studentPerformances.length > 5
                            ? 5
                            : _performanceReport!.studentPerformances.length),
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final performance =
                          _performanceReport!.studentPerformances[index];
                      final position = index + 1;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: position == 1
                              ? Colors.amber
                              : position == 2
                                  ? Colors.grey[400]
                                  : position == 3
                                      ? Colors.brown[300]
                                      : Colors.blue[100],
                          child: Text(
                            '$position°',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  position <= 3 ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        title: Text(
                          performance.studentName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Média: ${performance.averageHoursPerDay.toStringAsFixed(1)}h/dia',
                        ),
                        trailing: Text(
                          '${performance.totalHours.toStringAsFixed(1)}h',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
