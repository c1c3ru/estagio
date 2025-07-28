// lib/core/services/reminder_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'notification_helper.dart'; // Mantém a importação para usar os métodos estáticos

/// Serviço responsável por gerenciar lembretes automáticos
/// para estudantes (check-in, check-out, contratos expirando, etc.)
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final NotificationService _notificationService = NotificationService();
  // Removendo a instância de NotificationHelper, pois os métodos serão chamados estaticamente.
  // final NotificationHelper _notificationHelper = NotificationHelper();

  Timer? _dailyReminderTimer;
  Timer? _contractExpirationTimer;

  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _checkInTimeKey = 'check_in_reminder_time';
  static const String _checkOutTimeKey = 'check_out_reminder_time';
  static const String _contractReminderKey = 'contract_reminder_enabled';

  /// Inicializa o serviço de lembretes
  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print('🔔 ReminderService: Inicializando serviço de lembretes...');
      }

      // Verificar se os lembretes estão habilitados
      final prefs = await SharedPreferences.getInstance();
      final reminderEnabled = prefs.getBool(_reminderEnabledKey) ?? true;
      final contractReminderEnabled =
          prefs.getBool(_contractReminderKey) ?? true;

      if (reminderEnabled) {
        await _setupDailyReminders();
      }

      if (contractReminderEnabled) {
        await _setupContractExpirationReminders();
      }

      if (kDebugMode) {
        print(
            '✅ ReminderService: Serviço de lembretes inicializado com sucesso');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ ReminderService: Erro ao inicializar serviço de lembretes: $e');
      }
      return false;
    }
  }

  /// Configura lembretes diários de check-in e check-out
  Future<void> _setupDailyReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Horários padrão: check-in às 8h, check-out às 17h
      final checkInHour = prefs.getInt('${_checkInTimeKey}_hour') ?? 8;
      final checkInMinute = prefs.getInt('${_checkInTimeKey}_minute') ?? 0;
      final checkOutHour = prefs.getInt('${_checkOutTimeKey}_hour') ?? 17;
      final checkOutMinute = prefs.getInt('${_checkOutTimeKey}_minute') ?? 0;

      // Agendar lembrete de check-in usando a classe estática NotificationHelper
      await NotificationHelper.scheduleCheckInReminder(
        hour: checkInHour,
        minute: checkInMinute,
      );

      // Agendar lembrete de check-out usando a classe estática NotificationHelper
      await NotificationHelper.scheduleCheckOutReminder(
        hour: checkOutHour,
        minute: checkOutMinute,
      );

      if (kDebugMode) {
        print('✅ ReminderService: Lembretes diários configurados');
        print(
            '   - Check-in: ${checkInHour.toString().padLeft(2, '0')}:${checkInMinute.toString().padLeft(2, '0')}');
        print(
            '   - Check-out: ${checkOutHour.toString().padLeft(2, '0')}:${checkOutMinute.toString().padLeft(2, '0')}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao configurar lembretes diários: $e');
      }
    }
  }

  /// Configura lembretes de contratos expirando
  Future<void> _setupContractExpirationReminders() async {
    try {
      // Timer para verificar contratos expirando a cada 24 horas
      _contractExpirationTimer = Timer.periodic(
        const Duration(hours: 24),
        (timer) => _checkExpiringContracts(),
      );

      // Verificar imediatamente
      await _checkExpiringContracts();

      if (kDebugMode) {
        print(
            '✅ ReminderService: Verificação de contratos expirando configurada');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ ReminderService: Erro ao configurar lembretes de contrato: $e');
      }
    }
  }

  /// Verifica contratos que estão expirando e envia notificações
  Future<void> _checkExpiringContracts() async {
    try {
      // Aqui você integraria com o repositório de contratos
      // para buscar contratos expirando nos próximos 30, 15, 7 e 1 dias

      if (kDebugMode) {
        print('🔍 ReminderService: Verificando contratos expirando...');
      }

      // Exemplo de como seria a integração:
      // final contracts = await contractRepository.getExpiringContracts();
      // for (final contract in contracts) {
      //   await NotificationHelper.notifyContractExpiring(...); // Chamada estática
      // }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao verificar contratos expirando: $e');
      }
    }
  }

  /// Habilita ou desabilita lembretes diários
  Future<void> setDailyRemindersEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, enabled);

      if (enabled) {
        await _setupDailyReminders();
      } else {
        await _cancelDailyReminders();
      }

      if (kDebugMode) {
        print(
            '✅ ReminderService: Lembretes diários ${enabled ? 'habilitados' : 'desabilitados'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao alterar status dos lembretes: $e');
      }
    }
  }

  /// Configura horários personalizados para lembretes
  Future<void> setReminderTimes({
    required int checkInHour,
    required int checkInMinute,
    required int checkOutHour,
    required int checkOutMinute,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('${_checkInTimeKey}_hour', checkInHour);
      await prefs.setInt('${_checkInTimeKey}_minute', checkInMinute);
      await prefs.setInt('${_checkOutTimeKey}_hour', checkOutHour);
      await prefs.setInt('${_checkOutTimeKey}_minute', checkOutMinute);

      // Reconfigurar lembretes com novos horários
      final reminderEnabled = prefs.getBool(_reminderEnabledKey) ?? true;
      if (reminderEnabled) {
        await _setupDailyReminders();
      }

      if (kDebugMode) {
        print('✅ ReminderService: Horários de lembrete atualizados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao atualizar horários: $e');
      }
    }
  }

  /// Cancela todos os lembretes diários
  Future<void> _cancelDailyReminders() async {
    try {
      // Convertendo IDs para String
      await _notificationService
          .cancelNotification('1001'); // Check-in reminder ID
      await _notificationService
          .cancelNotification('1002'); // Check-out reminder ID

      if (kDebugMode) {
        print('✅ ReminderService: Lembretes diários cancelados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao cancelar lembretes: $e');
      }
    }
  }

  /// Habilita ou desabilita lembretes de contrato
  Future<void> setContractRemindersEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_contractReminderKey, enabled);

      if (enabled) {
        await _setupContractExpirationReminders();
      } else {
        _contractExpirationTimer?.cancel();
      }

      if (kDebugMode) {
        print(
            '✅ ReminderService: Lembretes de contrato ${enabled ? 'habilitados' : 'desabilitados'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao alterar lembretes de contrato: $e');
      }
    }
  }

  /// Agenda um lembrete personalizado
  Future<void> scheduleCustomReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await _notificationService.scheduleNotification(
        id: (DateTime.now().millisecondsSinceEpoch % 100000)
            .toString(), // ID único como String
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        data: payload != null
            ? {'payload': payload}
            : null, // Passando payload como 'data'
      );

      if (kDebugMode) {
        print(
            '✅ ReminderService: Lembrete personalizado agendado para $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao agendar lembrete personalizado: $e');
      }
    }
  }

  /// Obtém configurações atuais dos lembretes
  Future<Map<String, dynamic>> getReminderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'dailyRemindersEnabled': prefs.getBool(_reminderEnabledKey) ?? true,
        'contractRemindersEnabled': prefs.getBool(_contractReminderKey) ?? true,
        'checkInHour': prefs.getInt('${_checkInTimeKey}_hour') ?? 8,
        'checkInMinute': prefs.getInt('${_checkInTimeKey}_minute') ?? 0,
        'checkOutHour': prefs.getInt('${_checkOutTimeKey}_hour') ?? 17,
        'checkOutMinute': prefs.getInt('${_checkOutTimeKey}_minute') ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao obter configurações: $e');
      }
      return {};
    }
  }

  /// Limpa todos os lembretes e configurações
  Future<void> clearAllReminders() async {
    try {
      _dailyReminderTimer?.cancel();
      _contractExpirationTimer?.cancel();

      await _cancelDailyReminders();
      await _notificationService.cancelAllNotifications();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reminderEnabledKey);
      await prefs.remove(_contractReminderKey);
      await prefs.remove('${_checkInTimeKey}_hour');
      await prefs.remove('${_checkInTimeKey}_minute');
      await prefs.remove('${_checkOutTimeKey}_hour');
      await prefs.remove('${_checkOutTimeKey}_minute');

      if (kDebugMode) {
        print(
            '✅ ReminderService: Todos os lembretes e configurações foram limpos');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReminderService: Erro ao limpar lembretes: $e');
      }
    }
  }

  /// Libera recursos do serviço
  void dispose() {
    _dailyReminderTimer?.cancel();
    _contractExpirationTimer?.cancel();

    if (kDebugMode) {
      print('🔔 ReminderService: Serviço de lembretes finalizado');
    }
  }
}
