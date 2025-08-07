import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/app_module.dart';
import 'package:gestao_de_estagio/core/services/notification_service.dart';
import 'package:gestao_de_estagio/core/services/cache_service.dart';
import 'package:gestao_de_estagio/core/services/sync_service.dart';
import 'package:gestao_de_estagio/core/services/report_service.dart';
import 'package:gestao_de_estagio/core/theme/theme_service.dart';
import '../../test/mocks/mock_notification_service.dart';
import '../../test/mocks/mock_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Mocks para serviços de persistência
class MockCacheService implements CacheService {
  final Map<String, Map<String, dynamic>> _cache = {};
  final List<Map<String, dynamic>> _pendingOperations = [];
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  @override
  Future<bool> cacheData({
    required String key,
    required Map<String, dynamic> data,
    required String entityType,
    Duration? expiresIn,
    String syncStatus = 'synced',
  }) async {
    final cacheEntry = Map<String, dynamic>.from(data);
    cacheEntry['entityType'] = entityType;
    cacheEntry['syncStatus'] = syncStatus;
    
    if (expiresIn != null) {
      cacheEntry['expiresAt'] = DateTime.now().add(expiresIn).millisecondsSinceEpoch;
    }
    
    _cache[key] = cacheEntry;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    // Check if data is expired before returning
    await clearExpiredData();
    return _cache[key];
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedDataByType(
      String entityType) async {
    // Check for expired data before returning
    await clearExpiredData();
    return _cache.values
        .where((data) => data['entityType'] == entityType)
        .toList();
  }

  @override
  Future<bool> deleteCachedData(String key) async {
    return _cache.remove(key) != null;
  }

  @override
  Future<bool> addPendingOperation({
    required String operationType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> data,
    int maxRetries = 3,
  }) async {
    final operation = {
      'id': _pendingOperations.length + 1,
      'operation_type': operationType,
      'entity_type': entityType,
      'entity_id': entityId,
      'data': data,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'max_retries': maxRetries,
      'status': 'pending',
    };
    _pendingOperations.add(operation);
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    return List<Map<String, dynamic>>.from(_pendingOperations);
  }

  @override
  Future<bool> markOperationCompleted(int operationId) async {
    return true;
  }

  @override
  Future<bool> incrementOperationRetry(int operationId) async {
    return true;
  }

  @override
  Future<int> clearExpiredData() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];
    
    _cache.forEach((key, value) {
      final expiresAt = value['expiresAt'] as int?;
      if (expiresAt != null && expiresAt < now) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    return expiredKeys.length;
  }

  @override
  Future<bool> clearAllCache() async {
    _cache.clear();
    _pendingOperations.clear();
    return true;
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    final expiredCount = await clearExpiredData();
    return {
      'totalCachedItems': _cache.length,
      'pendingOperations': _pendingOperations.length,
      'expiredItems': expiredCount,
      'isInitialized': _isInitialized,
    };
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

class MockSyncService implements SyncService {
  final MockCacheService cacheService;
  bool _isInitialized = false;
  final bool _isSyncing = false;

  MockSyncService(this.cacheService);

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Stream<SyncStatus> get syncStatus => Stream.value(SyncStatus.synced);

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  @override
  Future<bool> cacheDataOfflineFirst({
    required String key,
    required Map<String, dynamic> data,
    required String entityType,
    Duration? expiresIn,
  }) async {
    return await cacheService.cacheData(
      key: key,
      data: data,
      entityType: entityType,
      expiresIn: expiresIn,
      syncStatus: 'synced',
    );
  }

  @override
  Future<Map<String, dynamic>?> getDataCacheFirst(String key) async {
    return await cacheService.getCachedData(key);
  }

  @override
  Future<List<Map<String, dynamic>>> getDataListCacheFirst(
      String entityType) async {
    return await cacheService.getCachedDataByType(entityType);
  }

  @override
  Future<bool> addOfflineOperation({
    required String operationType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> data,
  }) async {
    return await cacheService.addPendingOperation(
      operationType: operationType,
      entityType: entityType,
      entityId: entityId,
      data: data,
    );
  }

  @override
  Future<bool> forcSync() async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> getSyncStats() async {
    final cacheStats = await cacheService.getCacheStats();
    return {
      'isOnline': true,
      'isSyncing': _isSyncing,
      'isInitialized': _isInitialized,
      'pendingOperations': cacheStats['pendingOperations'] ?? 0,
      'cachedItems': cacheStats['totalCachedItems'] ?? 0,
      'expiredItems': cacheStats['expiredItems'] ?? 0,
      'connectivity': 'online',
      'lastSyncAttempt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<bool> clearAllData() async {
    return await cacheService.clearAllCache();
  }

  @override
  void dispose() {
    cacheService.dispose();
    _isInitialized = false;
  }
}

class TestAppModule extends AppModule {
  @override
  void binds(Injector i) {
    i.addSingleton<NotificationService>(MockNotificationService.new);

    // Register mock services
    final mockCacheService = MockCacheService();
    i.addSingleton<CacheService>(() => mockCacheService);

    // Register ThemeService BEFORE SyncService since SyncService depends on it
    i.addSingleton<ThemeService>(() => ThemeService());

    final mockSyncService = MockSyncService(mockCacheService);
    i.addSingleton<SyncService>(() => mockSyncService);

    i.addSingleton<ReportService>(MockReportService.new);

    // Adicione outros mocks aqui se necessário
  }
  // As rotas e estrutura do AppModule são herdadas normalmente
}

// Mock Firebase initialization for integration tests
Future<void> mockFirebaseInitialization() async {
  // This is a simplified mock that doesn't actually initialize Firebase
  // but prevents the PlatformException during tests
  TestWidgetsFlutterBinding.ensureInitialized();
  // We don't actually initialize Firebase for tests to avoid platform channel issues
}
