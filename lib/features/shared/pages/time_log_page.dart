import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/bloc/time_log_bloc.dart';
import '../../../domain/entities/time_log_entity.dart';

class TimeLogPage extends StatefulWidget {
  final String studentId;

  const TimeLogPage({
    super.key,
    required this.studentId,
  });

  @override
  State<TimeLogPage> createState() => _TimeLogPageState();
}

class _TimeLogPageState extends State<TimeLogPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTimeLogs();
    _loadActiveTimeLog();
  }

  void _loadTimeLogs() {
    context.read<TimeLogBloc>().add(
          TimeLogLoadByStudentRequested(studentId: widget.studentId),
        );
  }

  void _loadActiveTimeLog() {
    context.read<TimeLogBloc>().add(
          TimeLogGetActiveRequested(studentId: widget.studentId),
        );
  }

  void _clockIn() {
    context.read<TimeLogBloc>().add(
          TimeLogClockInRequested(
            studentId: widget.studentId,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
    _notesController.clear();
  }

  void _clockOut() {
    context.read<TimeLogBloc>().add(
          TimeLogClockOutRequested(
            studentId: widget.studentId,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
    _notesController.clear();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Horas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadTimeLogs();
              _loadActiveTimeLog();
            },
          ),
        ],
      ),
      body: BlocListener<TimeLogBloc, TimeLogState>(
        listener: (context, state) {
          if (state is TimeLogClockInSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Entrada registrada com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadTimeLogs();
            _loadActiveTimeLog();
          } else if (state is TimeLogClockOutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saída registrada com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadTimeLogs();
            _loadActiveTimeLog();
          } else if (state is TimeLogClockInError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is TimeLogClockOutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _loadTimeLogs();
            _loadActiveTimeLog();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClockInOutCard(),
                const SizedBox(height: 24),
                _buildTimeLogsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClockInOutCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Registro de Ponto',
                  style: AppTextStyles.h6,
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<TimeLogBloc, TimeLogState>(
              builder: (context, state) {
                if (state is TimeLogGetActiveSuccess) {
                  final hasActiveLog = state.activeTimeLog != null;

                  return Column(
                    children: [
                      if (hasActiveLog) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_circle,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Entrada registrada',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      _formatDateTime(
                                          state.activeTimeLog!.clockIn),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações (opcional)',
                          hintText: 'Digite observações sobre o registro...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: BlocBuilder<TimeLogBloc, TimeLogState>(
                              builder: (context, state) {
                                final isLoading = state is TimeLogClockingIn ||
                                    state is TimeLogClockingOut;

                                return ElevatedButton.icon(
                                  onPressed: hasActiveLog || isLoading
                                      ? null
                                      : _clockIn,
                                  icon: isLoading && state is TimeLogClockingIn
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.login),
                                  label: const Text('Entrada'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: AppColors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BlocBuilder<TimeLogBloc, TimeLogState>(
                              builder: (context, state) {
                                final isLoading = state is TimeLogClockingIn ||
                                    state is TimeLogClockingOut;

                                return ElevatedButton.icon(
                                  onPressed: !hasActiveLog || isLoading
                                      ? null
                                      : _clockOut,
                                  icon: isLoading && state is TimeLogClockingOut
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.logout),
                                  label: const Text('Saída'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: AppColors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Histórico de Registros',
              style: AppTextStyles.h6,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatisticsCard(),
        const SizedBox(height: 16),
        BlocBuilder<TimeLogBloc, TimeLogState>(
          builder: (context, state) {
            if (state is TimeLogSelecting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is TimeLogLoadByStudentSuccess) {
              if (state.timeLogs.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum registro encontrado',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Agrupar logs por data
              final groupedLogs = _groupTimeLogsByDate(state.timeLogs);
              final sortedDates = groupedLogs.keys.toList()
                ..sort(
                    (a, b) => b.compareTo(a)); // Ordenar por data mais recente

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedDates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final logsForDate = groupedLogs[date]!;
                  return _DateGroupCard(
                    date: date,
                    timeLogs: logsForDate,
                  );
                },
              );
            }

            if (state is TimeLogSelectError) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar registros',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTimeLogs,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return BlocBuilder<TimeLogBloc, TimeLogState>(
      builder: (context, state) {
        if (state is TimeLogLoadByStudentSuccess) {
          final weeklyStats = _calculateWeeklyStats(state.timeLogs);
          final monthlyStats = _calculateMonthlyStats(state.timeLogs);

          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Estatísticas',
                        style: AppTextStyles.h6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatisticItem(
                          title: 'Esta Semana',
                          value:
                              '${weeklyStats['totalHours'].toStringAsFixed(1)}h',
                          subtitle: '${weeklyStats['totalDays']} dias',
                          icon: Icons.view_week,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatisticItem(
                          title: 'Este Mês',
                          value:
                              '${monthlyStats['totalHours'].toStringAsFixed(1)}h',
                          subtitle: '${monthlyStats['totalDays']} dias',
                          icon: Icons.calendar_month,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Map<String, dynamic> _calculateWeeklyStats(List<TimeLogEntity> timeLogs) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    double totalHours = 0;
    final daysWithLogs = <DateTime>{};

    for (final log in timeLogs) {
      if (log.clockIn.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          log.clockIn.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        if (log.clockOut != null) {
          final duration = log.clockOut!.difference(log.clockIn);
          totalHours += duration.inMinutes / 60.0;
        }
        daysWithLogs.add(
            DateTime(log.clockIn.year, log.clockIn.month, log.clockIn.day));
      }
    }

    return {
      'totalHours': totalHours,
      'totalDays': daysWithLogs.length,
    };
  }

  Map<String, dynamic> _calculateMonthlyStats(List<TimeLogEntity> timeLogs) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    double totalHours = 0;
    final daysWithLogs = <DateTime>{};

    for (final log in timeLogs) {
      if (log.clockIn.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          log.clockIn.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        if (log.clockOut != null) {
          final duration = log.clockOut!.difference(log.clockIn);
          totalHours += duration.inMinutes / 60.0;
        }
        daysWithLogs.add(
            DateTime(log.clockIn.year, log.clockIn.month, log.clockIn.day));
      }
    }

    return {
      'totalHours': totalHours,
      'totalDays': daysWithLogs.length,
    };
  }

  Map<DateTime, List<TimeLogEntity>> _groupTimeLogsByDate(
      List<TimeLogEntity> timeLogs) {
    final grouped = <DateTime, List<TimeLogEntity>>{};

    for (final log in timeLogs) {
      final date =
          DateTime(log.clockIn.year, log.clockIn.month, log.clockIn.day);
      grouped.putIfAbsent(date, () => []).add(log);
    }

    // Ordenar logs dentro de cada data por horário de entrada
    for (final logs in grouped.values) {
      logs.sort((a, b) => a.clockIn.compareTo(b.clockIn));
    }

    return grouped;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DateGroupCard extends StatelessWidget {
  final DateTime date;
  final List<TimeLogEntity> timeLogs;

  const _DateGroupCard({
    required this.date,
    required this.timeLogs,
  });

  @override
  Widget build(BuildContext context) {
    final totalHours = _calculateTotalHoursForDate();
    final isToday = _isToday(date);
    final isYesterday = _isYesterday(date);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isToday ? Icons.today : Icons.calendar_today,
                  color: isToday ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDateLabel(),
                        style: AppTextStyles.h6.copyWith(
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDate(date),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${totalHours.toStringAsFixed(1)}h',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...timeLogs.map((log) => _TimeLogItem(timeLog: log)).toList(),
          ],
        ),
      ),
    );
  }

  String _getDateLabel() {
    if (_isToday(date)) return 'Hoje';
    if (_isYesterday(date)) return 'Ontem';
    return _formatDate(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  double _calculateTotalHoursForDate() {
    double totalHours = 0;
    for (final log in timeLogs) {
      if (log.clockOut != null) {
        final duration = log.clockOut!.difference(log.clockIn);
        totalHours += duration.inMinutes / 60;
      }
    }
    return totalHours;
  }
}

class _TimeLogItem extends StatelessWidget {
  final TimeLogEntity timeLog;

  const _TimeLogItem({required this.timeLog});

  @override
  Widget build(BuildContext context) {
    final isActive = timeLog.clockOut == null;
    final duration = timeLog.clockOut != null
        ? timeLog.clockOut!.difference(timeLog.clockIn)
        : DateTime.now().difference(timeLog.clockIn);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.warning : AppColors.success,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.play_circle : Icons.check_circle,
                color: isActive ? AppColors.warning : AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isActive ? 'Em andamento' : 'Concluído',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entrada',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      _formatTime(timeLog.clockIn),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.textSecondary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saída',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      timeLog.clockOut != null
                          ? _formatTime(timeLog.clockOut!)
                          : '--:--',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (timeLog.description != null &&
              timeLog.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.note,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    timeLog.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }
}

class _StatisticItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatisticItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
