import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../../domain/entities/time_log_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/supervisor_entity.dart';
import '../../domain/entities/contract_entity.dart';
import '../utils/date_utils.dart';

/// Interface simples para TimeLog usado em notificações
abstract class TimeLogNotifiable {
  String get id;
  DateTime get date;
  Duration get duration;
  String get studentId;
}

/// Interface simples para Student usado em notificações
abstract class StudentNotifiable {
  String get id;
  String get name;
}

/// Interface simples para Supervisor usado em notificações
abstract class SupervisorNotifiable {
  String get id;
  String get name;
}

/// Interface simples para Contract usado em notificações
abstract class ContractNotifiable {
  String get id;
  DateTime get startDate;
  DateTime get endDate;
}

/// Helper para integrar notificações com eventos do domínio
class NotificationHelper {
  final NotificationService _notificationService;

  const NotificationHelper(this._notificationService);

  /// Notifica aprovação/rejeição de registro de horas
  Future<void> notifyTimeLogStatusChange({
    required TimeLogNotifiable timeLog,
    required bool approved,
    required StudentNotifiable student,
    SupervisorNotifiable? supervisor,
  }) async {
    final status = approved ? 'aprovado' : 'rejeitado';
    final date = AppDateUtils.formatDate(timeLog.date);
    final hours = AppDateUtils.formatDuration(timeLog.duration);

    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Registro de Horas $status',
      body: 'Seu registro de $hours do dia $date foi $status${supervisor != null ? ' por ${supervisor.name}' : ''}.',
      data: {
        'type': 'time_log_status',
        'timeLogId': timeLog.id,
        'approved': approved.toString(),
        'date': date,
        'hours': hours,
      },
    );
  }

  /// Notifica novo registro de horas para supervisor
  Future<void> notifyNewTimeLogToSupervisor({
    required TimeLogNotifiable timeLog,
    required StudentNotifiable student,
    required SupervisorNotifiable supervisor,
  }) async {
    final date = AppDateUtils.formatDate(timeLog.date);
    final hours = AppDateUtils.formatDuration(timeLog.duration);

    await _notificationService.sendNotificationToUser(
      userId: supervisor.id,
      title: 'Novo Registro de Horas',
      body: '${student.name} registrou $hours no dia $date. Aguarda aprovação.',
      data: {
        'type': 'new_time_log',
        'timeLogId': timeLog.id,
        'studentId': student.id,
        'studentName': student.name,
        'date': date,
        'hours': hours,
      },
    );
  }

  /// Notifica contrato expirando
  Future<void> notifyContractExpiring({
    required ContractNotifiable contract,
    required StudentNotifiable student,
    required int daysUntilExpiry,
  }) async {
    final expiryDate = AppDateUtils.formatDate(contract.endDate);
    
    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Contrato Expirando',
      body: 'Seu contrato expira em $daysUntilExpiry ${daysUntilExpiry == 1 ? 'dia' : 'dias'} ($expiryDate). Entre em contato com seu supervisor.',
      data: {
        'type': 'contract_expiring',
        'contractId': contract.id,
        'expiryDate': expiryDate,
        'daysUntilExpiry': daysUntilExpiry.toString(),
      },
    );
  }

  /// Notifica contrato expirado
  Future<void> notifyContractExpired({
    required ContractNotifiable contract,
    required StudentNotifiable student,
  }) async {
    final expiryDate = AppDateUtils.formatDate(contract.endDate);
    
    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Contrato Expirado',
      body: 'Seu contrato expirou em $expiryDate. Entre em contato com seu supervisor para renovação.',
      data: {
        'type': 'contract_expired',
        'contractId': contract.id,
        'expiryDate': expiryDate,
      },
    );
  }

  /// Notifica lembrete de check-in
  Future<void> notifyCheckInReminder({
    required StudentNotifiable student,
    required TimeOfDay reminderTime,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Lembrete de Check-in',
      body: 'Não se esqueça de fazer o check-in para registrar o início do seu trabalho.',
      data: {
        'type': 'checkin_reminder',
        'reminderTime': '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
      },
    );
  }

  /// Notifica lembrete de check-out
  Future<void> notifyCheckOutReminder({
    required StudentNotifiable student,
    required TimeOfDay reminderTime,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Lembrete de Check-out',
      body: 'Não se esqueça de fazer o check-out para registrar o fim do seu trabalho.',
      data: {
        'type': 'checkout_reminder',
        'reminderTime': '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
      },
    );
  }

  /// Notifica supervisor sobre múltiplos registros pendentes
  Future<void> notifyPendingTimeLogsToSupervisor({
    required SupervisorNotifiable supervisor,
    required int pendingCount,
    required List<StudentNotifiable> students,
  }) async {
    final studentNames = students.take(3).map((s) => s.name).join(', ');
    final moreStudents = students.length > 3 ? ' e mais ${students.length - 3}' : '';
    
    await _notificationService.sendNotificationToUser(
      userId: supervisor.id,
      title: 'Registros Pendentes',
      body: 'Você tem $pendingCount ${pendingCount == 1 ? 'registro pendente' : 'registros pendentes'} de aprovação de $studentNames$moreStudents.',
      data: {
        'type': 'pending_time_logs',
        'pendingCount': pendingCount.toString(),
        'studentIds': students.map((s) => s.id).join(','),
      },
    );
  }

  /// Notifica estudante sobre registro rejeitado com motivo
  Future<void> notifyTimeLogRejectedWithReason({
    required TimeLogNotifiable timeLog,
    required StudentNotifiable student,
    required String reason,
    SupervisorNotifiable? supervisor,
  }) async {
    final date = AppDateUtils.formatDate(timeLog.date);
    final hours = AppDateUtils.formatDuration(timeLog.duration);

    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Registro de Horas Rejeitado',
      body: 'Seu registro de $hours do dia $date foi rejeitado${supervisor != null ? ' por ${supervisor.name}' : ''}. Motivo: $reason',
      data: {
        'type': 'time_log_rejected',
        'timeLogId': timeLog.id,
        'date': date,
        'hours': hours,
        'reason': reason,
        'supervisorName': supervisor?.name ?? '',
      },
    );
  }

  /// Notifica estudante sobre novo contrato
  Future<void> notifyNewContract({
    required ContractNotifiable contract,
    required StudentNotifiable student,
    required SupervisorNotifiable supervisor,
  }) async {
    final startDate = AppDateUtils.formatDate(contract.startDate);
    final endDate = AppDateUtils.formatDate(contract.endDate);

    await _notificationService.sendNotificationToUser(
      userId: student.id,
      title: 'Novo Contrato',
      body: 'Você tem um novo contrato com ${supervisor.name} válido de $startDate até $endDate.',
      data: {
        'type': 'new_contract',
        'contractId': contract.id,
        'supervisorId': supervisor.id,
        'supervisorName': supervisor.name,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
  }

  /// Notifica supervisor sobre novo estudante
  Future<void> notifyNewStudentToSupervisor({
    required StudentNotifiable student,
    required SupervisorNotifiable supervisor,
    required ContractNotifiable contract,
  }) async {
    final startDate = AppDateUtils.formatDate(contract.startDate);

    await _notificationService.sendNotificationToUser(
      userId: supervisor.id,
      title: 'Novo Estudante',
      body: '${student.name} foi adicionado como seu estudante a partir de $startDate.',
      data: {
        'type': 'new_student',
        'studentId': student.id,
        'studentName': student.name,
        'contractId': contract.id,
        'startDate': startDate,
      },
    );
  }

  /// Notifica sobre backup de dados realizado
  Future<void> notifyDataBackupCompleted({
    required String userId,
    required DateTime backupDate,
    required int recordsCount,
  }) async {
    final date = AppDateUtils.formatDate(backupDate);

    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: 'Backup Concluído',
      body: 'Backup de $recordsCount registros realizado com sucesso em $date.',
      data: {
        'type': 'backup_completed',
        'backupDate': date,
        'recordsCount': recordsCount.toString(),
      },
    );
  }

  /// Notifica sobre sincronização de dados offline
  Future<void> notifyOfflineDataSynced({
    required String userId,
    required int syncedRecords,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: 'Dados Sincronizados',
      body: '$syncedRecords ${syncedRecords == 1 ? 'registro foi sincronizado' : 'registros foram sincronizados'} com sucesso.',
      data: {
        'type': 'offline_sync',
        'syncedRecords': syncedRecords.toString(),
      },
    );
  }
}
