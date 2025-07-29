import 'package:gestao_de_estagio/core/services/notification_service.dart';
import 'package:mockito/mockito.dart';

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<bool> initialize() async {
    // Simula inicialização sem Firebase
    return true;
  }

  @override
  Stream<NotificationPayload> get notificationStream => const Stream.empty();

  @override
  Stream<String> get tokenStream => const Stream.empty();

  @override
  String? get fcmToken => 'mock-token';
}
