// lib/features/shared/pages/notification_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_strings.dart'; // Removed: Unused import

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key}); // Use super.key

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final ReminderService _reminderService = Modular.get<ReminderService>();
  final NotificationService _notificationService =
      Modular.get<NotificationService>();
  // No longer instantiating FeedbackService, as its methods are static.
  // final FeedbackService _feedbackService = FeedbackService();

  bool _dailyRemindersEnabled = true;
  bool _contractRemindersEnabled = true;
  bool _notificationsEnabled = true;

  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);

      // Carregar configurações de lembretes
      final reminderSettings = await _reminderService.getReminderSettings();

      // Verificar se notificações estão habilitadas
      final notificationStatus =
          await _notificationService.areNotificationsEnabled();

      if (!mounted) {
        return; // Check if widget is still mounted after async operation
      }

      setState(() {
        _dailyRemindersEnabled =
            reminderSettings['dailyRemindersEnabled'] ?? true;
        _contractRemindersEnabled =
            reminderSettings['contractRemindersEnabled'] ?? true;
        _notificationsEnabled = notificationStatus;

        _checkInTime = TimeOfDay(
          hour: reminderSettings['checkInHour'] ?? 8,
          minute: reminderSettings['checkInMinute'] ?? 0,
        );

        _checkOutTime = TimeOfDay(
          hour: reminderSettings['checkOutHour'] ?? 17,
          minute: reminderSettings['checkOutMinute'] ?? 0,
        );

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return; // Check if widget is still mounted
      }
      setState(() => _isLoading = false);
      // Access static methods directly from FeedbackService class with named parameters
      FeedbackService.showErrorDialog(
        context,
        title: 'Erro ao carregar configurações',
        message: 'Não foi possível carregar as configurações de notificação: $e',
      );
    }
  }

  Future<void> _requestNotificationPermission() async {
    await FeedbackService.executeWithFeedback(
      context,
      loadingMessage: 'Solicitando permissão...',
      operation: () async {
        final granted = await _notificationService.requestPermission();
        if (!mounted) return;
        setState(() {
          _notificationsEnabled = granted;
        });
      },
      onSuccess: () {
        if (!mounted) return;
        FeedbackService.showSuccess(context, 'Permissão atualizada!');
      },
      onError: () {
        if (!mounted) return;
        FeedbackService.showError(context, 'Falha ao solicitar permissão.');
      },
    );
  }

  Future<void> _toggleDailyReminders(bool enabled) async {
    await FeedbackService.executeWithFeedback(
      context,
      loadingMessage: 'Salvando preferência...',
      operation: () => _reminderService.setDailyRemindersEnabled(enabled),
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _dailyRemindersEnabled = enabled;
        });
        FeedbackService.showSuccess(
          context,
          'Lembretes diários ${enabled ? 'ativados' : 'desativados'}.',
        );
      },
      onError: () {
        if (!mounted) return;
        FeedbackService.showError(context, 'Erro ao atualizar lembretes.');
      },
    );
  }

  Future<void> _toggleContractReminders(bool enabled) async {
    await FeedbackService.executeWithFeedback(
      context,
      loadingMessage: 'Salvando preferência...',
      operation: () => _reminderService.setContractRemindersEnabled(enabled),
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _contractRemindersEnabled = enabled;
        });
        FeedbackService.showSuccess(
          context,
          'Alertas de contrato ${enabled ? 'ativados' : 'desativados'}.',
        );
      },
      onError: () {
        if (!mounted) return;
        FeedbackService.showError(context, 'Erro ao atualizar alertas.');
      },
    );
  }

  Future<void> _selectTime(bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      await FeedbackService.executeWithFeedback(
        context,
        loadingMessage: 'Salvando horário...',
        operation: () => _reminderService.setReminderTimes(
          checkInHour: isCheckIn ? picked.hour : _checkInTime.hour,
          checkInMinute: isCheckIn ? picked.minute : _checkInTime.minute,
          checkOutHour: !isCheckIn ? picked.hour : _checkOutTime.hour,
          checkOutMinute: !isCheckIn ? picked.minute : _checkOutTime.minute,
        ),
        onSuccess: () {
          if (!mounted) return;
          setState(() {
            if (isCheckIn) {
              _checkInTime = picked;
            } else {
              _checkOutTime = picked;
            }
          });
          FeedbackService.showSuccess(context, 'Horário atualizado!');
        },
        onError: () {
          if (!mounted) return;
          FeedbackService.showError(context, 'Erro ao salvar horário.');
        },
      );
    }
  }

  Future<void> _testNotification() async {
    await FeedbackService.executeWithFeedback(
      context,
      loadingMessage: 'Enviando notificação de teste...',
      operation: () => _notificationService.showNotification(
        title: 'Notificação de Teste',
        body: 'Esta é uma notificação de teste do sistema.',
      ),
      onSuccess: () {
        if (!mounted) return;
        FeedbackService.showSuccess(context, 'Notificação de teste enviada!');
      },
      onError: () {
        if (!mounted) return;
        FeedbackService.showError(context, 'Falha ao enviar notificação.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificação'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Permissões'),
                  _buildNotificationPermissionCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Lembretes Diários'),
                  _buildDailyRemindersCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Alertas de Contrato'),
                  _buildContractAlertsCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Teste'),
                  _buildTestCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildNotificationPermissionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _notificationsEnabled
                      ? Icons.notifications
                      : Icons.notifications_off,
                  color: _notificationsEnabled ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  _notificationsEnabled
                      ? 'Notificações Habilitadas'
                      : 'Notificações Desabilitadas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _notificationsEnabled
                  ? 'Você receberá notificações do aplicativo.'
                  : 'Para receber notificações, é necessário conceder permissão.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!_notificationsEnabled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _requestNotificationPermission,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Solicitar Permissão'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRemindersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Changed to Column to hold multiple widgets
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Lembretes de Check-in/out'),
              subtitle:
                  const Text('Receba lembretes para registrar entrada e saída'),
              value: _dailyRemindersEnabled,
              onChanged: _notificationsEnabled ? _toggleDailyReminders : null,
              activeColor: AppColors.primary,
            ),
            if (_dailyRemindersEnabled) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Horário do Check-in'),
                subtitle: Text(_checkInTime.format(context)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectTime(true),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Horário do Check-out'),
                subtitle: Text(_checkOutTime.format(context)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectTime(false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContractAlertsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SwitchListTile(
          title: const Text('Alertas de Contrato'),
          subtitle: const Text('Receba alertas sobre contratos expirando'),
          value: _contractRemindersEnabled,
          onChanged: _notificationsEnabled ? _toggleContractReminders : null,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teste de Notificação',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Envie uma notificação de teste para verificar se está funcionando.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _notificationsEnabled ? _testNotification : null,
                icon: const Icon(Icons.send),
                label: const Text('Enviar Teste'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
