// lib/core/services/notification_helper.dart
// Mantém para kDebugMode
// import 'package:flutter/material.dart'; // Removido: Unused import

import '../../domain/entities/contract_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/supervisor_entity.dart';
import '../../domain/entities/time_log_entity.dart';
// import '../constants/app_strings.dart'; // Removido: Unused import
import '../utils/date_utils.dart';
import '../utils/logger_utils.dart';
import 'notification_service.dart';

/// Helper para integrar notificações com casos de uso específicos do domínio
class NotificationHelper {
  static final NotificationService _notificationService = NotificationService();

  /// Notifica aprovação de registro de horas
  static Future<void> notifyTimeLogApproval({
    required TimeLogEntity timeLog,
    required StudentEntity student,
    required SupervisorEntity supervisor,
  }) async {
    try {
      const title = 'Horas Aprovadas! ✅';
      final hoursLogged = timeLog.hoursLogged?.toStringAsFixed(1) ?? '0.0';
      final body =
          'Suas horas do dia ${AppDateUtils.formatDate(timeLog.logDate)} '
          'foram aprovadas por ${supervisor.fullName}. '
          'Horas registradas: ${hoursLogged}h.';

      await _notificationService.scheduleLocalNotification(
        id: 'timelog_approval_${timeLog.id}',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.timeLogApproval,
        data: {
          'timeLogId': timeLog.id,
          'studentId': student.id,
          'supervisorId': supervisor.id,
          'action': 'view_timelog',
        },
      );

      logger.i(
          'Notificação de aprovação de horas enviada para ${student.fullName}');
    } catch (e) {
      logger.e('Erro ao enviar notificação de aprovação de horas: $e');
    }
  }

  /// Notifica rejeição de registro de horas
  static Future<void> notifyTimeLogRejection({
    required TimeLogEntity timeLog,
    required StudentEntity student,
    required SupervisorEntity supervisor,
    String? rejectionReason,
  }) async {
    try {
      const title = 'Horas Rejeitadas! ❌';
      final hoursLogged = timeLog.hoursLogged?.toStringAsFixed(1) ?? '0.0';
      final body =
          'Suas horas do dia ${AppDateUtils.formatDate(timeLog.logDate)} '
          'foram rejeitadas por ${supervisor.fullName}. '
          'Horas registradas: ${hoursLogged}h.${rejectionReason != null ? ' Motivo: $rejectionReason' : ''}';

      await _notificationService.scheduleLocalNotification(
        id: 'timelog_rejection_${timeLog.id}',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.timeLogRejection,
        data: {
          'timeLogId': timeLog.id,
          'studentId': student.id,
          'supervisorId': supervisor.id,
          'action': 'view_timelog',
        },
      );

      logger.i(
          'Notificação de rejeição de horas enviada para ${student.fullName}');
    } catch (e) {
      logger.e('Erro ao enviar notificação de rejeição de horas: $e');
    }
  }

  /// Notifica contratos próximos do vencimento
  static Future<void> notifyContractExpiring({
    required ContractEntity contract,
    required StudentEntity student,
    required SupervisorEntity supervisor,
    required int daysUntilExpiry,
  }) async {
    try {
      const title = 'Contrato Expirando ⚠️';
      final body =
          'O contrato de ${student.fullName} expira em $daysUntilExpiry dias '
          '(${AppDateUtils.formatDate(contract.endDate)}).';

      // Notifica o supervisor
      await _notificationService.scheduleLocalNotification(
        id: 'contract_expiring_supervisor_${contract.id}',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.contractExpiring,
        data: {
          'contractId': contract.id,
          'studentId': student.id,
          'supervisorId': supervisor.id,
          'daysUntilExpiry': daysUntilExpiry,
          'action': 'view_contract',
          'recipient': 'supervisor',
        },
      );

      // Notifica o estudante
      const studentTitle = 'Seu Contrato Expira em Breve ⚠️';
      final studentBody =
          'Seu contrato de estágio expira em $daysUntilExpiry dias '
          '(${AppDateUtils.formatDate(contract.endDate)}). '
          'Entre em contato com seu supervisor.';

      await _notificationService.scheduleLocalNotification(
        id: 'contract_expiring_student_${contract.id}',
        title: studentTitle,
        body: studentBody,
        scheduledDate: DateTime.now(),
        type: NotificationType.contractExpiring,
        data: {
          'contractId': contract.id,
          'studentId': student.id,
          'supervisorId': supervisor.id,
          'daysUntilExpiry': daysUntilExpiry,
          'action': 'view_contract',
          'recipient': 'student',
        },
      );

      logger.i(
          'Notificações de contrato expirando enviadas para ${student.fullName} e ${supervisor.fullName}');
    } catch (e) {
      logger.e('Erro ao enviar notificação de contrato expirando: $e');
    }
  }

