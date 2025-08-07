// lib/features/supervisor/presentation/widgets/student_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart'; // Para formatação de datas

import '../../../../core/constants/app_colors.dart'; // Para cores de status
import '../../../../domain/entities/student_entity.dart';
import 'package:gestao_de_estagio/core/enums/student_status.dart';
import '../../shared/animations/lottie_animations.dart';

class StudentListWidget extends StatelessWidget {
  final List<StudentEntity> students;
  final void Function(StudentEntity student)? onEdit;
  final void Function(StudentEntity student)? onDelete;

  const StudentListWidget({
    super.key,
    required this.students,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor(StudentStatus status, BuildContext context) {
    Theme.of(context);
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
          padding: EdgeInsets.all(32.0),
          child: LottieEmptyStateWidget(
            message: 'Nenhum estudante para exibir.',
            size: 120,
          ),
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
        final displayStatus = student.contractEndDate.isAfter(DateTime.now()) &&
                student.contractStartDate.isBefore(DateTime.now())
            ? StudentStatus.active
            : StudentStatus.inactive;
        final displayStatusColor = _getStatusColor(displayStatus, context);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.greyDark
              : AppColors.surface,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textHint
                          : theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: displayStatusColor),
                      const SizedBox(width: 4),
                      Text(
                        displayStatus.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: displayStatusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text('  •  ', style: TextStyle(color: Colors.grey)),
                      Expanded(
                        child: Text(
                          _getDaysRemainingText(student.contractEndDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textHint
                                    : theme.hintColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      tooltip: 'Editar',
                      onPressed: () => onEdit!(student),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Remover',
                      onPressed: () => onDelete!(student),
                    ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.hintColor),
                ],
              ),
              onTap: () {
                Modular.to
                    .pushNamed('/supervisor/student-details/${student.id}');
              },
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
          height: 0), // Sem separador visível, o Card já tem margem
    );
  }
}
