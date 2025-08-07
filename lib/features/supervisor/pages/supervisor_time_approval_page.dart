// lib/features/supervisor/presentation/pages/supervisor_time_approval_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:gestao_de_estagio/core/widgets/app_text_field.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as auth_state;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../domain/entities/time_log_entity.dart';
import '../bloc/supervisor_bloc.dart' as bloc;
import '../bloc/supervisor_event.dart' as event;
import '../bloc/supervisor_state.dart' as supervisor_state;
import '../widgets/supervisor_app_drawer.dart';
import '../../../core/utils/feedback_service.dart';

class SupervisorTimeApprovalPage extends StatefulWidget {
  const SupervisorTimeApprovalPage({super.key});

  @override
  State<SupervisorTimeApprovalPage> createState() =>
      _SupervisorTimeApprovalPageState();
}

class _SupervisorTimeApprovalPageState
    extends State<SupervisorTimeApprovalPage> {
  late bloc.SupervisorBloc _supervisorBloc;
  late AuthBloc _authBloc;
  String? _supervisorId;
  final Map<String, String> _studentNames = {};

  @override
  void initState() {
    super.initState();
    _supervisorBloc = Modular.get<bloc.SupervisorBloc>();
    _authBloc = Modular.get<AuthBloc>();

    final currentAuthState = _authBloc.state;
    if (currentAuthState is auth_state.AuthSuccess) {
      _supervisorId = currentAuthState.user.id;
    }
    // Ouve o AuthBloc para o caso de o ID do supervisor mudar ou o login acontecer depois
    _authBloc.stream.listen((authState) {
      if (mounted && authState is auth_state.AuthSuccess) {
        if (_supervisorId != authState.user.id) {
          setState(() {
            _supervisorId = authState.user.id;
          });
        }
      } else if (mounted && authState is auth_state.AuthUnauthenticated) {
        setState(() {
          _supervisorId = null;
        });
      }
    });

    // Carregar dados do dashboard primeiro se necessário
    if (_supervisorBloc.state
        is! supervisor_state.SupervisorDashboardLoadSuccess) {
      _supervisorBloc.add(event.LoadSupervisorDashboardDataEvent());
    }

    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
    // Carrega apenas os logs pendentes por padrão
    BlocProvider.of<bloc.SupervisorBloc>(context, listen: false)
        .add(const event.LoadAllTimeLogsForApprovalEvent(pendingOnly: true));
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Função para buscar o nome do estudante se não estiver no cache
  // Na prática, a lista de logs do BLoC/Usecase poderia já vir com os nomes dos estudantes (via join).
  // Esta é uma solução alternativa se a TimeLogEntity só tiver studentId.
  /// Versão síncrona para evitar rebuilds infinitos no FutureBuilder
  String _getStudentNameSync(
      String studentId, supervisor_state.SupervisorState currentState) {
    // Primeiro verifica o cache
    if (_studentNames.containsKey(studentId)) {
      return _studentNames[studentId]!;
    }

    // Se o estado atual do dashboard tiver a lista de estudantes, usa ela
    if (currentState is supervisor_state.SupervisorDashboardLoadSuccess) {
      try {
        final student =
            currentState.students.firstWhere((s) => s.id == studentId);
        final nameParts = student.fullName.split(' ');
        final displayName = nameParts.length >= 2
            ? '${nameParts[0]} ${nameParts[1]}'
            : student.fullName;
        _studentNames[studentId] = displayName;
        return displayName;
      } catch (e) {
        // Estudante não encontrado na lista do dashboard
      }
    }

    // Fallback: retorna ID truncado para evitar operações assíncronas
    return 'ID: ${studentId.substring(0, 6)}...';
  }

  void _showApprovalConfirmation(
      BuildContext pageContext, TimeLogEntity log, String studentName) {
    showDialog(
      context: pageContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Aprovação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deseja aprovar as horas de $studentName?'),
              const SizedBox(height: 8),
              Text('Data: ${DateFormat('dd/MM/yyyy').format(log.logDate)}'),
              Text('Horas: ${log.hoursLogged?.toStringAsFixed(1) ?? '-'}h'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_supervisorId != null) {
                  BlocProvider.of<bloc.SupervisorBloc>(pageContext,
                          listen: false)
                      .add(event.ApproveOrRejectTimeLogEvent(
                    timeLogId: log.id,
                    approved: true,
                    supervisorId: _supervisorId!,
                  ));
                }
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aprovar'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectionReasonDialog(BuildContext pageContext, String timeLogId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: pageContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rejeitar Registo de Tempo'),
          content: Form(
            key: formKey,
            child: AppTextField(
              controller: reasonController,
              labelText: 'Motivo da Rejeição (Opcional)',
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                if (_supervisorId != null) {
                  BlocProvider.of<bloc.SupervisorBloc>(pageContext,
                          listen: false)
                      .add(event.ApproveOrRejectTimeLogEvent(
                    timeLogId: timeLogId,
                    approved: false,
                    supervisorId: _supervisorId!,
                    rejectionReason: reasonController.text.trim(),
                  ));
                }
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(pageContext).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar Rejeição'),
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
        title: const Text('Aprovações de Horas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Recarregar Pendentes',
            onPressed: _loadPendingApprovals,
          ),
        ],
      ),
      drawer: const SupervisorAppDrawer(
          currentIndex: 2), // Ajuste o currentIndex conforme sua navegação
      bottomNavigationBar: const SupervisorBottomNavBar(
          currentIndex: 2), // Ajuste o currentIndex
      body: BlocConsumer<bloc.SupervisorBloc, supervisor_state.SupervisorState>(
        listener: (context, currentState) {
          if (currentState is supervisor_state.SupervisorOperationFailure) {
            FeedbackService.showError(context, currentState.message);
          } else if (currentState
                  is supervisor_state.SupervisorOperationSuccess &&
              (currentState.entity is TimeLogEntity ||
                  currentState.message.contains("Registo de tempo"))) {
            FeedbackService.showSuccess(context, currentState.message);
          }
        },
        builder: (context, currentState) {
          if (kDebugMode) {
            print(
                '🟡 SupervisorTimeApprovalPage: Estado atual: ${currentState.runtimeType}');
          }

          if (currentState is supervisor_state.SupervisorLoading) {
            return const LoadingIndicator();
          }

          if (currentState
              is supervisor_state.SupervisorTimeLogsForApprovalLoadSuccess) {
            if (kDebugMode) {
              print(
                  '🟡 SupervisorTimeApprovalPage: Renderizando ${currentState.timeLogs.length} logs');
            }

            if (currentState.timeLogs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 80, color: AppColors.success),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhum registo pendente!',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Todos os registos de tempo foram processados.',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.hintColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Recarregar',
                        onPressed: _loadPendingApprovals,
                        icon: Icons.refresh,
                        type: AppButtonType.outlined,
                      )
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadPendingApprovals,
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: currentState.timeLogs.length,
                itemBuilder: (context, index) {
                  final log = currentState.timeLogs[index];
                  // CORREÇÃO: Usar cache síncrono em vez de FutureBuilder para evitar loop infinito
                  final studentName =
                      _getStudentNameSync(log.studentId, currentState);
                  return _buildTimeLogApprovalCard(
                      context, log, studentName, index + 1);
                },
              ),
            );
          }

          if (currentState is supervisor_state.SupervisorOperationFailure &&
              BlocProvider.of<bloc.SupervisorBloc>(context, listen: false).state
                  is! supervisor_state
                  .SupervisorTimeLogsForApprovalLoadSuccess) {
            return _buildErrorStatePage(context, currentState.message);
          }

          return const LoadingIndicator();
        },
      ),
    );
  }

  Widget _buildErrorStatePage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 60, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorOccurred,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: AppStrings.tryAgain,
              onPressed: _loadPendingApprovals,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLogApprovalCard(BuildContext context, TimeLogEntity log,
      String studentName, int sequentialNumber) {
    final theme = Theme.of(context);
    final String checkInStr = _formatTimeOfDay(_parseTime(log.checkInTime));
    final String checkOutStr = _formatTimeOfDay(_parseTime(log.checkOutTime));
    final String hoursStr = log.hoursLogged != null
        ? '${log.hoursLogged!.toStringAsFixed(1)}h'
        : '-';

    return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            radius: 20,
                            child: Text(
                              sequentialNumber.toString(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Registro de Horas',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(log.logDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hoursStr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(context, Icons.login_outlined, 'Entrada:',
                          checkInStr),
                      if (checkOutStr != 'N/A')
                        _buildDetailRow(context, Icons.logout_outlined,
                            'Saída:', checkOutStr),
                      _buildDetailRow(context, Icons.hourglass_full_outlined,
                          'Horas Registadas:', hoursStr),
                      if (log.description != null &&
                          log.description!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.notes_outlined,
                                      size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Descrição:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.description!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Botões de Ação
                if (log.approved == false &&
                    _supervisorId != null &&
                    _supervisorId!.isNotEmpty)
                  BlocBuilder<bloc.SupervisorBloc,
                      supervisor_state.SupervisorState>(
                    builder: (context, state) {
                      bool isLoadingAction =
                          state is supervisor_state.SupervisorLoading;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: isLoadingAction
                                ? null
                                : () =>
                                    _showRejectionReasonDialog(context, log.id),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Rejeitar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: isLoadingAction
                                ? null
                                : () => _showApprovalConfirmation(
                                    context, log, studentName),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Aprovar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else if (log.approved == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.success, size: 18),
                        SizedBox(width: 6),
                        Text('Aprovado',
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ));
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label ',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
