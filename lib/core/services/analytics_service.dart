import 'dart:async';
// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/app_logger.dart';
// import '../constants/app_strings.dart';

enum AnalyticsEvent {
  appOpen,
  userLogin,
  userLogout,
  checkIn,
  checkOut,
  timeLogCreated,
  timeLogApproved,
  timeLogRejected,
  contractCreated,
  contractUpdated,
  reportGenerated,
  notificationReceived,
  errorOccurred,
  featureUsed,
  pageView,
}

enum UserProperty {
  userRole,
  userType,
  isActive,
  lastLogin,
  totalHours,
  contractsCount,
  timeLogsCount,
}

class AnalyticsData {
  final String eventName;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;

  AnalyticsData({
    required this.eventName,
    required this.parameters,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      eventName: json['eventName'],
      parameters: json['parameters'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      sessionId: json['sessionId'],
    );
  }
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _firebaseAnalytics;
  final StreamController<AnalyticsData> _analyticsController =
      StreamController<AnalyticsData>.broadcast();

  bool _isInitialized = false;
  String? _currentUserId;
  String? _currentSessionId;
  final List<AnalyticsData> _pendingEvents = [];
  Timer? _flushTimer;

  /// Stream para eventos de analytics
  Stream<AnalyticsData> get analyticsStream => _analyticsController.stream;

  /// Status de inicialização
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de analytics
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Inicializa Firebase Analytics
      await _initializeFirebaseAnalytics();

      // Configura timer para flush de eventos
      _setupFlushTimer();

      // Gera ID de sessão
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

      _isInitialized = true;
      AppLogger.info('AnalyticsService inicializado com sucesso');

      return true;
    } catch (e) {
      AppLogger.error('Erro ao inicializar AnalyticsService', error: e);
      return false;
    }
  }

  /// Inicializa Firebase Analytics
  Future<void> _initializeFirebaseAnalytics() async {
    try {
      _firebaseAnalytics = FirebaseAnalytics.instance;

      // Configura propriedades padrão
      await _firebaseAnalytics!.setAnalyticsCollectionEnabled(true);

      if (kDebugMode) {
        AppLogger.debug('Firebase Analytics inicializado');
      }
    } catch (e) {
      AppLogger.warning('Firebase Analytics não disponível: $e');
    }
  }

  /// Configura timer para flush de eventos
  void _setupFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _flushPendingEvents();
    });
  }

  /// Define usuário atual
  Future<void> setUserId(String userId) async {
    _currentUserId = userId;

    try {
      await _firebaseAnalytics?.setUserId(id: userId);

      if (kDebugMode) {
        AppLogger.debug('User ID definido: $userId');
      }
    } catch (e) {
      AppLogger.error('Erro ao definir User ID', error: e);
    }
  }

  /// Define propriedades do usuário
  Future<void> setUserProperty(UserProperty property, String value) async {
    try {
      await _firebaseAnalytics?.setUserProperty(
        name: property.name,
        value: value,
      );

      if (kDebugMode) {
        AppLogger.debug('User property definida: ${property.name} = $value');
      }
    } catch (e) {
      AppLogger.error('Erro ao definir user property', error: e);
    }
  }

  /// Registra evento de analytics
  Future<void> logEvent(
    AnalyticsEvent event, {
    Map<String, dynamic>? parameters,
    String? userId,
  }) async {
    try {
      final eventData = AnalyticsData(
        eventName: event.name,
        parameters: parameters ?? {},
        timestamp: DateTime.now(),
        userId: userId ?? _currentUserId,
        sessionId: _currentSessionId,
      );

      // Adiciona à lista de eventos pendentes
      _pendingEvents.add(eventData);

      // Notifica stream
      _analyticsController.add(eventData);

      // Tenta enviar imediatamente se Firebase estiver disponível
      if (_firebaseAnalytics != null) {
        await _firebaseAnalytics!.logEvent(
          name: event.name,
          parameters: parameters?.cast<String, Object>(),
        );
      }

      if (kDebugMode) {
        AppLogger.debug('Evento registrado: ${event.name}');
      }
    } catch (e) {
      AppLogger.error('Erro ao registrar evento', error: e);
    }
  }

  /// Registra evento de página visualizada
  Future<void> logPageView({
    required String pageName,
    String? pageClass,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _firebaseAnalytics?.logScreenView(
        screenName: pageName,
        screenClass: pageClass,
      );

      await logEvent(
        AnalyticsEvent.pageView,
        parameters: {
          'page_name': pageName,
          'page_class': pageClass,
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar page view', error: e);
    }
  }

  /// Registra erro
  Future<void> logError({
    required String error,
    required String errorType,
    StackTrace? stackTrace,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.errorOccurred,
        parameters: {
          'error': error,
          'error_type': errorType,
          'stack_trace': stackTrace?.toString(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar erro de analytics', error: e);
    }
  }

  /// Registra uso de funcionalidade
  Future<void> logFeatureUsage({
    required String featureName,
    String? featureCategory,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.featureUsed,
        parameters: {
          'feature_name': featureName,
          'feature_category': featureCategory,
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar uso de funcionalidade', error: e);
    }
  }

  /// Registra check-in
  Future<void> logCheckIn({
    required String studentId,
    String? location,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.checkIn,
        parameters: {
          'student_id': studentId,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar check-in', error: e);
    }
  }

  /// Registra check-out
  Future<void> logCheckOut({
    required String studentId,
    required double hoursWorked,
    String? location,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.checkOut,
        parameters: {
          'student_id': studentId,
          'hours_worked': hoursWorked,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar check-out', error: e);
    }
  }

  /// Registra criação de time log
  Future<void> logTimeLogCreated({
    required String timeLogId,
    required String studentId,
    required double hours,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.timeLogCreated,
        parameters: {
          'time_log_id': timeLogId,
          'student_id': studentId,
          'hours': hours,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar criação de time log', error: e);
    }
  }

  /// Registra aprovação/rejeição de time log
  Future<void> logTimeLogStatus({
    required String timeLogId,
    required String studentId,
    required bool approved,
    String? reason,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final event = approved
          ? AnalyticsEvent.timeLogApproved
          : AnalyticsEvent.timeLogRejected;

      await logEvent(
        event,
        parameters: {
          'time_log_id': timeLogId,
          'student_id': studentId,
          'approved': approved,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar status de time log', error: e);
    }
  }

  /// Registra criação de contrato
  Future<void> logContractCreated({
    required String contractId,
    required String studentId,
    required String contractType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.contractCreated,
        parameters: {
          'contract_id': contractId,
          'student_id': studentId,
          'contract_type': contractType,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar criação de contrato', error: e);
    }
  }

  /// Registra geração de relatório
  Future<void> logReportGenerated({
    required String reportId,
    required String reportType,
    required String generatedBy,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.reportGenerated,
        parameters: {
          'report_id': reportId,
          'report_type': reportType,
          'generated_by': generatedBy,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar geração de relatório', error: e);
    }
  }

  /// Registra recebimento de notificação
  Future<void> logNotificationReceived({
    required String notificationId,
    required String notificationType,
    String? userId,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logEvent(
        AnalyticsEvent.notificationReceived,
        parameters: {
          'notification_id': notificationId,
          'notification_type': notificationType,
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
          ...?parameters,
        },
      );
    } catch (e) {
      AppLogger.error('Erro ao registrar recebimento de notificação', error: e);
    }
  }

  /// Obtém eventos pendentes
  List<AnalyticsData> getPendingEvents() {
    return List.from(_pendingEvents);
  }

  /// Força flush de eventos pendentes
  Future<void> flushEvents() async {
    await _flushPendingEvents();
  }

  /// Flush de eventos pendentes
  Future<void> _flushPendingEvents() async {
    if (_pendingEvents.isEmpty) return;

    try {
      // Em produção, enviaria para servidor próprio ou Firebase
      if (kDebugMode) {
        AppLogger.debug(
            'Flush de ${_pendingEvents.length} eventos de analytics');
      }

      // Limpa eventos após flush
      _pendingEvents.clear();
    } catch (e) {
      AppLogger.error('Erro ao fazer flush de eventos', error: e);
    }
  }

  /// Obtém estatísticas de analytics
  Map<String, dynamic> getAnalyticsStats() {
    return {
      'pendingEvents': _pendingEvents.length,
      'currentUserId': _currentUserId,
      'currentSessionId': _currentSessionId,
      'isInitialized': _isInitialized,
      'firebaseAvailable': _firebaseAnalytics != null,
    };
  }

  /// Limpa dados de analytics
  void clearAnalyticsData() {
    _pendingEvents.clear();
    _currentUserId = null;
    _currentSessionId = null;
  }

  /// Reseta sessão
  void resetSession() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    if (kDebugMode) {
      AppLogger.debug('Sessão de analytics resetada');
    }
  }

  /// Habilita/desabilita coleta de analytics
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      await _firebaseAnalytics?.setAnalyticsCollectionEnabled(enabled);

      if (kDebugMode) {
        AppLogger.debug('Analytics ${enabled ? 'habilitado' : 'desabilitado'}');
      }
    } catch (e) {
      AppLogger.error('Erro ao configurar analytics', error: e);
    }
  }

  /// Dispose do serviço
  void dispose() {
    _flushTimer?.cancel();
    _analyticsController.close();
    _isInitialized = false;
  }
}
