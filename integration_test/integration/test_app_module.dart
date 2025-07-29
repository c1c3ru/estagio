import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/app_module.dart';
import 'package:gestao_de_estagio/core/services/notification_service.dart';
import '../../test/mocks/mock_notification_service.dart';
import 'package:gestao_de_estagio/core/services/report_service.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TestAppModule extends AppModule {
  @override
  @override
  List<Bind<Object>> get overrideBinds => [
    Bind.instance<NotificationService>(MockNotificationService()),
    // Adicione outros mocks aqui se necessário
  ];
  // As rotas e estrutura do AppModule são herdadas normalmente
}

