// lib/core/services/connectivity_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Serviço responsável por monitorar a conectividade de rede
/// e gerenciar o status online/offline da aplicação
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isOnline = true;
  bool _hasBeenInitialized = false;

  /// Stream que emite true quando online, false quando offline
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Status atual da conectividade
  bool get isOnline => _isOnline;

  /// Verifica se o serviço foi inicializado
  bool get isInitialized => _hasBeenInitialized;

  /// Inicializa o serviço de conectividade
  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print('🌐 ConnectivityService: Inicializando monitoramento de conectividade...');
      }

      // Verificar status inicial
      final initialResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(initialResult);

      // Escutar mudanças de conectividade
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          if (kDebugMode) {
            print('❌ ConnectivityService: Erro ao monitorar conectividade: $error');
          }
        },
      );

      _hasBeenInitialized = true;

      if (kDebugMode) {
        print('✅ ConnectivityService: Serviço inicializado. Status inicial: ${_isOnline ? 'Online' : 'Offline'}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ConnectivityService: Erro ao inicializar: $e');
      }
      return false;
    }
  }

  /// Atualiza o status de conectividade baseado no resultado
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        _isOnline = true;
        break;
      case ConnectivityResult.none:
        _isOnline = false;
        break;
      default:
        _isOnline = false;
        break;
    }

    // Emitir evento apenas se o status mudou
    if (wasOnline != _isOnline) {
      _connectionStatusController.add(_isOnline);
      
      if (kDebugMode) {
        print('🌐 ConnectivityService: Status alterado para ${_isOnline ? 'Online' : 'Offline'}');
      }
    }
  }

  /// Verifica conectividade manualmente (útil para validações específicas)
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isOnline;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ConnectivityService: Erro ao verificar conectividade: $e');
      }
      return false;
    }
  }

  /// Aguarda até que a conectividade seja restaurada
  Future<void> waitForConnection({Duration? timeout}) async {
    if (_isOnline) return;

    final completer = Completer<void>();
    StreamSubscription<bool>? subscription;

    subscription = connectionStatus.listen((isOnline) {
      if (isOnline) {
        subscription?.cancel();
        completer.complete();
      }
    });

    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError(TimeoutException('Timeout aguardando conectividade', timeout));
        }
      });
    }

    return completer.future;
  }

  /// Executa uma função apenas quando online
  Future<T?> executeWhenOnline<T>(Future<T> Function() operation, {
    Duration? timeout,
    T? fallbackValue,
  }) async {
    try {
      if (!_isOnline) {
        if (kDebugMode) {
          print('⚠️ ConnectivityService: Operação adiada - dispositivo offline');
        }
        
        if (timeout != null) {
          await waitForConnection(timeout: timeout);
        } else {
          await waitForConnection();
        }
      }

      return await operation();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ConnectivityService: Erro ao executar operação: $e');
      }
      return fallbackValue;
    }
  }

  /// Obtém informações detalhadas sobre a conectividade
  Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      return {
        'isOnline': _isOnline,
        'connectionType': result.toString().split('.').last,
        'timestamp': DateTime.now().toIso8601String(),
        'isInitialized': _hasBeenInitialized,
      };
    } catch (e) {
      return {
        'isOnline': false,
        'connectionType': 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
        'isInitialized': _hasBeenInitialized,
      };
    }
  }

  /// Simula perda de conectividade (útil para testes)
  void simulateOffline() {
    if (kDebugMode) {
      print('🧪 ConnectivityService: Simulando modo offline');
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  /// Simula restauração de conectividade (útil para testes)
  void simulateOnline() {
    if (kDebugMode) {
      print('🧪 ConnectivityService: Simulando modo online');
      _updateConnectionStatus(ConnectivityResult.wifi);
    }
  }

  /// Libera recursos do serviço
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
    _hasBeenInitialized = false;
    
    if (kDebugMode) {
      print('🌐 ConnectivityService: Serviço finalizado');
    }
  }
}

/// Exceção lançada quando uma operação expira aguardando conectividade
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}
