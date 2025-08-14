// lib/features/supervisor/presentation/pages/student_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gestao_de_estagio/core/enums/contract_status.dart';
import 'package:gestao_de_estagio/core/enums/student_status.dart'
    as student_status_enum;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../domain/entities/student_entity.dart';
import '../../../../domain/entities/time_log_entity.dart';
import '../../../../domain/entities/contract_entity.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../../../../domain/repositories/i_student_repository.dart';

class StudentDetailsPage extends StatefulWidget {
  final String studentId;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  late SupervisorBloc _supervisorBloc;

  @override
  void initState() {
    super.initState();
    _supervisorBloc = Modular.get<SupervisorBloc>();
    // Carrega os detalhes do estudante, seus logs e contratos
    _supervisorBloc
        .add(LoadStudentDetailsForSupervisorEvent(studentId: widget.studentId));
  }

  Future<void> _refreshDetails() async {
    _supervisorBloc
        .add(LoadStudentDetailsForSupervisorEvent(studentId: widget.studentId));
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Color _getStatusColor(
      student_status_enum.StudentStatus status, BuildContext context) {
    switch (status) {
      case student_status_enum.StudentStatus.active:
        return AppColors.statusActive;
      case student_status_enum.StudentStatus.inactive:
        return AppColors.statusInactive;
      case student_status_enum.StudentStatus.pending:
        return AppColors.statusPending;
      case student_status_enum.StudentStatus.completed:
        return AppColors.statusCompleted;
      case student_status_enum.StudentStatus.terminated:
        return AppColors.statusTerminated;
    }
  }

  Color _getContractStatusColor(ContractStatus status, BuildContext context) {
    switch (status) {
      case ContractStatus.active:
        return AppColors.statusActive;
      case ContractStatus.pendingApproval:
        return AppColors.statusPending;
      case ContractStatus.completed:
        return AppColors.statusCompleted;
      case ContractStatus.expired:
        return AppColors.statusExpired;
      case ContractStatus.terminated:
        return AppColors.statusTerminated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Estudante'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Recarregar',
            onPressed: _refreshDetails,
          ),
          // Botão de editar pode ser adicionado aqui se o estado permitir
        ],
      ),
      body: BlocBuilder<SupervisorBloc, SupervisorState>(
        bloc: _supervisorBloc,
        builder: (context, state) {
          if (state is SupervisorLoading &&
              state is! SupervisorStudentDetailsLoadSuccess) {
            if (_supervisorBloc.state is! SupervisorStudentDetailsLoadSuccess) {
              return const LoadingIndicator();
            }
          }

          if (state is SupervisorStudentDetailsLoadSuccess) {
            final student = state.student;
            return RefreshIndicator(
              onRefresh: _refreshDetails,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileHeader(context, student),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                      context, 'Informações do Contrato Principal'),
                  if (state.contracts.isNotEmpty)
                    _buildContractInfoCard(
                        context,
                        state.contracts
                            .first) // Mostra o primeiro contrato como exemplo
                  else
                    const Text('Nenhum contrato ativo encontrado.'),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Progresso e Horas'),
                  _buildProgressSection(context, student),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Registos de Tempo Recentes'),
                  _buildRecentTimeLogs(context, state.timeLogs),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Editar Perfil do Estudante',
                    icon: Icons.edit_outlined,
                    onPressed: () {
                      Modular.to
                          .pushNamed('/supervisor/student-edit/${student.id}');
                    },
                    type: AppButtonType.outlined,
                  ),
                ],
              ),
            );
          }

          if (state is SupervisorOperationFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    AppButton(
                        text: AppStrings.tryAgain, onPressed: _refreshDetails),
                  ],
                ),
              ),
            );
          }
          return const LoadingIndicator(); // Estado inicial ou de carregamento
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, StudentEntity student) {
    final theme = Theme.of(context);
    final bool isActiveBasedOnContract =
        student.contractEndDate.isAfter(DateTime.now()) &&
            student.contractStartDate.isBefore(DateTime.now());
    final displayStatus = isActiveBasedOnContract
        ? student_status_enum.StudentStatus.active
        : student_status_enum.StudentStatus.inactive;
    final displayStatusColor = _getStatusColor(displayStatus, context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: student.profilePictureUrl != null &&
                          student.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(student.profilePictureUrl!)
                      : null,
                  child: student.profilePictureUrl == null ||
                          student.profilePictureUrl!.isEmpty
                      ? Text(
                          student.fullName.isNotEmpty
                              ? student.fullName[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(student.course, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 10, color: displayStatusColor),
                          const SizedBox(width: 6),
                          Text(
                            displayStatus.displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: displayStatusColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.badge_outlined, 'Matrícula',
                student.registrationNumber),
            _buildInfoRow(context, Icons.email_outlined, 'Email',
                student.userEmail ?? 'Não informado'),
            _buildInfoRow(context, Icons.phone_outlined, 'Telefone',
                student.phoneNumber ?? 'Não informado'),
            _buildInfoRow(context, Icons.cake_outlined, 'Nascimento',
                DateFormat('dd/MM/yyyy').format(student.birthDate)),
            _buildInfoRow(context, Icons.supervisor_account_outlined,
                'Orientador(a)', student.advisorName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value,
                  style: theme.textTheme.bodyMedium, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContractInfoCard(BuildContext context, ContractEntity contract) {
    final theme = Theme.of(context);
    final statusColor = _getContractStatusColor(
      ContractStatus.fromString(contract.status),
      context,
    );
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tipo: ${contract.contractType}',
                    style: theme.textTheme.titleMedium),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ContractStatus.fromString(contract.status).displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow(context, Icons.play_arrow_outlined, 'Início',
                DateFormat('dd/MM/yyyy').format(contract.startDate)),
            _buildInfoRow(context, Icons.stop_outlined, 'Término',
                DateFormat('dd/MM/yyyy').format(contract.endDate)),
            if (contract.description != null &&
                contract.description!.isNotEmpty)
              _buildInfoRow(context, Icons.description_outlined, 'Descrição',
                  contract.description!),
            if (contract.documentUrl != null &&
                contract.documentUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AppButton(
                  text: 'Ver Documento',
                  icon: Icons.link_outlined,
                  onPressed: () {
                    _launchUrl(contract.documentUrl!);
                  },
                  type: AppButtonType.text,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, StudentEntity student) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progresso das Horas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: Modular.get<IStudentRepository>()
                  .getStudentDashboard(student.id)
                  .then((either) => either.getOrElse(() => {})),
              builder: (context, snapshot) {
                final approved = (snapshot.data?['timeStats']?['approvedHoursTotal']
                            as num?)
                        ?.toDouble() ??
                    student.totalHoursCompleted;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${approved.toStringAsFixed(1)}h completas',
                        style: theme.textTheme.bodyMedium),
                    Text('${student.totalHoursRequired.toStringAsFixed(1)}h (Meta)',
                        style: theme.textTheme.bodyMedium),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            if (student.totalHoursRequired > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.0, // Pode ser ajustado quando approved for carregado via FutureBuilder
                  minHeight: 12,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withAlpha(100),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              )
            else
              const Text('Meta de horas não definida.'),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.hourglass_empty_outlined,
                'Horas Restantes', '${0.0.toStringAsFixed(1)}h'),
            _buildInfoRow(context, Icons.track_changes_outlined, 'Meta Semanal',
                '${student.weeklyHoursTarget.toStringAsFixed(1)}h'),
            _buildInfoRow(
              context,
              Icons.warning_amber_outlined,
              'Em Dia?',
              'Atenção',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTimeLogs(BuildContext context, List<TimeLogEntity> logs) {
    final theme = Theme.of(context);
    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Nenhum registo de tempo recente.')),
      );
    }
    // Mostra apenas os 3 mais recentes, por exemplo
    final recentLogsToShow = logs.take(3).toList();

    return Column(
      children: recentLogsToShow
          .map((log) => Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: log.approved == true
                        ? AppColors.success.withAlpha(40)
                        : theme.colorScheme.secondaryContainer,
                    child: Icon(
                      log.approved == true
                          ? Icons.check_circle_outline
                          : Icons.hourglass_top_outlined,
                      color: log.approved == true
                          ? AppColors.success
                          : theme.colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${DateFormat('dd/MM/yy').format(log.logDate)}: '
                    '${_formatTimeOfDay(_parseTimeOfDay(log.checkInTime))} - '
                    '${_formatTimeOfDay(_parseTimeOfDay(log.checkOutTime))}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(log.description ?? 'Sem descrição',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                      '${log.hoursLogged?.toStringAsFixed(1) ?? "-"}h',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ))
          .toList(),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o documento.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir documento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
