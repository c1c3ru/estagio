// lib/core/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// Import condicional para firebase_core
// ignore: uri_does_not_exist
// Mantém para kDebugMode
// import 'package:flutter/material.dart'; // Removido: Unused import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart'
    as tz_data; // Importa para inicialização

// import '../constants/app_strings.dart'; // Removido: Unused import
import '../utils/logger_utils.dart';

enum NotificationType {
  timeLogApproval,
  timeLogRejection,
  contractExpiring,
  newStudent,
  systemUpdate,
  reminder,
}

class NotificationPayload {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const NotificationPayload({
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

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      title: json['title'],
      body: json['body'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class NotificationService {
  static NotificationService? _testInstance;
  static NotificationService get instance =>
      _testInstance ??= NotificationService._internal();
  static set instance(NotificationService value) => _testInstance = value;
  factory NotificationService() => instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Inicializa o Firebase de forma segura (apenas se não for web)
  Future<void> safeInitializeFirebase() async {
    if (kIsWeb) return;
    try {
      // Só inicializa se firebase_core estiver disponível
      // e se não estiver inicializado ainda
      // ignore: undefined_prefixed_name
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      // Em ambiente de teste ou se firebase_core não estiver disponível, ignore
      if (kDebugMode) print('⚠️ safeInitializeFirebase: $e');
    }
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controllers para notificações
  final StreamController<NotificationPayload> _notificationStreamController =
      StreamController<NotificationPayload>.broadcast();
  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  // Getters para streams
  Stream<NotificationPayload> get notificationStream =>
      _notificationStreamController.stream;
  Stream<String> get tokenStream => _tokenStreamController.stream;

  bool _isInitialized = false;
  String? _fcmToken;
  List<NotificationPayload> _notificationHistory = [];

  // Getters
  String? get fcmToken => _fcmToken;
  List<NotificationPayload> get notificationHistory => _notificationHistory;
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de notificações
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Inicializa timezones para zonedSchedule
      tz_data.initializeTimeZones(); // Adicionado para resolver TZDateTime

      // Solicita permissões
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        logger.w('Permissões de notificação negadas');
        return false;
      }

      // Inicializa notificações locais
      await _initializeLocalNotifications();

      // Inicializa Firebase (caso necessário)
      await safeInitializeFirebase();
      // Inicializa Firebase Messaging
      await _initializeFirebaseMessaging();

      // Carrega histórico de notificações
      await _loadNotificationHistory();

      _isInitialized = true;
      logger.i('NotificationService inicializado com sucesso');
      return true;
    } catch (e, stackTrace) {
      logger.e('Erro ao inicializar NotificationService', e, stackTrace);
      return false;
    }
  }

  /// Solicita permissões necessárias
  Future<bool> _requestPermissions() async {
    try {
      // Permissão para notificações
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.w('Permissão de notificação negada pelo usuário');
        return false;
      }

      // Permissões adicionais para Android
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      logger.e('Erro ao solicitar permissões de notificação: $e');
      return false;
    }
  }

  /// Inicializa notificações locais
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Cria canal de notificação para Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Cria canais de notificação para Android
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel highImportanceChannel =
        AndroidNotificationChannel(
      'high_importance_channel',
      'Notificações Importantes',
      description: 'Canal para notificações importantes do sistema',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
      'default_channel',
      'Notificações Gerais',
      description: 'Canal para notificações gerais',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);
  }

  /// Inicializa Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Obtém token FCM
    _fcmToken = await _firebaseMessaging.getToken();
    logger.i('FCM Token: $_fcmToken');

    if (_fcmToken != null) {
      _tokenStreamController.add(_fcmToken!);
      await _saveFcmToken(_fcmToken!);
    } else {
      // Tenta carregar o token salvo se não conseguiu um novo
      _fcmToken = await _loadFcmToken(); // Chamada adicionada
      if (_fcmToken != null) {
        _tokenStreamController.add(_fcmToken!);
      }
    }

