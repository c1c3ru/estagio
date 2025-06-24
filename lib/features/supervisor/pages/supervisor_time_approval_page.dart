// lib/features/supervisor/presentation/pages/supervisor_time_approval_page.dart

import 'package:flutter/material.dart';
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

    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
    // Carrega apenas os logs pendentes por padrão
    _supervisorBloc
        .add(const event.LoadAllTimeLogsForApprovalEvent(pendingOnly: true));
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  // Função para buscar o nome do estudante se não estiver no cache
  // Na prática, a lista de logs do BLoC/Usecase poderia já vir com os nomes dos estudantes (via join).
  // Esta é uma solução alternativa se a TimeLogEntity só tiver studentId.
  Future<String> _getStudentName(
      String studentId, supervisor_state.SupervisorState currentState) async {
    if (_studentNames.containsKey(studentId)) {
      return _studentNames[studentId]!;
    }
    // Se o estado atual do dashboard tiver a lista de estudantes, podemos usá-la
    if (currentState is supervisor_state.SupervisorDashboardLoadSuccess) {
      try {
        final student =
            currentState.students.firstWhere((s) => s.id == studentId);
        _studentNames[studentId] = student.fullName;
        return student.fullName;
      } catch (e) {
        // Estudante não encontrado na lista do dashboard, poderia buscar individualmente
      }
    }
    // Fallback: buscar o nome do estudante (isso pode ser ineficiente se feito para cada item da lista)
    // O ideal é que o evento LoadAllTimeLogsForApprovalEvent já traga os nomes.
    // Por agora, retornamos o ID.
    // logger.w("Nome do estudante para ID $studentId não encontrado no cache nem no estado do dashboard.");
    return 'ID: ${studentId.substring(0, 6)}...';
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
            AppButton(
              text: 'Confirmar Rejeição',
              backgroundColor: Theme.of(pageContext).colorScheme.error,
              onPressed: () {
                if (_supervisorId != null) {
                  _supervisorBloc.add(event.ApproveOrRejectTimeLogEvent(
                    timeLogId: timeLogId,
                    approved: false,
                    supervisorId: _supervisorId!,
                    rejectionReason: reasonController.text.trim(),
                  ));
                }
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
        bloc: _supervisorBloc,
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
          if (currentState is supervisor_state.SupervisorLoading &&
              currentState is! supervisor_state
                  .SupervisorTimeLogsForApprovalLoadSuccess) {
            if (_supervisorBloc.state
                is! supervisor_state.SupervisorTimeLogsForApprovalLoadSuccess) {
              return const LoadingIndicator();
            }
          }

          if (currentState
              is supervisor_state.SupervisorTimeLogsForApprovalLoadSuccess) {
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
                  // Para obter o nome do estudante, você pode fazer um FutureBuilder aqui
                  // ou garantir que a entidade TimeLogEntity já venha com o nome do estudante.
                  // Por simplicidade, vou usar a função _getStudentName que pode ser otimizada.
                  return FutureBuilder<String>(
                      future: _getStudentName(
                          log.studentId, currentState), // Passa o estado atual
                      builder: (context, snapshot) {
                        final studentName =
                            snapshot.data ?? 'A carregar nome...';
                        return _buildTimeLogApprovalCard(
                            context, log, studentName);
                      });
                },
              ),
            );
          }

          if (currentState is supervisor_state.SupervisorOperationFailure &&
              _supervisorBloc.state is! supervisor_state
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

  Widget _buildTimeLogApprovalCard(
      BuildContext context, TimeLogEntity log, String studentName) {
    final theme = Theme.of(context);
    final String checkInStr = _formatTimeOfDay(log.checkInTime);
    final String checkOutStr = _formatTimeOfDay(log.checkOutTime);
    final String hoursStr = log.hoursLogged != null
        ? '${log.hoursLogged!.toStringAsFixed(1)}h'
        : '-';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    studentName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(log.logDate),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildDetailRow(
                context, Icons.login_outlined, 'Entrada:', checkInStr),
            if (log.checkOutTime != null)
              _buildDetailRow(
                  context, Icons.logout_outlined, 'Saída:', checkOutStr),
            _buildDetailRow(context, Icons.hourglass_full_outlined,
                'Horas Registadas:', hoursStr),
            if (log.description != null && log.description!.isNotEmpty)
              _buildDetailRow(context, Icons.notes_outlined, 'Descrição:',
                  log.description!),

            const SizedBox(height: 12),
            // Botões de Ação
            if (!log.approved &&
                _supervisorId !=
                    null) // Mostra botões apenas se não aprovado e supervisorId estiver disponível
              BlocBuilder<bloc.SupervisorBloc,
                  supervisor_state.SupervisorState>(
                bloc: _supervisorBloc, // Usa o BLoC da página
                builder: (context, state) {
                  bool isLoadingAction =
                      state is supervisor_state.SupervisorLoading;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        text: 'Rejeitar',
                        onPressed: isLoadingAction
                            ? null
                            : () => _showRejectionReasonDialog(context, log.id),
                        type: AppButtonType.text,
                        foregroundColor: theme.colorScheme.error,
                        isLoading: isLoadingAction &&
                            _supervisorBloc.state is supervisor_state
                                .SupervisorLoading, // Verifica se este log específico está a ser processado
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Aprovar',
                        onPressed: isLoadingAction
                            ? null
                            : () {
                                if (_supervisorId != null) {
                                  _supervisorBloc
                                      .add(event.ApproveOrRejectTimeLogEvent(
                                    timeLogId: log.id,
                                    approved: true,
                                    supervisorId: _supervisorId!,
                                  ));
                                }
                              },
                        isLoading: isLoadingAction &&
                            _supervisorBloc.state
                                is supervisor_state.SupervisorLoading,
                      ),
                    ],
                  );
                },
              )
            else if (log.approved)
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  SizedBox(width: 4),
                  Text('Aprovado',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold)),
                ],
              )
          ],
        ),
      ),
    );
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