  /// Notifica supervisor sobre novo estudante
  static Future<void> notifyNewStudent({
    required StudentEntity student,
    required SupervisorEntity supervisor,
  }) async {
    try {
      const title = 'Novo Estudante Atribuído 👨‍🎓';
      final body =
          '${student.fullName} foi atribuído como seu novo estagiário. '
          'Curso: ${student.course}.';

      await _notificationService.scheduleLocalNotification(
        id: 'new_student_${student.id}_${supervisor.id}',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.newStudent,
        data: {
          'studentId': student.id,
          'supervisorId': supervisor.id,
          'action': 'view_student',
        },
      );

      logger.i(
          'Notificação de novo estudante enviada para ${supervisor.fullName}');
    } catch (e) {
      logger.e('Erro ao enviar notificação de novo estudante: $e');
    }
  }

  /// Notifica estudante sobre check-in pendente
  static Future<void> notifyCheckInReminder({
    required StudentEntity student,
  }) async {
    try {
      const title = 'Lembrete: Registrar Entrada 🕐';
      const body = 'Não se esqueça de registrar sua entrada hoje!';

      await _notificationService.scheduleLocalNotification(
        id: 'checkin_reminder_${student.id}_${DateTime.now().day}',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.reminder,
        data: {
          'studentId': student.id,
          'action': 'check_in',
          'reminderType': 'checkin',
        },
      );

      logger.i('Lembrete de check-in enviado para ${student.fullName}');
    } catch (e) {
      logger.e('Erro ao enviar lembrete de check-in: $e');
    }
  }

  /// Notifica estudante sobre check-out pendente
  static Future<void> notifyCheckOutReminder({
    required StudentEntity student,
    required TimeLogEntity activeTimeLog,
  }) async {
    try {
      const title = 'Lembrete: Registrar Saída 🕕';
      final body = 'Você fez check-in às ${activeTimeLog.checkInTime}. '
          'Não se esqueça de registrar sua saída!';

      await _notificationService.scheduleLocalNotification(
        id: 'checkout_reminder_${student.id}_${activeTimeLog.id}',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.reminder,
        data: {
          'studentId': student.id,
          'timeLogId': activeTimeLog.id,
          'action': 'check_out',
          'reminderType': 'checkout',
        },
      );

      logger.i('Lembrete de check-out enviado para ${student.fullName}');
    } catch (e) {
      logger.e('Erro ao enviar lembrete de check-out: $e');
    }
  }

  /// Agenda lembrete de check-in para horário específico
  // Alterado para aceitar hour e minute diretamente, removendo student e reminderTime
  static Future<void> scheduleCheckInReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      const title = 'Hora de Trabalhar! 💼';
      const body = 'Lembre-se de registrar sua entrada no sistema.';

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // Se a hora agendada já passou para hoje, agende para amanhã
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationService.scheduleLocalNotification(
        id: 'scheduled_checkin_${scheduledDate.day}_${hour}_$minute', // ID mais específico
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        type: NotificationType.reminder,
        data: {
          // 'studentId': student.id, // Não temos um student aqui, se necessário, passe como parâmetro
          'action': 'check_in',
          'reminderType': 'scheduled_checkin',
        },
      );

