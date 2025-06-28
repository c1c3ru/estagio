// lib/features/shared/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:gestao_de_estagio/core/enums/contract_status.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import '../../../core/constants/app_colors.dart'; // Para as cores de status

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor =
        Colors.white, // Padrão para texto branco sobre fundos coloridos
    this.icon,
    this.fontSize = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
  });

  // Construtores de fábrica para status comuns (usando StudentStatus como exemplo)
  factory StatusBadge.fromStudentStatus(
      StudentStatus status, BuildContext context) {
    Color bgColor;
    Color fgColor = Colors.white; // Padrão
    IconData? statusIcon;

    switch (status) {
      case StudentStatus.active:
        bgColor = AppColors.statusActive;
        statusIcon = Icons.check_circle_outline;
        break;
      case StudentStatus.inactive:
        bgColor = AppColors.statusInactive;
        fgColor =
            AppColors.textPrimaryDark; // Texto escuro para fundo cinza claro
        statusIcon = Icons.pause_circle_outline_outlined;
        break;
      case StudentStatus.pending:
        bgColor = AppColors.statusPending;
        fgColor = AppColors.textPrimaryLight; // Texto escuro para fundo amarelo
        statusIcon = Icons.hourglass_empty_outlined;
        break;
      case StudentStatus.completed:
        bgColor = AppColors.statusCompleted;
        statusIcon = Icons.task_alt_outlined;
        break;
      case StudentStatus.terminated:
        bgColor = AppColors.statusTerminated;
        statusIcon = Icons.cancel_outlined;
        break;
      case StudentStatus.unknown:
      default:
        bgColor = Theme.of(context).disabledColor;
        fgColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
        statusIcon = Icons.help_outline;
        break;
    }
    return StatusBadge(
      text: status.displayName, // Usa a extensão do enum
      backgroundColor: bgColor,
      textColor: fgColor,
      icon: statusIcon,
    );
  }

  // Construtor de fábrica para ContractStatus
  factory StatusBadge.fromContractStatus(
      ContractStatus status, BuildContext context) {
    Color bgColor;
    Color fgColor = Colors.white;
    IconData? statusIcon;

    switch (status) {
      case ContractStatus.active:
        bgColor = AppColors.statusActive;
        statusIcon = Icons.play_circle_filled_outlined;
        break;
      case ContractStatus.pendingApproval:
        bgColor = AppColors.statusPending;
        fgColor = AppColors.textPrimaryLight;
        statusIcon = Icons.hourglass_empty_outlined;
        break;
      case ContractStatus.expired:
        bgColor = AppColors.statusExpired;
        statusIcon = Icons.event_busy_outlined;
        break;
      case ContractStatus.terminated:
        bgColor = AppColors.statusTerminated;
        statusIcon = Icons.do_not_disturb_on_outlined;
        break;
      case ContractStatus.completed:
        bgColor = AppColors.statusCompleted;
        statusIcon = Icons.assignment_turned_in_outlined;
        break;
    }
    return StatusBadge(
      text: status.displayName,
      backgroundColor: bgColor,
      textColor: fgColor,
      icon: statusIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Para que o badge se ajuste ao conteúdo
        children: [
          if (icon != null) ...[
            Icon(icon,
                color: textColor,
                size: fontSize + 2), // Ícone um pouco maior que o texto
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
