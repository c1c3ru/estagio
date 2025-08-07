// lib/core/services/sync_service.dart
import 'dart:async';
import '../utils/app_logger.dart';
import '../constants/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';

/// Serviço responsável por sincronizar dados entre cache local e backend
/// Gerencia operações offline e sincronização automática
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final CacheService _cacheService = CacheService();
  
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  
  bool _isInitialized = false;
  bool _isSyncing = false;
  
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();

  /// Stream que emite o status da sincronização
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Verifica se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Verifica se o serviço foi inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de sincronização
  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print('🔄 SyncService: Inicializando serviço de sincronização...');
      }

      // Verificar se os serviços dependentes estão inicializados
      if (!_connectivityService.isInitialized) {
        await _connectivityService.initialize();
      }

      if (!_cacheService.isInitialized) {
        await _cacheService.initialize();
      }

      // Escutar mudanças de conectividade para sincronização automática
      _connectivitySubscription = _connectivityService.connectionStatus.listen(
        _onConnectivityChanged,
        onError: (error) {
          if (kDebugMode) {
            print('❌ SyncService: Erro ao monitorar conectividade: $error');
          }
        },
      );

      // Timer periódico para limpeza e sincronização
      _syncTimer = Timer.periodic(
        const Duration(minutes: 15),
        (timer) => _performPeriodicTasks(),
      );

      _isInitialized = true;

      // Tentar sincronização inicial se estiver online
      if (_connectivityService.isOnline) {
        unawaited(_syncPendingOperations());
      }

      if (kDebugMode) {
        print('✅ SyncService: Serviço inicializado com sucesso');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro ao inicializar: $e');
      }
      return false;
    }
  }

  /// Manipula mudanças de conectividade
  void _onConnectivityChanged(bool isOnline) {
    if (kDebugMode) {
      print('🔄 SyncService: Conectividade alterada - ${isOnline ? 'Online' : 'Offline'}');
    }

    if (isOnline && !_isSyncing) {
      // Quando voltar online, sincronizar operações pendentes
      unawaited(_syncPendingOperations());
    }
  }

  /// Executa tarefas periódicas (limpeza e sincronização)
  Future<void> _performPeriodicTasks() async {
    try {
      // Limpar dados expirados
      await _cacheService.clearExpiredData();

      // Tentar sincronizar se estiver online
      if (_connectivityService.isOnline && !_isSyncing) {
        await _syncPendingOperations();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro nas tarefas periódicas: $e');
      }
    }
  }

  /// Armazena dados no cache com estratégia offline-first
  Future<bool> cacheDataOfflineFirst({
    required String key,
    required Map<String, dynamic> data,
    required String entityType,
    Duration? expiresIn,
  }) async {
    try {
      // Sempre armazenar no cache primeiro
      final cached = await _cacheService.cacheData(
        key: key,
        data: data,
        entityType: entityType,
        expiresIn: expiresIn,
        syncStatus: _connectivityService.isOnline ? 'synced' : 'pending_sync',
      );

      if (!cached) {
        return false;
      }

      // Se offline, marcar para sincronização posterior
      if (!_connectivityService.isOnline) {
        await _cacheService.addPendingOperation(
          operationType: 'cache_sync',
          entityType: entityType,
          entityId: key,
          data: data,
        );

        if (kDebugMode) {
          print('🔄 SyncService: Dados armazenados offline - Key: $key');
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro ao armazenar dados offline-first: $e');
      }
      return false;
    }
  }

  /// Recupera dados com estratégia cache-first
  Future<Map<String, dynamic>?> getDataCacheFirst(String key) async {
    try {
      // Tentar cache primeiro
      final cachedData = await _cacheService.getCachedData(key);
      
      if (cachedData != null) {
        if (kDebugMode) {
          print('🔄 SyncService: Dados recuperados do cache - Key: $key');
        }
        return cachedData;
      }

      // Se não estiver no cache e estiver online, buscar no backend
      if (_connectivityService.isOnline) {
        if (kDebugMode) {
          print('🔄 SyncService: Cache miss - tentando backend - Key: $key');
        }
        // Aqui seria implementada a busca no backend
        // return await _fetchFromBackend(key);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro ao recuperar dados cache-first: $e');
      }
      return null;
    }
  }

  /// Recupera lista de dados por tipo com estratégia cache-first
  Future<List<Map<String, dynamic>>> getDataListCacheFirst(String entityType) async {
    try {
      // Sempre retornar dados do cache primeiro
      final cachedData = await _cacheService.getCachedDataByType(entityType);
      
      if (kDebugMode) {
        print('🔄 SyncService: ${cachedData.length} itens recuperados do cache - Type: $entityType');
      }

      // Se estiver online e não tiver dados no cache, buscar no backend
      if (_connectivityService.isOnline && cachedData.isEmpty) {
        if (kDebugMode) {
          print('🔄 SyncService: Cache vazio - tentando backend - Type: $entityType');
        }
        // Aqui seria implementada a busca no backend
        // final backendData = await _fetchListFromBackend(entityType);
        // if (backendData.isNotEmpty) {
        //   await _cacheMultipleData(backendData, entityType);
        //   return backendData;
        // }
      }

      return cachedData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro ao recuperar lista cache-first: $e');
      }
      return [];
    }
  }

  /// Adiciona operação para execução offline
  Future<bool> addOfflineOperation({
    required String operationType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final success = await _cacheService.addPendingOperation(
        operationType: operationType,
        entityType: entityType,
        entityId: entityId,
        data: data,
      );

      if (success) {
        _syncStatusController.add(SyncStatus.pendingOperationsAdded);
        
        // Se estiver online, tentar sincronizar imediatamente
        if (_connectivityService.isOnline && !_isSyncing) {
          unawaited(_syncPendingOperations());
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro ao adicionar operação offline: $e');
      }
      return false;
    }
  }

  /// Sincroniza operações pendentes com o backend
  Future<bool> _syncPendingOperations() async {
    if (_isSyncing || !_connectivityService.isOnline) {
      return false;
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(SyncStatus.syncing);

      if (kDebugMode) {
        print('🔄 SyncService: Iniciando sincronização de operações pendentes...');
      }

      final pendingOperations = await _cacheService.getPendingOperations();
      
      if (pendingOperations.isEmpty) {
        if (kDebugMode) {
          print('🔄 SyncService: Nenhuma operação pendente para sincronizar');
        }
        _syncStatusController.add(SyncStatus.synced);
        return true;
      }

      int successCount = 0;
      int failureCount = 0;

      for (final operation in pendingOperations) {
        try {
          final operationId = operation['id'] as int;
          final operationType = operation['operation_type'] as String;
          final entityType = operation['entity_type'] as String;
          final data = operation['data'] as Map<String, dynamic>;

          // Aqui seria implementada a sincronização específica para cada tipo de operação
          final success = await _executeSyncOperation(operationType, entityType, data);

          if (success) {
            await _cacheService.markOperationCompleted(operationId);
            successCount++;
            
            if (kDebugMode) {
              print('✅ SyncService: Operação sincronizada - Type: $operationType, Entity: $entityType');
            }
          } else {
            await _cacheService.incrementOperationRetry(operationId);
            failureCount++;
            
            if (kDebugMode) {
              print('❌ SyncService: Falha na sincronização - Type: $operationType, Entity: $entityType');
            }
          }
        } catch (e) {
          failureCount++;
          if (kDebugMode) {
            AppLogger.error('\u001b[31m${AppStrings.errorOccurred}: ${AppStrings.serverError} - $e\u001b[0m');
          }
        }
      }

      if (kDebugMode) {
        print('🔄 SyncService: Sincronização concluída - Sucesso: $successCount, Falhas: $failureCount');
      }

      _syncStatusController.add(
        failureCount == 0 ? SyncStatus.synced : SyncStatus.partialSync,
      );

      return failureCount == 0;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('\u001b[31m${AppStrings.errorOccurred}: ${AppStrings.serverError} - $e\u001b[0m');
      }
      _syncStatusController.add(SyncStatus.syncError);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Executa uma operação de sincronização específica
  Future<bool> _executeSyncOperation(
    String operationType,
    String entityType,
    Map<String, dynamic> data,
  ) async {
    try {
      // Aqui seria implementada a lógica específica para cada tipo de operação
      // Por exemplo:
      switch (operationType) {
        case 'create':
          // return await _createInBackend(entityType, data);
          break;
        case 'update':
          // return await _updateInBackend(entityType, data);
          break;
        case 'delete':
          // return await _deleteInBackend(entityType, data);
          break;
        case 'cache_sync':
          // return await _syncCacheToBackend(entityType, data);
          break;
        default:
          if (kDebugMode) {
            print('⚠️ SyncService: Tipo de operação desconhecido: $operationType');
          }
          return false;
      }

      // Por enquanto, simular sucesso para demonstração
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('\u001b[31m${AppStrings.errorOccurred}: ${AppStrings.serverError} [$operationType] - $e\u001b[0m');
      }
      return false;
    }
  }

  /// Força sincronização manual
  Future<bool> forcSync() async {
    if (!_connectivityService.isOnline) {
      if (kDebugMode) {
        print('⚠️ SyncService: Não é possível sincronizar - dispositivo offline');
      }
      return false;
    }

    return await _syncPendingOperations();
  }

  /// Obtém estatísticas de sincronização
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final cacheStats = await _cacheService.getCacheStats();
      final connectivityInfo = await _connectivityService.getConnectionInfo();

      return {
        'isOnline': _connectivityService.isOnline,
        'isSyncing': _isSyncing,
        'isInitialized': _isInitialized,
        'pendingOperations': cacheStats['pendingOperations'] ?? 0,
        'cachedItems': cacheStats['totalCachedItems'] ?? 0,
        'expiredItems': cacheStats['expiredItems'] ?? 0,
        'connectivity': connectivityInfo,
        'lastSyncAttempt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'isOnline': false,
        'isSyncing': false,
        'isInitialized': false,
        'error': e.toString(),
      };
    }
  }

  /// Limpa todos os dados de cache e operações pendentes
  Future<bool> clearAllData() async {
    try {
      final success = await _cacheService.clearAllCache();
      
      if (success) {
        _syncStatusController.add(SyncStatus.cleared);
        
        if (kDebugMode) {
          print('🔄 SyncService: Todos os dados foram limpos');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SyncService: Erro ao limpar dados: $e');
      }
      return false;
    }
  }

  /// Libera recursos do serviço
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _syncStatusController.close();
    _isInitialized = false;
    
    if (kDebugMode) {
      print('🔄 SyncService: Serviço finalizado');
    }
  }
}

/// Status da sincronização
enum SyncStatus {
  syncing,
  synced,
  partialSync,
  syncError,
  pendingOperationsAdded,
  cleared,
}

/// Extensão para facilitar uso do SyncStatus
extension SyncStatusExtension on SyncStatus {
  String get description {
    switch (this) {
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.synced:
        return 'Sincronizado';
      case SyncStatus.partialSync:
        return 'Sincronização parcial';
      case SyncStatus.syncError:
        return 'Erro na sincronização';
      case SyncStatus.pendingOperationsAdded:
        return 'Operações adicionadas à fila';
      case SyncStatus.cleared:
        return 'Dados limpos';
    }
  }

  bool get isError => this == SyncStatus.syncError;
  bool get isSuccess => this == SyncStatus.synced;
  bool get isInProgress => this == SyncStatus.syncing;
}

/// Função auxiliar para não aguardar futures
void unawaited(Future<void> future) {
  // Ignora o resultado do future para execução assíncrona
}