      logger.i(
          'Lembrete de check-in agendado para ${AppDateUtils.formatTime(scheduledDate)}');
    } catch (e) {
      logger.e('Erro ao agendar lembrete de check-in: $e');
    }
  }

  /// Agenda lembrete de check-out para horário específico
  // Alterado para aceitar hour e minute diretamente, removendo student e reminderTime
  static Future<void> scheduleCheckOutReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      const title = 'Hora de Finalizar o Trabalho! 🏁';
      const body = 'Lembre-se de registrar sua saída no sistema.';

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // Se a hora agendada já passou para hoje, agende para amanhã
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationService.scheduleLocalNotification(
        id: 'scheduled_checkout_${scheduledDate.day}_${hour}_$minute', // ID mais específico
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        type: NotificationType.reminder,
        data: {
          // 'studentId': student.id, // Não temos um student aqui, se necessário, passe como parâmetro
          'action': 'check_out',
          'reminderType': 'scheduled_checkout',
        },
      );

      logger.i(
          'Lembrete de check-out agendado para ${AppDateUtils.formatTime(scheduledDate)}');
    } catch (e) {
      logger.e('Erro ao agendar lembrete de check-out: $e');
    }
  }

  /// Notifica sobre atualizações do sistema
  static Future<void> notifySystemUpdate({
    required String version,
    required String description,
    bool isRequired = false,
  }) async {
    try {
      final title = isRequired
          ? 'Atualização Obrigatória Disponível 🔄'
          : 'Nova Atualização Disponível 🆕';
      final body = 'Versão $version: $description';

      await _notificationService.scheduleLocalNotification(
        id: 'system_update_$version',
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        type: NotificationType.systemUpdate,
        data: {
          'version': version,
          'description': description,
          'isRequired': isRequired,
          'action': 'view_update',
        },
      );

      logger.i('Notificação de atualização do sistema enviada: $version');
    } catch (e) {
      logger.e('Erro ao enviar notificação de atualização: $e');
    }
  }

  /// Cancela lembretes específicos de um estudante
  static Future<void> cancelStudentReminders(String studentId) async {
    try {
      final today = DateTime.now().day;
      // IDs de notificação agora são mais específicos, ajuste aqui também
      await _notificationService
          .cancelScheduledNotification('checkin_reminder_${studentId}_$today');
      // Estes IDs precisam ser ajustados para corresponder aos gerados em scheduleCheckInReminder/scheduleCheckOutReminder
      // Exemplo: 'scheduled_checkin_${today}_${hour}_$minute'
      // Para cancelar de forma genérica, você precisaria de uma lista de IDs agendados ou uma forma de identificar todos os lembretes do estudante.
      // Por enquanto, vou remover as chamadas que não correspondem aos novos IDs gerados.
      // await _notificationService.cancelScheduledNotification('scheduled_checkin_${studentId}_$today');
      // await _notificationService.cancelScheduledNotification('scheduled_checkout_${studentId}_$today');

      logger.i('Lembretes cancelados para estudante: $studentId');
    } catch (e) {
      logger.e('Erro ao cancelar lembretes do estudante: $e');
    }
  }

  /// Cancela lembrete de check-out específico
  static Future<void> cancelCheckOutReminder(
      String studentId, String timeLogId) async {
    try {
      await _notificationService.cancelScheduledNotification(
          'checkout_reminder_${studentId}_$timeLogId');
      logger.i('Lembrete de check-out cancelado: $timeLogId');
    } catch (e) {
      logger.e('Erro ao cancelar lembrete de check-out: $e');
    }
  }

  /// Agenda lembretes automáticos para contratos expirando
  static Future<void> scheduleContractExpiryReminders({
    required ContractEntity contract,
    required StudentEntity student,
    required SupervisorEntity supervisor,
  }) async {
    try {
      final now = DateTime.now();
      final endDate = contract.endDate;

      // Agenda notificações para 30, 15, 7 e 1 dia antes do vencimento
      final reminderDays = [30, 15, 7, 1];

      for (final days in reminderDays) {
        final reminderDate = endDate.subtract(Duration(days: days));

        // Só agenda se a data for no futuro
        if (reminderDate.isAfter(now)) {
          await _notificationService.scheduleLocalNotification(
            id: 'contract_expiry_${contract.id}_${days}days',
            title: 'Contrato Expira em $days Dias ⚠️',
            body: 'O contrato de ${student.fullName} expira em $days dias.',
            scheduledDate: reminderDate,
            type: NotificationType.contractExpiring,
            data: {
              'contractId': contract.id,
              'studentId': student.id,
              'supervisorId': supervisor.id,
              'daysUntilExpiry': days,
              'action': 'view_contract',
            },
          );
        }
      }

      logger.i(
          'Lembretes de vencimento de contrato agendados para ${student.fullName}');
    } catch (e) {
      logger.e('Erro ao agendar lembretes de vencimento de contrato: $e');
    }
  }

  /// Obtém estatísticas de notificações
  static Map<String, int> getNotificationStats() {
    final history = _notificationService.notificationHistory;
    final stats = <String, int>{};

    for (final notification in history) {
      final type = notification.type.name;
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return stats;
  }

  /// Obtém notificações recentes (últimas 24 horas)
  static List<NotificationPayload> getRecentNotifications() {
    final history = _notificationService.notificationHistory;
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));

    return history
        .where((notification) => notification.timestamp.isAfter(yesterday))
        .toList();
  }

  /// Verifica se há notificações não lidas
  static bool hasUnreadNotifications() {
    // Implementar lógica de notificações não lidas se necessário
    return getRecentNotifications().isNotEmpty;
  }
}
