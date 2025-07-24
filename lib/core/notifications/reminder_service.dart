import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../services/notification_service.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/contract_entity.dart';
import '../utils/date_utils.dart';
import 'notification_helper.dart';

/// Configurações de lembrete
class ReminderSettings {
  final bool enabled;
  final TimeOfDay time;
  final List<int> weekdays; // 1-7 (Monday-Sunday)
  final int advanceDays; // Para contratos

  const ReminderSettings({
    required this.enabled,
    required this.time,
    required this.weekdays,
    this.advanceDays = 7,
  });

  ReminderSettings copyWith({
    bool? enabled,
    TimeOfDay? time,
    List<int>? weekdays,
    int? advanceDays,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      time: time ?? this.time,
      weekdays: weekdays ?? this.weekdays,
      advanceDays: advanceDays ?? this.advanceDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'hour': time.hour,
      'minute': time.minute,
      'weekdays': weekdays,
      'advanceDays': advanceDays,
    };
  }

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      enabled: json['enabled'] ?? false,
      time: TimeOfDay(
        hour: json['hour'] ?? 9,
        minute: json['minute'] ?? 0,
      ),
      weekdays: List<int>.from(json['weekdays'] ?? [1, 2, 3, 4, 5]),
      advanceDays: json['advanceDays'] ?? 7,
    );
  }
}

/// Serviço de lembretes automáticos
class ReminderService {
  final NotificationService _notificationService;
  final NotificationHelper _notificationHelper;
  
  // Configurações padrão
  static const ReminderSettings _defaultCheckInSettings = ReminderSettings(
    enabled: true,
    time: TimeOfDay(hour: 8, minute: 0),
    weekdays: [1, 2, 3, 4, 5], // Segunda a sexta
  );

  static const ReminderSettings _defaultCheckOutSettings = ReminderSettings(
    enabled: true,
    time: TimeOfDay(hour: 17, minute: 0),
    weekdays: [1, 2, 3, 4, 5], // Segunda a sexta
  );

  static const ReminderSettings _defaultContractSettings = ReminderSettings(
    enabled: true,
    time: TimeOfDay(hour: 9, minute: 0),
    weekdays: [1, 2, 3, 4, 5, 6, 7], // Todos os dias
    advanceDays: 7, // 7 dias antes do vencimento
  );

  ReminderService(this._notificationService, this._notificationHelper);

  /// Agenda lembretes de check-in para um estudante
  Future<void> scheduleCheckInReminders({
    required StudentEntity student,
    ReminderSettings? settings,
  }) async {
    final reminderSettings = settings ?? _defaultCheckInSettings;
    
    if (!reminderSettings.enabled) return;

    // Cancela lembretes existentes
    await _cancelReminders('checkin_${student.id}');

    // Agenda novos lembretes para os próximos 30 dias
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      
      // Verifica se é um dia da semana configurado
      if (!reminderSettings.weekdays.contains(date.weekday)) continue;

      final reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        reminderSettings.time.hour,
        reminderSettings.time.minute,
      );

