// lib/core/services/cache_service.dart
import 'dart:async';
// import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
// import '../constants/app_strings.dart';

class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration ttl;
  final String key;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
    required this.key,
  });

  bool get isExpired => DateTime.now().isAfter(createdAt.add(ttl));

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'ttl': ttl.inSeconds,
      'key': key,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      ttl: Duration(seconds: json['ttl']),
      key: json['key'],
    );
  }
}

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry> _memoryCache = {};
  final StreamController<String> _cacheUpdateController =
      StreamController<String>.broadcast();

  // Configurações de cache
  static const int _maxCacheSize = 100;
  static const Duration _defaultTtl = Duration(minutes: 30);
  static const Duration _cleanupInterval = Duration(minutes: 5);

  Timer? _cleanupTimer;

  /// Inicializa o serviço de cache
  Future<bool> initialize() async {
    _startCleanupTimer();
    AppLogger.info('CacheService inicializado');
    return true;
  }

  /// Adiciona um item ao cache
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
    bool persist = false,
  }) async {
    try {
      final entry = CacheEntry(
        data: data,
        createdAt: DateTime.now(),
        ttl: ttl ?? _defaultTtl,
        key: key,
      );

      // Remove entrada antiga se existir
      _memoryCache.remove(key);

      // Verifica se o cache está cheio
      if (_memoryCache.length >= _maxCacheSize) {
        _removeOldestEntries(count: 10);
      }

      _memoryCache[key] = entry;

      if (persist) {
        await _persistToStorage(key, entry);
      }

      _cacheUpdateController.add(key);

      if (kDebugMode) {
        AppLogger.debug(
            'Item adicionado ao cache: $key (TTL: ${ttl?.inMinutes ?? _defaultTtl.inMinutes}min)');
      }
    } catch (e) {
      AppLogger.error('Erro ao adicionar item ao cache', error: e);
    }
  }

  /// Obtém um item do cache
  T? get<T>(String key) {
    try {
      final entry = _memoryCache[key];

      if (entry == null) {
        return null;
      }

      if (entry.isExpired) {
        _memoryCache.remove(key);
        if (kDebugMode) {
          AppLogger.debug('Item expirado removido do cache: $key');
        }
        return null;
      }

      if (kDebugMode) {
        AppLogger.debug('Item encontrado no cache: $key');
      }

      return entry.data as T;
    } catch (e) {
      AppLogger.error('Erro ao obter item do cache', error: e);
      return null;
    }
  }

  /// Verifica se um item existe no cache e não está expirado
  bool has(String key) {
    final entry = _memoryCache[key];
    return entry != null && !entry.isExpired;
  }

  /// Remove um item específico do cache
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      await _removeFromStorage(key);
      _cacheUpdateController.add(key);

      if (kDebugMode) {
        AppLogger.debug('Item removido do cache: $key');
      }
    } catch (e) {
      AppLogger.error('Erro ao remover item do cache', error: e);
    }
  }

  /// Limpa todo o cache
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      await _clearStorage();
      _cacheUpdateController.add('*');

      if (kDebugMode) {
        AppLogger.debug('Cache limpo completamente');
      }
    } catch (e) {
      AppLogger.error('Erro ao limpar cache', error: e);
    }
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getStats() {
    // final now = DateTime.now();
    int expiredCount = 0;
    int validCount = 0;

    for (final entry in _memoryCache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return {
      'totalItems': _memoryCache.length,
      'validItems': validCount,
      'expiredItems': expiredCount,
      'maxSize': _maxCacheSize,
      'memoryUsage': _estimateMemoryUsage(),
    };
  }

  /// Stream para monitorar mudanças no cache
  Stream<String> get cacheUpdates => _cacheUpdateController.stream;

  /// Remove as entradas mais antigas do cache
  void _removeOldestEntries({int count = 5}) {
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    for (int i = 0; i < count && i < sortedEntries.length; i++) {
      _memoryCache.remove(sortedEntries[i].key);
    }

    if (kDebugMode) {
      AppLogger.debug('Removidas $count entradas antigas do cache');
    }
  }

  /// Inicia o timer de limpeza automática
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupExpiredEntries();
    });
  }

  /// Remove entradas expiradas do cache
  void _cleanupExpiredEntries() {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    if (expiredKeys.isNotEmpty && kDebugMode) {
      AppLogger.debug(
          'Limpeza automática: ${expiredKeys.length} itens expirados removidos');
    }
  }

  /// Estimativa de uso de memória
  double _estimateMemoryUsage() {
    // Estimativa simples: ~1KB por entrada
    return _memoryCache.length * 1.0;
  }

  /// Persiste entrada no storage local
  Future<void> _persistToStorage(String key, CacheEntry entry) async {
    // Implementação futura com SharedPreferences ou Hive
    // Por enquanto, apenas log
    if (kDebugMode) {
      AppLogger.debug('Persistindo entrada no storage: $key');
    }
  }

  /// Remove entrada do storage local
  Future<void> _removeFromStorage(String key) async {
    // Implementação futura
    if (kDebugMode) {
      AppLogger.debug('Removendo entrada do storage: $key');
    }
  }

  /// Limpa storage local
  Future<void> _clearStorage() async {
    // Implementação futura
    if (kDebugMode) {
      AppLogger.debug('Limpando storage local');
    }
  }

  /// Dispose do serviço
  void dispose() {
    _cleanupTimer?.cancel();
    _cacheUpdateController.close();
    _memoryCache.clear();
  }

  // ---- Compat: métodos legados usados em testes/integration ----
  Future<bool> cacheData({
    required String key,
    required Map<String, dynamic> data,
    required String entityType,
    Duration? expiresIn,
    String? syncStatus,
  }) async {
    await set<Map<String, dynamic>>(key, data, ttl: expiresIn);
    return true;
  }

  Future<Map<String, dynamic>?> getCachedData(String key) async {
    return get<Map<String, dynamic>>(key);
  }

  Future<List<Map<String, dynamic>>> getCachedDataByType(
      String entityType) async {
    // Como não persistimos por tipo, retornamos todos os itens que parecem Map e contém hint do tipo
    final result = <Map<String, dynamic>>[];
    for (final entry in _memoryCache.values) {
      if (!entry.isExpired && entry.data is Map<String, dynamic>) {
        final map = entry.data as Map<String, dynamic>;
        if (map['entity_type'] == entityType || map['_type'] == entityType) {
          result.add(map);
        }
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    // Compat: não gerenciamos operações pendentes no CacheService após refatoração
    return [];
  }

  Future<bool> clearAllCache() async {
    await clear();
    return true;
  }

  Future<int> clearExpiredData() async {
    int removed = 0;
    final keys = _memoryCache.keys.toList();
    for (final key in keys) {
      final entry = _memoryCache[key];
      if (entry != null && entry.isExpired) {
        _memoryCache.remove(key);
        removed++;
      }
    }
    return removed;
  }
}
