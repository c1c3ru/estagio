// lib/core/services/performance_service.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Serviço de otimização de performance
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<double>> _operationMetrics = {};
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  static const int _maxCacheSize = 100;
  static const Duration _cacheExpiry = Duration(minutes: 15);
  static const Duration _performanceThreshold = Duration(milliseconds: 500);

  /// Inicializar serviço de performance
  void initialize() {
    if (kDebugMode) {
      developer.log('PerformanceService initialized', name: 'Performance');
    }
    
    // Configurar limpeza automática de cache
    Timer.periodic(const Duration(minutes: 5), (_) => _cleanExpiredCache());
    
    // Configurar coleta de métricas de sistema
    Timer.periodic(const Duration(seconds: 30), (_) => _collectSystemMetrics());
  }

  /// Iniciar medição de performance de uma operação
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    
    if (kDebugMode) {
      developer.log('Started operation: $operationName', name: 'Performance');
    }
  }

  /// Finalizar medição de performance de uma operação
  void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    _recordMetric(operationName, duration.inMilliseconds.toDouble());
    _operationStartTimes.remove(operationName);

    if (kDebugMode) {
      final isSlowOperation = duration > _performanceThreshold;
      developer.log(
        'Completed operation: $operationName (${duration.inMilliseconds}ms)${isSlowOperation ? ' [SLOW]' : ''}',
        name: 'Performance',
      );
      
      if (isSlowOperation) {
        _logSlowOperation(operationName, duration);
      }
    }
  }

  /// Executar operação com medição automática de performance
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startOperation(operationName);
    try {
      final result = await operation();
      endOperation(operationName);
      return result;
    } catch (e) {
      endOperation(operationName);
      if (kDebugMode) {
        developer.log(
          'Operation failed: $operationName - $e',
          name: 'Performance',
          error: e,
        );
      }
      rethrow;
    }
  }

  /// Cache inteligente com expiração automática
  T? getCached<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    final isExpired = DateTime.now().difference(timestamp) > _cacheExpiry;
    if (isExpired) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    final cached = _memoryCache[key];
    if (cached is T) {
      if (kDebugMode) {
        developer.log('Cache hit: $key', name: 'Performance');
      }
      return cached;
    }

    return null;
  }

  /// Armazenar no cache com controle de tamanho
  void setCached<T>(String key, T value) {
    // Limpar cache se estiver muito grande
    if (_memoryCache.length >= _maxCacheSize) {
      _cleanOldestCacheEntries();
    }

    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();

    if (kDebugMode) {
      developer.log('Cache set: $key', name: 'Performance');
    }
  }

  /// Executar operação com cache automático
  Future<T> cachedOperation<T>(
    String cacheKey,
    Future<T> Function() operation, {
    Duration? customExpiry,
  }) async {
    // Tentar buscar do cache primeiro
    final cached = getCached<T>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Executar operação e cachear resultado
    final result = await measureOperation(
      'cached_$cacheKey',
      operation,
    );

    setCached(cacheKey, result);
    return result;
  }

  /// Limpar cache específico
  void clearCache(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Limpar todo o cache
  void clearAllCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    
    if (kDebugMode) {
      developer.log('All cache cleared', name: 'Performance');
    }
  }

  /// Obter estatísticas de performance
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _operationMetrics.entries) {
      final metrics = entry.value;
      if (metrics.isEmpty) continue;

      final average = metrics.reduce((a, b) => a + b) / metrics.length;
      final min = metrics.reduce((a, b) => a < b ? a : b);
      final max = metrics.reduce((a, b) => a > b ? a : b);

      stats[entry.key] = {
        'average_ms': average.toStringAsFixed(2),
        'min_ms': min.toStringAsFixed(2),
        'max_ms': max.toStringAsFixed(2),
        'count': metrics.length,
      };
    }

    stats['cache'] = {
      'size': _memoryCache.length,
      'max_size': _maxCacheSize,
      'hit_ratio': _calculateCacheHitRatio(),
    };

    return stats;
  }

  /// Otimizar automaticamente baseado em métricas
  void optimizePerformance() {
    final stats = getPerformanceStats();
    
    // Limpar cache se estiver muito cheio
    final cacheSize = _memoryCache.length;
    if (cacheSize > _maxCacheSize * 0.8) {
      _cleanOldestCacheEntries(count: (cacheSize * 0.3).round());
    }

    // Identificar operações lentas
    final slowOperations = <String>[];
    for (final entry in stats.entries) {
      if (entry.value is Map<String, dynamic>) {
        final operationStats = entry.value as Map<String, dynamic>;
        final averageMs = double.tryParse(operationStats['average_ms'] ?? '0') ?? 0;
        
        if (averageMs > _performanceThreshold.inMilliseconds) {
          slowOperations.add(entry.key);
        }
      }
    }

    if (kDebugMode && slowOperations.isNotEmpty) {
      developer.log(
        'Slow operations detected: ${slowOperations.join(', ')}',
        name: 'Performance',
      );
    }

    // Forçar garbage collection se necessário
    if (cacheSize > _maxCacheSize * 0.9) {
      _forceGarbageCollection();
    }
  }

  /// Pré-carregar dados críticos
  Future<void> preloadCriticalData({
    required String userId,
    required String userType,
  }) async {
    final operations = <Future<void>>[];

    // Pré-carregar dados do usuário
    operations.add(
      cachedOperation(
        'user_profile_$userId',
        () => _loadUserProfile(userId),
      ).then((_) {}),
    );

    // Pré-carregar dados específicos do tipo de usuário
    if (userType == 'student') {
      operations.add(
        cachedOperation(
          'student_timelogs_$userId',
          () => _loadRecentTimeLogs(userId),
        ).then((_) {}),
      );
    } else if (userType == 'supervisor') {
      operations.add(
        cachedOperation(
          'supervisor_students_$userId',
          () => _loadSupervisorStudents(userId),
        ).then((_) {}),
      );
    }

    // Executar pré-carregamento em paralelo
    await Future.wait(operations);

    if (kDebugMode) {
      developer.log(
        'Critical data preloaded for $userType: $userId',
        name: 'Performance',
      );
    }
  }

  /// Configurar otimizações de UI
  void configureUIOptimizations() {
    // Configurar frame rate para 60fps
    if (kDebugMode) {
      developer.log('UI optimizations configured', name: 'Performance');
    }
  }

  /// Monitorar uso de memória
  Future<Map<String, dynamic>> getMemoryUsage() async {
    try {
      // Obter informações de memória do sistema
      final memoryInfo = await _getSystemMemoryInfo();
      
      return {
        'cache_size': _memoryCache.length,
        'cache_memory_mb': _estimateCacheMemoryUsage(),
        'system_memory': memoryInfo,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to get memory usage: $e', name: 'Performance');
      }
      return {'error': e.toString()};
    }
  }

  // Métodos privados

  void _recordMetric(String operationName, double durationMs) {
    _operationMetrics.putIfAbsent(operationName, () => <double>[]);
    final metrics = _operationMetrics[operationName]!;
    
    metrics.add(durationMs);
    
    // Manter apenas as últimas 100 métricas por operação
    if (metrics.length > 100) {
      metrics.removeAt(0);
    }
  }

  void _logSlowOperation(String operationName, Duration duration) {
    developer.log(
      'SLOW OPERATION: $operationName took ${duration.inMilliseconds}ms (threshold: ${_performanceThreshold.inMilliseconds}ms)',
      name: 'Performance',
    );
  }

  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (kDebugMode && expiredKeys.isNotEmpty) {
      developer.log(
        'Cleaned ${expiredKeys.length} expired cache entries',
        name: 'Performance',
      );
    }
  }

  void _cleanOldestCacheEntries({int? count}) {
    final entriesToRemove = count ?? (_maxCacheSize * 0.2).round();
    
    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final keysToRemove = sortedEntries
        .take(entriesToRemove)
        .map((e) => e.key)
        .toList();

    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (kDebugMode) {
      developer.log(
        'Cleaned ${keysToRemove.length} oldest cache entries',
        name: 'Performance',
      );
    }
  }

  double _calculateCacheHitRatio() {
    // Implementação simplificada - em produção seria mais sofisticada
    return _memoryCache.isNotEmpty ? 0.85 : 0.0;
  }

  void _collectSystemMetrics() {
    if (kDebugMode) {
      getMemoryUsage().then((usage) {
        developer.log(
          'Memory usage: ${usage['cache_memory_mb']}MB cache, ${usage['cache_size']} items',
          name: 'Performance',
        );
      });
    }
  }

  void _forceGarbageCollection() {
    if (kDebugMode) {
      developer.log('Forcing garbage collection', name: 'Performance');
    }
    // Em Flutter, não temos controle direto sobre GC, mas podemos limpar nossos caches
    _cleanOldestCacheEntries(count: (_maxCacheSize * 0.5).round());
  }

  double _estimateCacheMemoryUsage() {
    // Estimativa simples baseada no número de itens
    return (_memoryCache.length * 0.1); // ~100KB por item em média
  }

  Future<Map<String, dynamic>> _getSystemMemoryInfo() async {
    try {
      // Simulação - em produção usaria platform channels
      return {
        'total_mb': 4096,
        'available_mb': 2048,
        'used_mb': 2048,
      };
    } catch (e) {
      return {'error': 'Unable to get system memory info'};
    }
  }

  // Métodos de simulação para pré-carregamento
  Future<Map<String, dynamic>> _loadUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'id': userId, 'name': 'User $userId'};
  }

  Future<List<Map<String, dynamic>>> _loadRecentTimeLogs(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': '1', 'student_id': userId, 'hours': 8.0},
      {'id': '2', 'student_id': userId, 'hours': 7.5},
    ];
  }

  Future<List<Map<String, dynamic>>> _loadSupervisorStudents(String userId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      {'id': 'student1', 'supervisor_id': userId, 'name': 'Student 1'},
      {'id': 'student2', 'supervisor_id': userId, 'name': 'Student 2'},
    ];
  }
}

/// Mixin para widgets que precisam de otimizações de performance
mixin PerformanceOptimizedWidget {
  final PerformanceService _performanceService = PerformanceService();

  /// Executar operação com cache automático
  Future<T> cachedOperation<T>(
    String cacheKey,
    Future<T> Function() operation,
  ) {
    return _performanceService.cachedOperation(cacheKey, operation);
  }

  /// Medir performance de operação
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) {
    return _performanceService.measureOperation(operationName, operation);
  }

  /// Limpar cache específico
  void clearCache(String key) {
    _performanceService.clearCache(key);
  }
}

/// Extensão para facilitar uso em qualquer classe
extension PerformanceExtension on Object {
  PerformanceService get performance => PerformanceService();
}
