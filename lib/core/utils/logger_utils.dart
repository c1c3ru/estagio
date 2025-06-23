// lib/core/utils/logger_utils.dart
import 'package:logger/logger.dart';

/// Instância global do Logger para ser usada em toda a aplicação.
/// A configuração pode ser ajustada aqui conforme necessário.
final AppLogger logger = AppLogger();

class AppLogger {
  late final Logger _logger;

  AppLogger() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1, // Mostra 1 método na stack trace
        errorMethodCount: 8, // Mostra mais para erros
        lineLength: 100, // Largura da linha
        colors: true, // Usa cores no console
        printEmojis: true, // Mostra emojis para níveis de log
        printTime: true, // Mostra timestamp
      ),
      // Pode-se definir um nível de log diferente para produção vs desenvolvimento
      // filter: ProductionFilter(), // Exemplo
    );
  }

  void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

// Exemplo de filtro para produção (opcional)
// class ProductionFilter extends LogFilter {
//   @override
//   bool shouldLog(LogEvent event) {
//     return event.level.index >= Level.warning.index; // Só loga warnings e acima em produção
//   }
// }
