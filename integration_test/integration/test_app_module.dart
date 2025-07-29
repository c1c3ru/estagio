import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/app_module.dart';
import 'package:gestao_de_estagio/core/services/notification_service.dart';
import '../../test/mocks/mock_notification_service.dart';

class TestAppModule extends AppModule {
  @override
  void binds(Injector i) {
    i.addSingleton<NotificationService>(MockNotificationService.new);
    // Adicione outros mocks aqui se necessário
  }
  // As rotas e estrutura do AppModule são herdadas normalmente
}
