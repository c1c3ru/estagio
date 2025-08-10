import 'package:gestao_de_estagio/core/services/notification_service.dart';
import 'package:mockito/mockito.dart';

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<bool> initialize() async => true;

  @override
  Stream<NotificationData> get notificationStream => const Stream.empty();

  @override
  String? get fcmToken => 'mock-token';

  @override
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? payload,
  }) async {}

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? payload,
  }) async {}

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;
}
