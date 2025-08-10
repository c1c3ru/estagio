// lib/core/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
// import '../constants/app_strings.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  /// Stream para monitorar mudanças de conectividade
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Status atual da conectividade
  bool get isOnline => _isOnline;

  // ---- Compat: alias legado ----
  Stream<bool> get connectionStatus => connectivityStream;

  /// Inicializa o serviço de conectividade
  Future<void> initialize() async {
    try {
      // Verifica conectividade inicial
      await _checkConnectivity();

      // Escuta mudanças de conectividade
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

      AppLogger.info('ConnectivityService inicializado');
    } catch (e) {
      AppLogger.error('Erro ao inicializar ConnectivityService', error: e);
    }
  }

  /// Verifica conectividade atual
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);

        if (kDebugMode) {
          AppLogger.debug(
              'Status de conectividade alterado: ${_isOnline ? 'Online' : 'Offline'}');
        }
      }

      return _isOnline;
    } catch (e) {
      AppLogger.error('Erro ao verificar conectividade', error: e);
      return false;
    }
  }

  /// Executa operação com retry automático
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration retryDelay = _retryDelay,
    String? operationName,
  }) async {
    int attempts = 0;

    while (attempts <= maxRetries) {
      try {
        // Verifica conectividade antes de tentar
        if (!await checkConnectivity()) {
          throw Exception('Sem conectividade com a internet');
        }

        final result = await operation();

        // Sucesso - reseta contador de tentativas
        _retryCount = 0;

        if (kDebugMode) {
          AppLogger.debug(
              'Operação ${operationName ?? 'desconhecida'} executada com sucesso');
        }

        return result;
      } catch (e) {
        attempts++;

        if (kDebugMode) {
          AppLogger.warning(
              'Tentativa $attempts/${maxRetries + 1} falhou para ${operationName ?? 'operação'}: $e');
        }

        // Se é a última tentativa, falha
        if (attempts > maxRetries) {
          _retryCount = 0;
          AppLogger.error(
              'Operação ${operationName ?? 'desconhecida'} falhou após $maxRetries tentativas',
              error: e);
          rethrow;
        }

        // Aguarda antes da próxima tentativa
        await Future.delayed(retryDelay * attempts);
      }
    }

    throw Exception('Número máximo de tentativas excedido');
  }

  /// Executa operação apenas se estiver online
  Future<T?> executeIfOnline<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    if (!await checkConnectivity()) {
      if (kDebugMode) {
        AppLogger.warning(
            'Operação ${operationName ?? 'desconhecida'} cancelada - offline');
      }
      return null;
    }

    try {
      final result = await operation();

      if (kDebugMode) {
        AppLogger.debug(
            'Operação ${operationName ?? 'desconhecida'} executada com sucesso');
      }

      return result;
    } catch (e) {
      AppLogger.error(
          'Erro ao executar operação ${operationName ?? 'desconhecida'}',
          error: e);
      rethrow;
    }
  }

  /// Agenda retry para operação falhada
  Future<void> scheduleRetry(
    Future<void> Function() operation, {
    String? operationName,
  }) async {
    if (_retryCount >= _maxRetries) {
      if (kDebugMode) {
        AppLogger.warning(
            'Número máximo de retries atingido para ${operationName ?? 'operação'}');
      }
      return;
    }

    _retryCount++;

    if (kDebugMode) {
      AppLogger.info(
          'Agendando retry $_retryCount/$_maxRetries para ${operationName ?? 'operação'} em ${_retryDelay.inSeconds}s');
    }

    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () async {
      if (await checkConnectivity()) {
        try {
          await operation();
          _retryCount = 0; // Reset contador em caso de sucesso
        } catch (e) {
          AppLogger.error(
              'Retry $_retryCount/$_maxRetries falhou para ${operationName ?? 'operação'}',
              error: e);

          // Agenda próximo retry se ainda não atingiu o limite
          if (_retryCount < _maxRetries) {
            await scheduleRetry(operation, operationName: operationName);
          }
        }
      } else {
        if (kDebugMode) {
          AppLogger.warning('Retry cancelado - sem conectividade');
        }
      }
    });
  }

  /// Obtém informações detalhadas da conectividade
  Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();

      return {
        'isOnline': result != ConnectivityResult.none,
        'connectionType': result.name,
        'retryCount': _retryCount,
        'maxRetries': _maxRetries,
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.error('Erro ao obter informações de conectividade', error: e);
      return {
        'isOnline': false,
        'connectionType': 'unknown',
        'error': e.toString(),
      };
    }
  }

  /// Callback para mudanças de conectividade
  void _onConnectivityChanged(ConnectivityResult result) async {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);

      if (kDebugMode) {
        AppLogger.info(
            'Conectividade alterada: ${_isOnline ? 'Online' : 'Offline'} (${result.name})');
      }

      // Se voltou a ficar online, executa operações pendentes
      if (_isOnline) {
        _retryCount = 0; // Reset contador
        _retryTimer?.cancel();
      }
    }
  }

  /// Verifica conectividade interna
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      _connectivityController.add(_isOnline);
    } catch (e) {
      AppLogger.error('Erro ao verificar conectividade inicial', error: e);
      _isOnline = false;
      _connectivityController.add(false);
    }
  }

  /// Dispose do serviço
  void dispose() {
    _retryTimer?.cancel();
    _connectivityController.close();
  }
}
