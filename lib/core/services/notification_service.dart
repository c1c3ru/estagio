// lib/core/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/app_logger.dart';
// import '../constants/app_strings.dart';

enum NotificationType {
  checkInReminder,
  checkOutReminder,
  timeLogApproved,
  timeLogRejected,
  contractExpiring,
  general,
}

class NotificationData {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? payload;
  final DateTime? scheduledAt;
  final bool isRead;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    this.scheduledAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'payload': payload != null ? jsonEncode(payload) : null,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      payload: json['payload'] != null ? jsonDecode(json['payload']) : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationData> _notificationController =
      StreamController<NotificationData>.broadcast();
  final StreamController<List<NotificationData>> _notificationsListController =
      StreamController<List<NotificationData>>.broadcast();

  bool _isInitialized = false;
  String? _fcmToken;
  List<NotificationData> _notifications = [];

  /// Stream para notificações recebidas
  Stream<NotificationData> get notificationStream =>
      _notificationController.stream;

  /// Stream para lista de notificações
  Stream<List<NotificationData>> get notificationsListStream =>
      _notificationsListController.stream;

  /// Token FCM atual
  String? get fcmToken => _fcmToken;

  /// Status de inicialização
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de notificações
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Inicializa timezone
      tz.initializeTimeZones();

      // Configura notificações locais
      await _initializeLocalNotifications();

      // Configura Firebase Messaging
      await _initializeFirebaseMessaging();

      // Configura handlers
      _setupMessageHandlers();

      _isInitialized = true;
      AppLogger.info('NotificationService inicializado com sucesso');

