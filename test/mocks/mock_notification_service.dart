import 'package:gestao_de_estagio/core/services/notification_service.dart';
import 'package:mockito/mockito.dart';

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<bool> initialize() async {
    // Simula inicialização sem Firebase
    return true;
  }

  @override
  Future<void> safeInitializeFirebase() async {
    // Mock Firebase initialization to prevent platform channel errors
    // Do nothing, completely skip Firebase initialization
  }

  @override
  Stream<NotificationPayload> get notificationStream => const Stream.empty();

  @override
  Stream<String> get tokenStream => const Stream.empty();

  @override
  String? get fcmToken => 'mock-token';

  @override
  Future<void> scheduleLocalNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationType type = NotificationType.reminder,
    Map<String, dynamic>? data,
  }) async {
    // Mock implementation without Firebase
    return;
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Mock implementation without Firebase
    return;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    // Mock implementation
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    // Mock implementation
    return true;
  }
}
