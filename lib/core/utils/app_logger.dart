import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static const String _tag = 'EstagioApp';
  static bool _isDebugMode = true;

  static void setDebugMode(bool isDebug) {
    _isDebugMode = isDebug;
  }

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_isDebugMode && level == LogLevel.debug) return;

    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    
    String logMessage = '[$timestamp] [$levelStr] [$logTag] $message';
    
    if (error != null) {
      logMessage += '\nError: $error';
    }
    
    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }

    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        developer.log(logMessage, name: logTag);
        break;
      case LogLevel.warning:
        developer.log(logMessage, name: logTag, level: 900);
        break;
      case LogLevel.error:
        developer.log(logMessage, name: logTag, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }
  }

  // Métodos específicos para diferentes contextos
  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    info(message, tag: 'Auth', error: error, stackTrace: stackTrace);
  }

  static void repository(String message, {Object? error, StackTrace? stackTrace}) {
    info(message, tag: 'Repository', error: error, stackTrace: stackTrace);
  }

  static void bloc(String message, {Object? error, StackTrace? stackTrace}) {
    debug(message, tag: 'BLoC', error: error, stackTrace: stackTrace);
  }

  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    info(message, tag: 'Network', error: error, stackTrace: stackTrace);
  }

  static void ui(String message, {Object? error, StackTrace? stackTrace}) {
    debug(message, tag: 'UI', error: error, stackTrace: stackTrace);
  }
}