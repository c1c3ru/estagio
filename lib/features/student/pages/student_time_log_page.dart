// lib/features/student/presentation/pages/student_time_log_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as auth_state;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart'; // Para validação no formulário
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../domain/entities/time_log_entity.dart';

import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../core/utils/feedback_service.dart';

class StudentTimeLogPage extends StatefulWidget {
  const StudentTimeLogPage({super.key});

  @override
  State<StudentTimeLogPage> createState() => _StudentTimeLogPageState();
}

class _StudentTimeLogPageState extends State<StudentTimeLogPage> {
  late StudentBloc _studentBloc;
  late AuthBloc _authBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _studentBloc = Modular.get<StudentBloc>();
    _authBloc = Modular.get<AuthBloc>();

    final currentAuthState = _authBloc.state;
    if (currentAuthState is auth_state.AuthSuccess) {
      _currentUserId = currentAuthState.user.id;
      if (_currentUserId != null) {
        _studentBloc.add(LoadStudentTimeLogsEvent(userId: _currentUserId!));
      }
    }

    _authBloc.stream.listen((authState) {
      if (mounted && authState is auth_state.AuthSuccess) {
        if (_currentUserId != authState.user.id) {
          setState(() {
            _currentUserId = authState.user.id;
          });
          if (_currentUserId != null) {
            _studentBloc.add(LoadStudentTimeLogsEvent(userId: _currentUserId!));
          }
        }
      } else if (mounted && authState is auth_state.AuthUnauthenticated) {
        setState(() {
          _currentUserId = null;
        });
      }
    });
  }

  Future<void> _refreshTimeLogs() async {
    if (_currentUserId != null) {
      _studentBloc.add(LoadStudentTimeLogsEvent(userId: _currentUserId!));
    }
  }

  TimeOfDay _stringToTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _timeOfDayToString(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  void _showAddEditTimeLogDialog({TimeLogEntity? timeLog}) {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'ID do utilizador não encontrado. Não é possível adicionar/editar registo.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController(
        text: timeLog != null
            ? DateFormat('dd/MM/yyyy').format(timeLog.logDate)
            : DateFormat('dd/MM/yyyy').format(DateTime.now()));
    final checkInController =
        TextEditingController(text: timeLog != null ? timeLog.checkInTime : '');
    final checkOutController = TextEditingController(
        text: timeLog?.checkOutTime != null ? timeLog!.checkOutTime! : '');
    final descriptionController =
        TextEditingController(text: timeLog?.description ?? '');

    DateTime selectedDate = timeLog?.logDate ?? DateTime.now();
    TimeOfDay? selectedCheckInTime = timeLog?.checkInTime != null
        ? _stringToTimeOfDay(timeLog!.checkInTime)
        : null;
    TimeOfDay? selectedCheckOutTime = timeLog?.checkOutTime != null
        ? _stringToTimeOfDay(timeLog!.checkOutTime!)
        : null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(timeLog == null
              ? 'Adicionar Registo de Tempo'
              : 'Editar Registo de Tempo'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Campo de Data
                  AppTextField(
                    controller: dateController,
                    labelText: 'Data',
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    validator: (value) =>
                        Validators.required(value, fieldName: 'Data'),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(
                            days:
                                1)), // Permite até amanhã para evitar problemas de fuso
                        locale: const Locale('pt', 'BR'),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          // setState do diálogo, não da página
                          selectedDate = picked;
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo Check-in
                  AppTextField(
                    controller: checkInController,
                    labelText: 'Hora de Entrada',
                    prefixIcon: Icons.access_time_outlined,
                    readOnly: true,
                    validator: (value) => Validators.required(value,
                        fieldName: 'Hora de Entrada'),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: selectedCheckInTime ?? TimeOfDay.now(),
                      );
                      if (picked != null && picked != selectedCheckInTime) {
                        setState(() {
                          selectedCheckInTime = picked;
                          checkInController.text = _timeOfDayToString(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo Check-out
                  AppTextField(
                    controller: checkOutController,
                    labelText: 'Hora de Saída',
                    prefixIcon: Icons.access_time_filled_outlined,
                    readOnly: true,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          selectedCheckInTime != null &&
                          selectedCheckOutTime != null) {
                        final checkInMinutes = selectedCheckInTime!.hour * 60 +
                            selectedCheckInTime!.minute;
                        final checkOutMinutes =
                            selectedCheckOutTime!.hour * 60 +
                                selectedCheckOutTime!.minute;
                        if (checkOutMinutes <= checkInMinutes) {
                          return 'Hora de saída deve ser posterior à entrada';
                        }
                      }
                      return null;
                    },
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: selectedCheckOutTime ?? TimeOfDay.now(),
                      );
                      if (picked != null && picked != selectedCheckOutTime) {
                        setState(() {
                          selectedCheckOutTime = picked;
                          checkOutController.text = _timeOfDayToString(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo Descrição
                  AppTextField(
                    controller: descriptionController,
                    labelText: 'Descrição (Opcional)',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            AppButton(
              text: timeLog == null ? 'Adicionar' : AppStrings.save,
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  if (selectedCheckInTime == null) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Por favor, selecione a hora de entrada.')),
                    );
                    return;
                  }

                  if (timeLog == null) {
                    // Criar novo
                    _studentBloc.add(CreateManualTimeLogEvent(
                      userId: _currentUserId!,
                      logDate: selectedDate,
                      checkInTime: selectedCheckInTime!,
                      checkOutTime: selectedCheckOutTime,
                      description: descriptionController.text.trim(),
                    ));
                  } else {
                    // Editar existente
                    // A lógica de atualização no BLoC precisa ser capaz de lidar com campos parciais
                    // ou este evento precisa enviar a entidade TimeLogEntity completa.
                    // Por agora, vamos assumir que o evento UpdateManualTimeLogEvent pode lidar com isso.
                    _studentBloc.add(UpdateManualTimeLogEvent(
                      timeLogId: timeLog.id,
                      logDate: selectedDate,
                      checkInTime: selectedCheckInTime,
                      checkOutTime: selectedCheckOutTime,
                      description: descriptionController.text.trim(),
                    ));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.timeLog),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.navigate('/student/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar Logs',
            onPressed: _refreshTimeLogs,
          ),
        ],
      ),
      body: BlocConsumer<StudentBloc, StudentState>(
        bloc: _studentBloc,
        listener: (context, state) {
          if (state is StudentOperationFailure) {
            FeedbackService.showError(context, state.message);
          } else if (state is StudentTimeLogOperationSuccess ||
              state is StudentTimeLogDeleteSuccess) {
            String message = 'Operação realizada com sucesso!';
            if (state is StudentTimeLogOperationSuccess) {
              message = state.message.isNotEmpty
                  ? state.message
                  : 'Registro salvo com sucesso!';
            }
            if (state is StudentTimeLogDeleteSuccess) {
              message = state.message.isNotEmpty
                  ? state.message
                  : 'Registro removido com sucesso!';
            }
            FeedbackService.showSuccess(context, message);
            _refreshTimeLogs();
          }
        },
        builder: (context, state) {
          if (state is StudentLoading && state is! StudentTimeLogsLoadSuccess) {
            if (_studentBloc.state is! StudentTimeLogsLoadSuccess) {
              // Evita loading sobre lista antiga
              return const LoadingIndicator();
            }
          }

          if (state is StudentTimeLogsLoadSuccess) {
            if (state.timeLogs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off_outlined,
                        size: 60, color: theme.hintColor),
                    const SizedBox(height: 16),
                    const Text('Nenhum registo de tempo encontrado.',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Adicionar Primeiro Registo',
                      onPressed: () => _showAddEditTimeLogDialog(),
                      icon: Icons.add_circle_outline,
                    )
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshTimeLogs,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTimeLogTable(state.timeLogs),
                    const SizedBox(height: 16),
                    _buildMonthlySummary(state.timeLogs),
                  ],
                ),
              ),
            );
          }
          if (state is StudentOperationFailure &&
              _studentBloc.state is! StudentTimeLogsLoadSuccess) {
            return _buildErrorStatePage(context, state.message);
          }
          // Fallback para loading ou estado inicial
          return const LoadingIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditTimeLogDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Registo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildErrorStatePage(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorOccurred,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: AppStrings.tryAgain,
              onPressed: _refreshTimeLogs,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLogTable(List<TimeLogEntity> timeLogs) {
    final groupedLogs = _groupLogsByDate(timeLogs);
    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registro de Horas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: MaterialStateProperty.all(
                    AppColors.primary.withOpacity(0.1)),
                columns: const [
                  DataColumn(
                      label: Text('Data',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Entrada',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Saída',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: sortedDates.map((date) {
                  final dayLogs = groupedLogs[date]!;
                  final totalHours = _calculateDayHours(dayLogs);
                  final isApproved =
                      dayLogs.every((log) => log.approved == true);

                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(date))),
                      DataCell(Text(dayLogs.isNotEmpty
                          ? _formatTime(dayLogs[0].checkInTime)
                          : '-')),
                      DataCell(Text(
                          dayLogs.isNotEmpty && dayLogs[0].checkOutTime != null
                              ? _formatTime(dayLogs[0].checkOutTime!)
                              : '-')),
                      DataCell(Text('${totalHours.toStringAsFixed(1)}h',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? AppColors.success
                                : AppColors.warning,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isApproved ? 'Aprovado' : 'Pendente',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(List<TimeLogEntity> timeLogs) {
    final currentMonth = DateTime.now();
    final monthlyLogs = timeLogs
        .where((log) =>
            log.logDate.year == currentMonth.year &&
            log.logDate.month == currentMonth.month)
        .toList();

    final totalHours =
        monthlyLogs.fold<double>(0, (sum, log) => sum + (log.hoursLogged ?? 0));
    final approvedHours = monthlyLogs
        .where((log) => log.approved == true)
        .fold<double>(0, (sum, log) => sum + (log.hoursLogged ?? 0));
    final pendingHours = totalHours - approvedHours;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo - ${DateFormat('MMMM yyyy', 'pt_BR').format(currentMonth)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total', '${totalHours.toStringAsFixed(1)}h',
                    AppColors.primary),
                _buildSummaryItem('Aprovadas',
                    '${approvedHours.toStringAsFixed(1)}h', AppColors.success),
                _buildSummaryItem('Pendentes',
                    '${pendingHours.toStringAsFixed(1)}h', AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalHours > 0 ? approvedHours / totalHours : 0,
              backgroundColor: AppColors.warning.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
            const SizedBox(height: 8),
            Text(
              'Progresso de aprovação: ${totalHours > 0 ? ((approvedHours / totalHours) * 100).toStringAsFixed(1) : 0}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Map<DateTime, List<TimeLogEntity>> _groupLogsByDate(
      List<TimeLogEntity> timeLogs) {
    final Map<DateTime, List<TimeLogEntity>> grouped = {};
    for (final log in timeLogs) {
      final dateKey =
          DateTime(log.logDate.year, log.logDate.month, log.logDate.day);
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }
    return grouped;
  }

  double _calculateDayHours(List<TimeLogEntity> dayLogs) {
    double totalHours = 0;
    for (final log in dayLogs) {
      if (log.checkOutTime != null) {
        final checkInParts = log.checkInTime.split(':');
        final checkOutParts = log.checkOutTime!.split(':');

        final checkInMinutes =
            int.parse(checkInParts[0]) * 60 + int.parse(checkInParts[1]);
        final checkOutMinutes =
            int.parse(checkOutParts[0]) * 60 + int.parse(checkOutParts[1]);

        final diffMinutes = checkOutMinutes - checkInMinutes;
        totalHours += diffMinutes / 60.0;
      }
    }
    return totalHours;
  }

  String _formatTime(String time) {
    return time.length >= 5 ? time.substring(0, 5) : time;
  }
}
