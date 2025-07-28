// lib/features/student/pages/student_reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/services/report_service.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../domain/repositories/i_time_log_repository.dart';
import '../../../domain/repositories/i_contract_repository.dart';
import '../../shared/widgets/chart_widgets.dart';
import '../bloc/student_bloc.dart';

class StudentReportsPage extends StatefulWidget {
  const StudentReportsPage({super.key});

  @override
  State<StudentReportsPage> createState() => _StudentReportsPageState();
}

class _StudentReportsPageState extends State<StudentReportsPage> {
  final ReportService _reportService = ReportService();
  final FeedbackService _feedbackService = FeedbackService();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  TimeLogReport? _currentReport;
  ContractReport? _contractReport;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final studentBloc = context.read<StudentBloc>();
      final studentId = studentBloc.state.student?.id;

      if (studentId == null) {
        _feedbackService.showErrorSnackBar(
          context,
          'Erro: ID do estudante não encontrado',
        );
        return;
      }

      // Buscar dados dos repositórios
      final timeLogRepository = Modular.get<ITimeLogRepository>();
      final contractRepository = Modular.get<IContractRepository>();

      final timeLogsResult =
          await timeLogRepository.getTimeLogsByStudentId(studentId);
      final contractsResult =
          await contractRepository.getContractsByStudentId(studentId);

      timeLogsResult.fold(
        (failure) {
          _feedbackService.showErrorSnackBar(
            context,
            'Erro ao carregar registros de horas: ${failure.message}',
          );
        },
        (timeLogs) async {
          // Gerar relatório de horas
          final timeLogReport = await _reportService.generateTimeLogReport(
            studentId: studentId,
            startDate: _startDate,
            endDate: _endDate,
            timeLogs: timeLogs.map((log) => log.toJson()).toList(),
          );

          contractsResult.fold(
            (failure) {
              _feedbackService.showErrorSnackBar(
                context,
                'Erro ao carregar contratos: ${failure.message}',
              );
            },
            (contracts) async {
              // Gerar relatório de contratos
              final contractReport =
                  await _reportService.generateContractReport(
                contracts:
                    contracts.map((contract) => contract.toJson()).toList(),
                studentId: studentId,
              );

              if (mounted) {
                setState(() {
                  _currentReport = timeLogReport;
                  _contractReport = contractReport;
                });
              }
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _feedbackService.showErrorSnackBar(
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: 'Selecionar período do relatório',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadReports();
    }
  }

  Future<void> _exportReport(String format) async {
    if (_currentReport == null) {
      _feedbackService.showErrorSnackBar(
        context,
        'Nenhum relatório disponível para exportar',
      );
      return;
    }

    try {
      _feedbackService.showLoadingDialog(context, 'Exportando relatório...');

      String filePath;
      final reportData = _currentReport!.toJson();

      if (format == 'CSV') {
        filePath = await _reportService.exportToCSV(
          reportType: 'time_log',
          reportData: reportData,
          fileName: 'relatorio_horas_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        filePath = await _reportService.exportToJSON(
          reportType: 'time_log',
          reportData: reportData,
          fileName: 'relatorio_horas_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      Navigator.of(context).pop(); // Fechar loading

      await _reportService.shareReport(
        filePath,
        subject:
            'Relatório de Horas - ${_startDate.day}/${_startDate.month}/${_startDate.year} a ${_endDate.day}/${_endDate.month}/${_endDate.year}',
      );

      _feedbackService.showSuccessSnackBar(
        context,
        'Relatório exportado com sucesso!',
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fechar loading
      _feedbackService.showErrorSnackBar(
        context,
        'Erro ao exportar relatório: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadReports,
            tooltip: 'Atualizar relatórios',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar relatório',
            onSelected: _exportReport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'CSV',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Exportar CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'JSON',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Exportar JSON'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro de período
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Período do Relatório',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'De: ${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Até: ${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.date_range),
                                onPressed: _selectDateRange,
                                tooltip: 'Alterar período',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_currentReport != null) ...[
                    // Cards de estatísticas resumidas
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        StatsSummaryCard(
                          title: 'Total de Horas',
                          value: _currentReport!.totalHours.toStringAsFixed(1),
                          subtitle: 'horas trabalhadas',
                          icon: Icons.access_time,
                          color: Colors.blue,
                        ),
                        StatsSummaryCard(
                          title: 'Dias Trabalhados',
                          value: _currentReport!.totalDays.toString(),
                          subtitle: 'dias no período',
                          icon: Icons.calendar_today,
                          color: Colors.green,
                        ),
                        StatsSummaryCard(
                          title: 'Média Diária',
                          value: _currentReport!.averageHoursPerDay
                              .toStringAsFixed(1),
                          subtitle: 'horas por dia',
                          icon: Icons.trending_up,
                          color: Colors.orange,
                        ),
                        StatsSummaryCard(
                          title: 'Registros',
                          value: _currentReport!.timeLogs.length.toString(),
                          subtitle: 'entradas de ponto',
                          icon: Icons.list,
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Gráfico de barras - horas por dia da semana
                    WeeklyHoursBarChart(
                      hoursByWeekday: _currentReport!.hoursByWeekday,
                      primaryColor: Theme.of(context).primaryColor,
                    ),

                    const SizedBox(height: 16),

                    // Gráfico de linha - horas por semana
                    if (_currentReport!.hoursByWeek.isNotEmpty)
                      TimeSeriesLineChart(
                        timeSeriesData: _currentReport!.hoursByWeek,
                        title: 'Horas por Semana',
                        lineColor: Colors.green,
                      ),

                    const SizedBox(height: 16),

                    // Gráfico de linha - horas por mês
                    if (_currentReport!.hoursByMonth.isNotEmpty)
                      TimeSeriesLineChart(
                        timeSeriesData: _currentReport!.hoursByMonth,
                        title: 'Horas por Mês',
                        lineColor: Colors.blue,
                      ),

                    const SizedBox(height: 16),

                    // Progresso do contrato (se houver)
                    if (_contractReport != null &&
                        _contractReport!.activeContracts > 0)
                      const ProgressCard(
                        title: 'Progresso do Contrato',
                        progress: 0.65, // Calcular baseado nas horas
                        progressText: '65%',
                        progressColor: Colors.green,
                        subtitle:
                            'Baseado nas horas trabalhadas vs. horas requeridas',
                      ),

                    const SizedBox(height: 24),

                    // Lista detalhada dos registros recentes
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registros Recentes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (_currentReport!.timeLogs.length > 5
                                  ? 5
                                  : _currentReport!.timeLogs.length),
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final log = _currentReport!.timeLogs[index];
                                final date =
                                    DateTime.parse(log['created_at']).toLocal();
                                final hours =
                                    log['total_hours'] as double? ?? 0.0;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.access_time,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                      log['description'] ?? 'Sem descrição'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${hours.toStringAsFixed(1)}h',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                      ),
                                      Text(
                                        log['status'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: log['status'] == 'approved'
                                              ? Colors.green
                                              : log['status'] == 'rejected'
                                                  ? Colors.red
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (_currentReport!.timeLogs.length > 5) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Navegar para página com todos os registros
                                    _feedbackService.showInfoSnackBar(
                                      context,
                                      'Funcionalidade em desenvolvimento',
                                    );
                                  },
                                  child: Text(
                                    'Ver todos os ${_currentReport!.timeLogs.length} registros',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Estado vazio
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assessment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum dado encontrado',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Não há registros de horas para o período selecionado.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[500],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _selectDateRange,
                            icon: const Icon(Icons.date_range),
                            label: const Text('Alterar Período'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