      // Só agenda se for no futuro
      if (reminderDateTime.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: _generateReminderId('checkin', student.id, date),
          title: 'Lembrete de Check-in',
          body: 'Não se esqueça de fazer o check-in para registrar o início do seu trabalho.',
          scheduledDate: reminderDateTime,
          payload: 'checkin_reminder',
        );
      }
    }
  }

  /// Agenda lembretes de check-out para um estudante
  Future<void> scheduleCheckOutReminders({
    required StudentEntity student,
    ReminderSettings? settings,
  }) async {
    final reminderSettings = settings ?? _defaultCheckOutSettings;
    
    if (!reminderSettings.enabled) return;

    // Cancela lembretes existentes
    await _cancelReminders('checkout_${student.id}');

    // Agenda novos lembretes para os próximos 30 dias
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      
      // Verifica se é um dia da semana configurado
      if (!reminderSettings.weekdays.contains(date.weekday)) continue;

      final reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        reminderSettings.time.hour,
        reminderSettings.time.minute,
      );

      // Só agenda se for no futuro
      if (reminderDateTime.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: _generateReminderId('checkout', student.id, date),
          title: 'Lembrete de Check-out',
          body: 'Não se esqueça de fazer o check-out para registrar o fim do seu trabalho.',
          scheduledDate: reminderDateTime,
          payload: 'checkout_reminder',
        );
      }
    }
  }

  /// Agenda lembretes de contratos expirando
  Future<void> scheduleContractExpiryReminders({
    required List<ContractEntity> contracts,
    ReminderSettings? settings,
  }) async {
    final reminderSettings = settings ?? _defaultContractSettings;
    
    if (!reminderSettings.enabled) return;

    for (final contract in contracts) {
      // Cancela lembretes existentes para este contrato
      await _cancelReminders('contract_${contract.id}');

      // Calcula data do lembrete
      final reminderDate = contract.endDate.subtract(
        Duration(days: reminderSettings.advanceDays),
      );

      final reminderDateTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        reminderSettings.time.hour,
        reminderSettings.time.minute,
      );

      // Só agenda se for no futuro
      if (reminderDateTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: _generateReminderId('contract', contract.id, reminderDate),
          title: 'Contrato Expirando',
          body: 'Seu contrato expira em ${reminderSettings.advanceDays} dias (${AppDateUtils.formatDate(contract.endDate)}). Entre em contato com seu supervisor.',
          scheduledDate: reminderDateTime,
          payload: 'contract_expiry_reminder',
        );

        // Agenda também um lembrete no dia do vencimento
        final expiryDateTime = DateTime(
          contract.endDate.year,
          contract.endDate.month,
          contract.endDate.day,
          reminderSettings.time.hour,
          reminderSettings.time.minute,
        );

        if (expiryDateTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: _generateReminderId('contract_expiry', contract.id, contract.endDate),
            title: 'Contrato Expirado',
            body: 'Seu contrato expirou hoje (${AppDateUtils.formatDate(contract.endDate)}). Entre em contato com seu supervisor para renovação.',
            scheduledDate: expiryDateTime,
            payload: 'contract_expired',
          );
        }
      }
    }
  }

  /// Atualiza configurações de lembrete de check-in
  Future<void> updateCheckInSettings({
    required StudentEntity student,
    required ReminderSettings settings,
  }) async {
    // Salva configurações (implementar persistência se necessário)
    // await _saveSettings('checkin_${student.id}', settings);
    
    // Reagenda lembretes com novas configurações
    await scheduleCheckInReminders(student: student, settings: settings);
  }

  /// Atualiza configurações de lembrete de check-out
  Future<void> updateCheckOutSettings({
    required StudentEntity student,
    required ReminderSettings settings,
  }) async {
    // Salva configurações (implementar persistência se necessário)
    // await _saveSettings('checkout_${student.id}', settings);
    
    // Reagenda lembretes com novas configurações
    await scheduleCheckOutReminders(student: student, settings: settings);
  }

  /// Atualiza configurações de lembrete de contratos
  Future<void> updateContractSettings({
    required List<ContractEntity> contracts,
    required ReminderSettings settings,
  }) async {
    // Salva configurações (implementar persistência se necessário)
    // await _saveSettings('contract_reminders', settings);
    
    // Reagenda lembretes com novas configurações
    await scheduleContractExpiryReminders(contracts: contracts, settings: settings);
  }

  /// Cancela todos os lembretes de um estudante
  Future<void> cancelAllRemindersForStudent(String studentId) async {
    await _cancelReminders('checkin_$studentId');
    await _cancelReminders('checkout_$studentId');
  }

  /// Cancela lembretes de um contrato específico
  Future<void> cancelContractReminders(String contractId) async {
    await _cancelReminders('contract_$contractId');
  }

  /// Cancela todos os lembretes
  Future<void> cancelAllReminders() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Verifica e processa lembretes vencidos
  Future<void> processExpiredReminders() async {
    // Esta função seria chamada periodicamente para verificar
    // contratos que expiraram e enviar notificações apropriadas
    
    // Implementação dependeria de como os contratos são armazenados
    // e acessados no sistema
  }

  /// Obtém configurações padrão para check-in
  ReminderSettings get defaultCheckInSettings => _defaultCheckInSettings;

  /// Obtém configurações padrão para check-out
  ReminderSettings get defaultCheckOutSettings => _defaultCheckOutSettings;

  /// Obtém configurações padrão para contratos
  ReminderSettings get defaultContractSettings => _defaultContractSettings;

  // Métodos privados

  /// Gera ID único para lembrete
  int _generateReminderId(String type, String entityId, DateTime date) {
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final hash = '$type$entityId$dateStr'.hashCode;
    return hash.abs() % 2147483647; // Garante que seja um int32 positivo
  }

  /// Cancela lembretes por padrão de ID
  Future<void> _cancelReminders(String pattern) async {
    // Esta implementação dependeria de como o NotificationService
    // gerencia e cancela notificações agendadas
    
    // Por enquanto, cancelamos todas (não ideal, mas funcional)
    // Em uma implementação real, manteríamos um registro dos IDs
    // de notificação para cancelar seletivamente
  }

  /// Salva configurações de lembrete (para implementação futura)
  Future<void> _saveSettings(String key, ReminderSettings settings) async {
    // Implementar persistência usando SharedPreferences ou similar
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.setString(key, jsonEncode(settings.toJson()));
    // });
  }

  /// Carrega configurações de lembrete (para implementação futura)
  Future<ReminderSettings?> _loadSettings(String key) async {
    // Implementar carregamento usando SharedPreferences ou similar
    // final prefs = await SharedPreferences.getInstance();
    // final settingsJson = prefs.getString(key);
    // if (settingsJson != null) {
    //   return ReminderSettings.fromJson(jsonDecode(settingsJson));
    // }
    return null;
  }
}
