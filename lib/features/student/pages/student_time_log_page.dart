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
                    labelText: 'Hora de Saída (Opcional)',
                    prefixIcon: Icons.access_time_filled_outlined,
                    readOnly: true,
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

  void _confirmDeleteTimeLog(String timeLogId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Remoção'),
          content: const Text(
              'Tem a certeza que deseja remover este registo de tempo? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            AppButton(
              text: 'Remover',
              type: AppButtonType.text, // Ou um botão com cor de erro
              foregroundColor: Theme.of(context).colorScheme.error,
              onPressed: () {
                _studentBloc
                    .add(DeleteTimeLogRequestedEvent(timeLogId: timeLogId));
                Navigator.of(dialogContext).pop();
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
          onPressed: () => Modular.to.navigate('/student'),
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
              message = state.message;
            }
            if (state is StudentTimeLogDeleteSuccess) {
              message = state.message;
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
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.timeLogs.length,
                itemBuilder: (context, index) {
                  final log = state.timeLogs[index];
                  return _buildTimeLogCard(context, log);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
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

  Widget _buildTimeLogCard(BuildContext context, TimeLogEntity log) {
    final theme = Theme.of(context);
    final String checkInStr = log.checkInTime;
    final String checkOutStr =
        log.checkOutTime != null ? log.checkOutTime! : 'Pendente';
    final String hoursStr = log.hoursLogged != null
        ? '${log.hoursLogged!.toStringAsFixed(1)}h'
        : '-';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () =>
            _showAddEditTimeLogDialog(timeLog: log), // Permite editar ao tocar
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: log.approved == true
                      ? AppColors.success.withAlpha(30)
                      : theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd', 'pt_BR').format(log.logDate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: log.approved == true
                            ? AppColors.success
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'pt_BR')
                          .format(log.logDate)
                          .toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: log.approved == true
                            ? AppColors.success
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrada: $checkInStr  |  Saída: $checkOutStr',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (log.description != null &&
                        log.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        log.description!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          log.approved == true
                              ? Icons.check_circle
                              : Icons.hourglass_empty,
                          color: log.approved == true
                              ? AppColors.success
                              : AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.approved == true ? 'Aprovado' : 'Pendente',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: log.approved == true
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total: $hoursStr',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.hintColor),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddEditTimeLogDialog(timeLog: log);
                  } else if (value == 'delete') {
                    _confirmDeleteTimeLog(log.id);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar')),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                        leading:
                            Icon(Icons.delete_outline, color: AppColors.error),
                        title: Text('Remover')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