      return true;
    } catch (e) {
      AppLogger.error('Erro ao inicializar NotificationService', error: e);
      return false;
    }
  }

  /// Inicializa notificações locais
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Inicializa Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Solicita permissões
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('Permissões de notificação concedidas');
    } else {
      AppLogger.warning('Permissões de notificação negadas');
    }

    // Obtém token FCM
    _fcmToken = await _firebaseMessaging.getToken();
    if (_fcmToken != null) {
      AppLogger.info('Token FCM obtido: ${_fcmToken!.substring(0, 20)}...');
    }

    // Escuta mudanças no token
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      AppLogger.info('Token FCM atualizado');
    });
  }

  /// Configura handlers de mensagens
  void _setupMessageHandlers() {
    // Mensagem recebida quando app está em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensagem recebida quando app está em background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Mensagem recebida quando app está fechado
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessageStatic);
  }

  /// Handler para mensagens em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Mensagem recebida em foreground: ${message.messageId}');

    final notificationData = _parseRemoteMessage(message);
    if (notificationData != null) {
      _addNotification(notificationData);
      _showLocalNotification(notificationData);
    }
  }

  /// Handler para mensagens em background
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info('Mensagem recebida em background: ${message.messageId}');

    final notificationData = _parseRemoteMessage(message);
    if (notificationData != null) {
      _addNotification(notificationData);
    }
  }

  /// Handler estático para mensagens em background
  static Future<void> _handleBackgroundMessageStatic(
      RemoteMessage message) async {
    AppLogger.info('Mensagem estática em background: ${message.messageId}');
    // Implementar lógica específica se necessário
  }

  /// Converte RemoteMessage para NotificationData
  NotificationData? _parseRemoteMessage(RemoteMessage message) {
    try {
      final data = message.data;
      final notification = message.notification;

      if (notification == null) return null;

      return NotificationData(
        id: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'Notificação',
        body: notification.body ?? '',
        type: _parseNotificationType(data['type']),
        payload: data.isNotEmpty ? data : null,
        scheduledAt: DateTime.now(),
      );
    } catch (e) {
      AppLogger.error('Erro ao parsear mensagem remota', error: e);
      return null;
    }
  }

  /// Converte string para NotificationType
  NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.general;

    try {
      return NotificationType.values.firstWhere((e) => e.name == type);
    } catch (e) {
      return NotificationType.general;
    }
  }

  /// Mostra notificação local
  Future<void> _showLocalNotification(NotificationData notification) async {
    const androidDetails = AndroidNotificationDetails(
      'estagio_channel',
      'Estágio Notifications',
      channelDescription: 'Notificações do sistema de estágio',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  /// Adiciona notificação à lista
  void _addNotification(NotificationData notification) {
    _notifications.insert(0, notification);
    _notificationsListController.add(_notifications);
    _notificationController.add(notification);
  }

  /// Handler para toque em notificação
  void _onNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        final notification = NotificationData.fromJson(data);

        // Marca como lida
        _markAsRead(notification.id);

        // Notifica sobre o toque
        _notificationController.add(notification);
      }
    } catch (e) {
      AppLogger.error('Erro ao processar toque em notificação', error: e);
    }
  }

  /// Agenda notificação local
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch;
      final notification = NotificationData(
        id: id.toString(),
        title: title,
        body: body,
        type: type,
        payload: payload,
        scheduledAt: scheduledDate,
      );

      const androidDetails = AndroidNotificationDetails(
        'estagio_scheduled',
        'Estágio Scheduled',
        channelDescription: 'Notificações agendadas do sistema de estágio',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails();
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode(notification.toJson()),
      );

      _addNotification(notification);

      if (kDebugMode) {
        AppLogger.debug(
            'Notificação agendada: $title em ${scheduledDate.toIso8601String()}');
      }
    } catch (e) {
      AppLogger.error('Erro ao agendar notificação', error: e);
    }
  }

  /// Agenda lembretes de check-in/check-out
  Future<void> scheduleCheckInReminder({
    required DateTime reminderTime,
    String? customMessage,
  }) async {
    await scheduleNotification(
      title: 'Lembrete de Check-in',
      body: customMessage ?? 'Não esqueça de fazer seu check-in!',
      scheduledDate: reminderTime,
      type: NotificationType.checkInReminder,
    );
  }

  Future<void> scheduleCheckOutReminder({
    required DateTime reminderTime,
    String? customMessage,
  }) async {
    await scheduleNotification(
      title: 'Lembrete de Check-out',
      body: customMessage ?? 'Não esqueça de fazer seu check-out!',
      scheduledDate: reminderTime,
      type: NotificationType.checkOutReminder,
    );
  }

  /// Envia notificação push para usuário específico
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? payload,
  }) async {
    try {
      // Aqui seria implementada a lógica para enviar via FCM
      // Por enquanto, apenas simula

      final notification = NotificationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: type,
        payload: payload,
        scheduledAt: DateTime.now(),
      );

      _addNotification(notification);

      if (kDebugMode) {
        AppLogger.debug('Notificação enviada para usuário $userId: $title');
      }

      return true;
    } catch (e) {
      AppLogger.error('Erro ao enviar notificação para usuário', error: e);
      return false;
    }
  }

  /// Marca notificação como lida
  void _markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationData(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        payload: _notifications[index].payload,
        scheduledAt: _notifications[index].scheduledAt,
        isRead: true,
      );
      _notificationsListController.add(_notifications);
    }
  }

  /// Marca notificação como lida (público)
  void markAsRead(String notificationId) {
    _markAsRead(notificationId);
  }

  /// Marca todas as notificações como lidas
  void markAllAsRead() {
    _notifications = _notifications
        .map((n) => NotificationData(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              payload: n.payload,
              scheduledAt: n.scheduledAt,
              isRead: true,
            ))
        .toList();
    _notificationsListController.add(_notifications);
  }

  /// Remove notificação
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsListController.add(_notifications);
  }

  /// Limpa todas as notificações
  void clearAllNotifications() {
    _notifications.clear();
    _notificationsListController.add(_notifications);
  }

  /// Obtém notificações não lidas
  List<NotificationData> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Obtém estatísticas de notificações
  Map<String, dynamic> getNotificationStats() {
    final total = _notifications.length;
    final unread = _notifications.where((n) => !n.isRead).length;
    final read = total - unread;

    return {
      'total': total,
      'unread': unread,
      'read': read,
      'fcmToken':
          _fcmToken != null ? '${_fcmToken!.substring(0, 20)}...' : null,
      'isInitialized': _isInitialized,
    };
  }

  /// Cancela notificação agendada
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);

    // Remove da lista local
    _notifications.removeWhere((n) => n.id == id.toString());
    _notificationsListController.add(_notifications);
  }

  /// Cancela todas as notificações agendadas
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    _notifications.clear();
    _notificationsListController.add(_notifications);
  }

  /// Verifica se notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Solicita permissões de notificação
  Future<bool> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Mostra notificação imediata
  Future<void> showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? payload,
  }) async {
    final notification = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      payload: payload,
      scheduledAt: DateTime.now(),
    );

    _addNotification(notification);
    await _showLocalNotification(notification);
  }

  /// Dispose do serviço
  void dispose() {
    _notificationController.close();
    _notificationsListController.close();
    _isInitialized = false;
  }
}

// ---- Compat: enums antigos mapeados para os novos ----
extension NotificationTypeCompat on NotificationType {
  static NotificationType fromLegacy(String legacy) {
    switch (legacy) {
      case 'timeLogApproval':
        return NotificationType.timeLogApproved;
      case 'timeLogRejection':
        return NotificationType.timeLogRejected;
      case 'newStudent':
        return NotificationType.general;
      case 'reminder':
        return NotificationType.general;
      case 'systemUpdate':
        return NotificationType.general;
      default:
        return NotificationType.general;
    }
  }
}

// ---- Compat: NotificationPayload legado ----
class NotificationPayload {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  NotificationPayload({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
}

extension NotificationServiceCompat on NotificationService {
  // Histórico legado
  List<NotificationPayload> get notificationHistory => _notifications
      .map((n) => NotificationPayload(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.payload,
            timestamp: n.scheduledAt ?? DateTime.now(),
          ))
      .toList();

  // API legada de agendamento
  Future<void> scheduleLocalNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  }) async {
    await scheduleNotification(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      type: NotificationType.general,
      payload: data,
    );
  }

  Future<void> cancelScheduledNotification(String id) async {
    final parsed = int.tryParse(id);
    if (parsed != null) {
      await cancelNotification(parsed);
    }
  }
}
