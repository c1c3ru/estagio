// lib/features/supervisor/presentation/widgets/student_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';

import '../../../../core/constants/app_colors.dart'; // Para cores de status
import '../../../../domain/entities/student_entity.dart';

class StudentListWidget extends StatelessWidget {
  final List<StudentEntity> students;

  const StudentListWidget({
    super.key,
    required this.students,
  });

  Color _getStatusColor(StudentStatus status, BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case StudentStatus.active:
        return AppColors.statusActive;
      case StudentStatus.inactive:
        return AppColors.statusInactive;
      case StudentStatus.pending:
        return AppColors.statusPending;
      case StudentStatus.completed:
        return AppColors.statusCompleted;
      case StudentStatus.terminated:
        return AppColors.statusTerminated;
      case StudentStatus.unknown:
      default:
        return theme.hintColor;
    }
  }

  String _getDaysRemainingText(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final difference = end.difference(today).inDays;

    if (difference < 0) {
      return 'Contrato Encerrado';
    } else if (difference == 0) {
      return 'Termina Hoje';
    } else if (difference == 1) {
      return 'Termina Amanhã';
    } else if (difference <= 30) {
      return 'Termina em $difference dias';
    } else {
      return 'Término: ${DateFormat('dd/MM/yyyy').format(endDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (students.isEmpty) {
      // Embora a SupervisorDashboardPage já trate a lista vazia,
      // este widget pode ser reutilizado, então é bom ter um fallback.
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Nenhum estudante para exibir.'),
        ),
      );
    }

    return ListView.separated(
      itemCount: students.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      physics:
          const ClampingScrollPhysics(), // Para funcionar bem dentro de outro scroll, se necessário
      shrinkWrap:
          true, // Se estiver dentro de uma Column/ListView que não define altura
      itemBuilder: (context, index) {
        final student = students[index];
        _getStatusColor(
            student.role == UserRole.student
                ? StudentStatus.active
                : StudentStatus.inactive,
            context); // Exemplo simplificado de status
        // A StudentEntity não tem um campo 'status' direto como o enum StudentStatus.
        // A lógica de status do estudante (ativo, inativo, etc.) pode depender da data do contrato
        // ou de um campo 'is_active' na tabela 'users' ou 'students'.
        // Para este exemplo, vou usar a data do contrato para um status visual simples.
        final bool isActiveBasedOnContract =
            student.contractEndDate.isAfter(DateTime.now()) &&
                student.contractStartDate.isBefore(DateTime.now());
        final displayStatus = isActiveBasedOnContract
            ? StudentStatus.active
            : StudentStatus.inactive; // Simplificação
        final displayStatusColor = _getStatusColor(displayStatus, context);

        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical:
                  6.0), // Ajustado para não ter margem horizontal se a page já tiver padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: displayStatusColor.withAlpha(50),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: displayStatusColor,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            title: Text(
              student.fullName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 2),
                Text(
                  student.course,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: displayStatusColor),
                    const SizedBox(width: 4),
                    Text(
                      displayStatus
                          .displayName, // Usando a extensão para nome amigável
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: displayStatusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text('  •  ', style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(
                        student.contractEndDate != null
                            ? _getDaysRemainingText(student.contractEndDate)
                            : 'Sem data de término',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: theme.hintColor),
            onTap: () {
              // Navegar para a página de detalhes do estudante
              Modular.to.pushNamed('/supervisor/student-details/${student.id}');
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
          height: 0), // Sem separador visível, o Card já tem margem
    );
  }
}
