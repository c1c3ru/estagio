// lib/core/utils/module_guard.dart
import 'package:flutter/foundation.dart';

/// Sistema de proteção contra múltipla inicialização de módulos
/// Resolve erros como: ModuleStartedException: Module BackgroundDownloadModule is already started
class ModuleGuard {
  static final ModuleGuard _instance = ModuleGuard._internal();
  factory ModuleGuard() => _instance;
  ModuleGuard._internal();

  final Set<String> _initializedModules = <String>{};
  final Set<String> _initializedServices = <String>{};

  /// Verifica se um módulo já foi inicializado
  bool isModuleInitialized(String moduleName) {
    return _initializedModules.contains(moduleName);
  }

  /// Marca um módulo como inicializado
  void markModuleAsInitialized(String moduleName) {
    if (_initializedModules.contains(moduleName)) {
      if (kDebugMode) {
        print('⚠️ Tentativa de reinicializar módulo já inicializado: $moduleName');
      }
      return;
    }
    _initializedModules.add(moduleName);
    if (kDebugMode) {
      print('✅ Módulo inicializado: $moduleName');
    }
  }

  /// Verifica se um serviço já foi inicializado
  bool isServiceInitialized(String serviceName) {
    return _initializedServices.contains(serviceName);
  }

  /// Marca um serviço como inicializado
  void markServiceAsInitialized(String serviceName) {
    if (_initializedServices.contains(serviceName)) {
      if (kDebugMode) {
        print('⚠️ Tentativa de reinicializar serviço já inicializado: $serviceName');
      }
      return;
    }
    _initializedServices.add(serviceName);
    if (kDebugMode) {
      print('✅ Serviço inicializado: $serviceName');
    }
  }

  /// Executa uma função apenas se o módulo não foi inicializado
  Future<T?> executeOnce<T>(
    String moduleName,
    Future<T> Function() initFunction,
  ) async {
    if (isModuleInitialized(moduleName)) {
      if (kDebugMode) {
        print('⚠️ Pulando inicialização de módulo já inicializado: $moduleName');
      }
      return null;
    }

    try {
      final result = await initFunction();
      markModuleAsInitialized(moduleName);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao inicializar módulo $moduleName: $e');
      }
      rethrow;
    }
  }

  /// Executa uma função de serviço apenas se não foi inicializado
  Future<T?> executeServiceOnce<T>(
    String serviceName,
    Future<T> Function() initFunction,
  ) async {
    if (isServiceInitialized(serviceName)) {
      if (kDebugMode) {
        print('⚠️ Pulando inicialização de serviço já inicializado: $serviceName');
      }
      return null;
    }

    try {
      final result = await initFunction();
      markServiceAsInitialized(serviceName);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao inicializar serviço $serviceName: $e');
      }
      rethrow;
    }
  }

  /// Reseta o estado de inicialização (útil para testes)
  void reset() {
    _initializedModules.clear();
    _initializedServices.clear();
    if (kDebugMode) {
      print('🔄 ModuleGuard resetado');
    }
  }

  /// Lista módulos e serviços inicializados (debug)
  void printStatus() {
    if (kDebugMode) {
      print('📊 ModuleGuard Status:');
      print('  Módulos inicializados: $_initializedModules');
      print('  Serviços inicializados: $_initializedServices');
    }
  }
}

/// Extensão para facilitar uso do ModuleGuard
extension ModuleGuardExtension on String {
  /// Verifica se este módulo já foi inicializado
  bool get isModuleInitialized => ModuleGuard().isModuleInitialized(this);
  
  /// Marca este módulo como inicializado
  void markModuleAsInitialized() => ModuleGuard().markModuleAsInitialized(this);
  
  /// Verifica se este serviço já foi inicializado
  bool get isServiceInitialized => ModuleGuard().isServiceInitialized(this);
  
  /// Marca este serviço como inicializado
  void markServiceAsInitialized() => ModuleGuard().markServiceAsInitialized(this);
}
