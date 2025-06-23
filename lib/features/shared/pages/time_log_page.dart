import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/bloc/time_log_bloc.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registro de Ponto',
              style: AppTextStyles.h6,
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
                                Icons.access_time,
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
        const Text(
          'Histórico de Registros',
          style: AppTextStyles.h6,
        ),
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

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.timeLogs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final timeLog = state.timeLogs[index];
                  return _TimeLogCard(timeLog: timeLog);
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _TimeLogCard extends StatelessWidget {
  final dynamic timeLog;

  const _TimeLogCard({required this.timeLog});

  @override
  Widget build(BuildContext context) {
    final isActive = timeLog.clockOut == null;
    final duration = timeLog.clockOut != null
        ? timeLog.clockOut!.difference(timeLog.clockIn)
        : DateTime.now().difference(timeLog.clockIn);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.play_circle : Icons.check_circle,
                  color: isActive ? AppColors.warning : AppColors.success,
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
            const SizedBox(height: 12),
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
            if (timeLog.notes != null && timeLog.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Observações',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                timeLog.notes!,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
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