    // Listener para mudanças no token
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _tokenStreamController.add(token);
      _saveFcmToken(token);
      logger.i('FCM Token atualizado: $token');
    });

    // Handlers para diferentes estados da app
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Verifica se app foi aberto por notificação
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// Manipula notificações quando app está em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    logger.i('Notificação recebida em foreground: ${message.messageId}');

    final payload = _createPayloadFromRemoteMessage(message);
    await _addToHistory(payload);
    _notificationStreamController.add(payload);

    // Mostra notificação local
    await _showLocalNotification(payload);
  }

  /// Manipula notificações quando app está em background
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    logger.i('Notificação aberta do background: ${message.messageId}');

    final payload = _createPayloadFromRemoteMessage(message);
    await _addToHistory(payload);
    _notificationStreamController.add(payload);
  }

  /// Cria payload a partir de RemoteMessage
  NotificationPayload _createPayloadFromRemoteMessage(RemoteMessage message) {
    final typeString = message.data['type'] ?? 'systemUpdate';
    final type = NotificationType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => NotificationType.systemUpdate,
    );

    return NotificationPayload(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: message.notification?.title ?? 'Notificação',
      body: message.notification?.body ?? '',
      data: message.data,
      timestamp: DateTime.now(),
    );
  }

  /// Mostra notificação local
  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final channelId = _getChannelIdForType(payload.type);
    final importance = _getImportanceForType(payload.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(payload.type),
      channelDescription: _getChannelDescriptionForType(payload.type),
      importance: importance,
      priority: Priority.high,
      showWhen: true,
      when: payload.timestamp.millisecondsSinceEpoch,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      payload.id.hashCode,
      payload.title,
      payload.body,
      notificationDetails,
      payload: jsonEncode(payload.toJson()),
    );
  }

  /// Manipula tap em notificação local
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final payloadData = jsonDecode(response.payload!);
        final payload = NotificationPayload.fromJson(payloadData);
        _notificationStreamController.add(payload);
        logger.i('Notificação local tocada: ${payload.id}');
      } catch (e) {
        logger.e('Erro ao processar payload da notificação: $e');
      }
    }
  }

  /// Envia notificação local programada
  Future<void> scheduleLocalNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationType type = NotificationType.reminder,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      logger.w('NotificationService não inicializado');
      return;
    }

    final payload = NotificationPayload(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      timestamp: scheduledDate,
    );

    final channelId = _getChannelIdForType(type);
    final importance = _getImportanceForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(type),
      channelDescription: _getChannelDescriptionForType(type),
      importance: importance,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(payload.toJson()),
    );

    logger.i('Notificação local agendada para: $scheduledDate');
  }

  Future<void> cancelScheduledNotification(String id) async {
    await _localNotifications.cancel(id.hashCode);
    logger.i('Notificação cancelada: $id');
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    logger.i('Todas as notificações canceladas');
  }

  /// Obtém notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Salva token FCM
  Future<void> _saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      logger.e('Erro ao salvar FCM token: $e');
    }
  }

  /// Carrega token FCM salvo
  Future<String?> _loadFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      logger.e('Erro ao carregar FCM token: $e');
      return null;
    }
  }

  /// Adiciona notificação ao histórico
  Future<void> _addToHistory(NotificationPayload payload) async {
    _notificationHistory.insert(0, payload);

    // Mantém apenas as últimas 100 notificações
    if (_notificationHistory.length > 100) {
      _notificationHistory = _notificationHistory.take(100).toList();
    }

    await _saveNotificationHistory();
  }

  /// Salva histórico de notificações
  Future<void> _saveNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _notificationHistory
          .map((notification) => notification.toJson())
          .toList();
      await prefs.setString('notification_history', jsonEncode(historyJson));
    } catch (e) {
      logger.e('Erro ao salvar histórico de notificações: $e');
    }
  }

  /// Carrega histórico de notificações
  Future<void> _loadNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('notification_history');

      if (historyString != null) {
        final historyJson = jsonDecode(historyString) as List;
        _notificationHistory = historyJson
            .map((json) => NotificationPayload.fromJson(json))
            .toList();
      }
    } catch (e) {
      logger.e('Erro ao carregar histórico de notificações: $e');
      _notificationHistory = [];
    }
  }

  /// Limpa histórico de notificações
  Future<void> clearNotificationHistory() async {
    _notificationHistory.clear();
    await _saveNotificationHistory();
    logger.i('Histórico de notificações limpo');
  }

  /// Marca notificação como lida
  Future<void> markAsRead(String notificationId) async {
    // Implementar lógica para marcar como lida se necessário
    logger.i('Notificação marcada como lida: $notificationId');
  }

  /// Obtém configurações de canal baseado no tipo
  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.timeLogApproval:
      case NotificationType.timeLogRejection:
      case NotificationType.contractExpiring:
        return 'high_importance_channel';
      default:
        return 'default_channel';
    }
  }

  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.timeLogApproval:
      case NotificationType.timeLogRejection:
      case NotificationType.contractExpiring:
        return 'Notificações Importantes';
      default:
        return 'Notificações Gerais';
    }
  }

  String _getChannelDescriptionForType(NotificationType type) {
    switch (type) {
      case NotificationType.timeLogApproval:
        return 'Notificações de aprovação de horas';
      case NotificationType.timeLogRejection:
        return 'Notificações de rejeição de horas';
      case NotificationType.contractExpiring:
        return 'Notificações de contratos expirando';
      case NotificationType.newStudent:
        return 'Notificações de novos estudantes';
      case NotificationType.systemUpdate:
        return 'Notificações de atualizações do sistema';
      case NotificationType.reminder:
        return 'Lembretes e notificações gerais';
    }
  }

  Importance _getImportanceForType(NotificationType type) {
    switch (type) {
      case NotificationType.timeLogApproval:
      case NotificationType.timeLogRejection:
      case NotificationType.contractExpiring:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  /// Envia notificação para usuário específico
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Implementação simplificada - em produção enviaria via FCM
    final payload = NotificationPayload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.systemUpdate,
      title: title,
      body: body,
      data: data,
      timestamp: DateTime.now(),
    );

    await _showLocalNotification(payload);
    logger.i('Notificação enviada para usuário: $userId');
  }

  /// Agenda notificação
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data, // Adicionado parâmetro 'data' para 'payload'
  }) async {
    await scheduleLocalNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      data: data,
    );
  }

  /// Cancela notificação
  Future<void> cancelNotification(String id) async {
    await cancelScheduledNotification(id);
  }

  /// Verifica se notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Solicita permissão para notificações
  Future<bool> requestPermission() async {
    return await _requestPermissions();
  }

  /// Mostra notificação imediata
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final payload = NotificationPayload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.systemUpdate,
      title: title,
      body: body,
      data: data,
      timestamp: DateTime.now(),
    );

    await _showLocalNotification(payload);
  }

  /// Dispose do serviço
  void dispose() {
    _notificationStreamController.close();
    _tokenStreamController.close();
  }
}
