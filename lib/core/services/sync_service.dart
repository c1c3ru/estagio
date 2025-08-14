// lib/core/services/sync_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/app_logger.dart';
// import '../constants/app_strings.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';

enum SyncStatus { pending, syncing, completed, failed }

enum OperationType { create, update, delete }

class PendingOperation {
  final String id;
  final OperationType type;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final SyncStatus status;
  final String? errorMessage;

  PendingOperation({
    required this.id,
    required this.type,
    required this.entityType,
    this.entityId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'entityType': entityType,
      'entityId': entityId,
      'data': jsonEncode(data),
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'],
      type: OperationType.values.firstWhere((e) => e.name == json['type']),
      entityType: json['entityType'],
      entityId: json['entityId'],
      data: jsonDecode(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
      status: SyncStatus.values.firstWhere((e) => e.name == json['status']),
      errorMessage: json['errorMessage'],
    );
  }
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Database? _database;
  final ConnectivityService _connectivityService = ConnectivityService();
  // ignore: unused_field
  final CacheService _cacheService = CacheService(); // kept for future use

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  final StreamController<List<PendingOperation>> _pendingOperationsController =
      StreamController<List<PendingOperation>>.broadcast();

  bool _isInitialized = false;
  bool _isSyncing = false;
  Timer? _autoSyncTimer;

  /// Stream para monitorar status de sincronização
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Stream para monitorar operações pendentes
  Stream<List<PendingOperation>> get pendingOperationsStream =>
      _pendingOperationsController.stream;

  /// Status atual de sincronização
  bool get isSyncing => _isSyncing;
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de sincronização
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Inicializa banco de dados local
      await _initializeDatabase();

      // Configura auto-sync
      _setupAutoSync();

      _isInitialized = true;
      AppLogger.info('SyncService inicializado com sucesso');

      return true;
    } catch (e) {
      AppLogger.error('Erro ao inicializar SyncService', error: e);
      return false;
    }
  }

  /// Inicializa banco de dados SQLite
  Future<void> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'sync_operations.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Cria tabelas do banco de dados
  Future<void> _createTables(Database db, int version) async {
    // Tabela para operações pendentes
    await db.execute('''
      CREATE TABLE pending_operations (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending',
        error_message TEXT
      )
    ''');

    // Tabela para dados offline
    await db.execute('''
      CREATE TABLE offline_data (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_version INTEGER DEFAULT 1
      )
    ''');

    // Índices para performance
    await db.execute(
        'CREATE INDEX idx_pending_status ON pending_operations(status)');
    await db.execute(
        'CREATE INDEX idx_pending_entity_type ON pending_operations(entity_type)');
    await db.execute(
        'CREATE INDEX idx_offline_entity_type ON offline_data(entity_type)');
  }

  /// Atualiza banco de dados
  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Implementar migrações futuras aqui
  }

  /// Configura sincronização automática
  void _setupAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectivityService.isOnline && !_isSyncing) {
        syncPendingOperations();
      }
    });
  }

  /// Adiciona operação pendente
  Future<void> addPendingOperation({
    required OperationType type,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (!_isInitialized) {
        throw Exception('SyncService não inicializado');
      }

      final operation = PendingOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        entityType: entityType,
        entityId: entityId,
        data: data,
        createdAt: DateTime.now(),
      );

      await _database!.insert(
        'pending_operations',
        operation.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Notifica mudanças
      _notifyPendingOperationsChanged();

      if (kDebugMode) {
        AppLogger.debug(
            'Operação pendente adicionada: ${operation.type.name} ${operation.entityType}');
      }
    } catch (e) {
      AppLogger.error('Erro ao adicionar operação pendente', error: e);
      rethrow;
    }
  }

  /// Sincroniza operações pendentes
  Future<bool> syncPendingOperations() async {
    if (_isSyncing || !_connectivityService.isOnline) {
      return false;
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(SyncStatus.syncing);

      final pendingOperations = await getPendingOperations();

      if (pendingOperations.isEmpty) {
        _syncStatusController.add(SyncStatus.completed);
        return true;
      }

      int successCount = 0;
      int failureCount = 0;

      for (final operation in pendingOperations) {
        try {
          final success = await _executeOperation(operation);

          if (success) {
            await _markOperationCompleted(operation.id);
            successCount++;
          } else {
            await _incrementRetryCount(operation.id);
            failureCount++;
          }
        } catch (e) {
          await _markOperationFailed(operation.id, e.toString());
          failureCount++;
        }
      }

      _notifyPendingOperationsChanged();

      final finalStatus =
          failureCount == 0 ? SyncStatus.completed : SyncStatus.failed;
      _syncStatusController.add(finalStatus);

      if (kDebugMode) {
        AppLogger.info(
            'Sincronização concluída: $successCount sucessos, $failureCount falhas');
      }

      return failureCount == 0;
    } catch (e) {
      AppLogger.error('Erro durante sincronização', error: e);
      _syncStatusController.add(SyncStatus.failed);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Executa operação específica
  Future<bool> _executeOperation(PendingOperation operation) async {
    try {
      switch (operation.type) {
        case OperationType.create:
          return await _executeCreateOperation(operation);
        case OperationType.update:
          return await _executeUpdateOperation(operation);
        case OperationType.delete:
          return await _executeDeleteOperation(operation);
      }
    } catch (e) {
      AppLogger.error('Erro ao executar operação ${operation.type.name}',
          error: e);
      return false;
    }
  }

  /// Executa operação de criação
  Future<bool> _executeCreateOperation(PendingOperation operation) async {
    // Implementação específica para cada tipo de entidade
    switch (operation.entityType) {
      case 'time_log':
        // return await _timeLogRepository.createTimeLog(operation.data);
        return true; // Placeholder
      case 'contract':
        // return await _contractRepository.createContract(operation.data);
        return true; // Placeholder
      default:
        AppLogger.warning(
            'Tipo de entidade não suportado: ${operation.entityType}');
        return false;
    }
  }

  /// Executa operação de atualização
  Future<bool> _executeUpdateOperation(PendingOperation operation) async {
    // Implementação similar ao create
    return true; // Placeholder
  }

  /// Executa operação de exclusão
  Future<bool> _executeDeleteOperation(PendingOperation operation) async {
    // Implementação similar ao create
    return true; // Placeholder
  }

  /// Obtém operações pendentes
  Future<List<PendingOperation>> getPendingOperations() async {
    try {
      if (!_isInitialized) return [];

      final result = await _database!.query(
        'pending_operations',
        where: 'status = ? AND retry_count < 3',
        whereArgs: [SyncStatus.pending.name],
        orderBy: 'created_at ASC',
      );

      return result.map((row) => PendingOperation.fromJson(row)).toList();
    } catch (e) {
      AppLogger.error('Erro ao obter operações pendentes', error: e);
      return [];
    }
  }

  /// Marca operação como concluída
  Future<void> _markOperationCompleted(String operationId) async {
    await _database!.update(
      'pending_operations',
      {'status': SyncStatus.completed.name},
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  /// Marca operação como falhada
  Future<void> _markOperationFailed(String operationId, String error) async {
    await _database!.update(
      'pending_operations',
      {
        'status': SyncStatus.failed.name,
        'error_message': error,
      },
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  /// Incrementa contador de tentativas
  Future<void> _incrementRetryCount(String operationId) async {
    await _database!.rawUpdate(
      'UPDATE pending_operations SET retry_count = retry_count + 1 WHERE id = ?',
      [operationId],
    );
  }

  /// Armazena dados offline
  Future<void> storeOfflineData({
    required String id,
    required String entityType,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (!_isInitialized) return;

      await _database!.insert(
        'offline_data',
        {
          'id': id,
          'entity_type': entityType,
          'data': jsonEncode(data),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (kDebugMode) {
        AppLogger.debug('Dados offline armazenados: $entityType/$id');
      }
    } catch (e) {
      AppLogger.error('Erro ao armazenar dados offline', error: e);
    }
  }

  /// Obtém dados offline
  Future<List<Map<String, dynamic>>> getOfflineData(String entityType) async {
    try {
      if (!_isInitialized) return [];

      final result = await _database!.query(
        'offline_data',
        where: 'entity_type = ?',
        whereArgs: [entityType],
        orderBy: 'updated_at DESC',
      );

      return result.map((row) {
        final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        data['_offline_id'] = row['id'];
        data['_offline_updated_at'] = row['updated_at'];
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Erro ao obter dados offline', error: e);
      return [];
    }
  }

  /// Limpa dados offline antigos
  Future<void> clearOldOfflineData({Duration? olderThan}) async {
    try {
      if (!_isInitialized) return;

      final cutoff =
          DateTime.now().subtract(olderThan ?? const Duration(days: 7));

      final deletedCount = await _database!.delete(
        'offline_data',
        where: 'updated_at < ?',
        whereArgs: [cutoff.toIso8601String()],
      );

      if (kDebugMode) {
        AppLogger.debug('$deletedCount registros offline antigos removidos');
      }
    } catch (e) {
      AppLogger.error('Erro ao limpar dados offline antigos', error: e);
    }
  }

  /// Obtém estatísticas de sincronização
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      if (!_isInitialized) return {};

      final pendingCount = Sqflite.firstIntValue(
            await _database!.rawQuery(
                'SELECT COUNT(*) FROM pending_operations WHERE status = "pending"'),
          ) ??
          0;

      final failedCount = Sqflite.firstIntValue(
            await _database!.rawQuery(
                'SELECT COUNT(*) FROM pending_operations WHERE status = "failed"'),
          ) ??
          0;

      final offlineDataCount = Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM offline_data'),
          ) ??
          0;

      return {
        'pendingOperations': pendingCount,
        'failedOperations': failedCount,
        'offlineDataCount': offlineDataCount,
        'isOnline': _connectivityService.isOnline,
        'isSyncing': _isSyncing,
        'lastSync':
            DateTime.now().toIso8601String(), // Implementar tracking real
      };
    } catch (e) {
      AppLogger.error('Erro ao obter estatísticas de sincronização', error: e);
      return {};
    }
  }

  /// Notifica mudanças nas operações pendentes
  void _notifyPendingOperationsChanged() {
    getPendingOperations().then((operations) {
      _pendingOperationsController.add(operations);
    });
  }

  /// Força sincronização manual
  Future<bool> forceSync() async {
    if (!_connectivityService.isOnline) {
      AppLogger.warning('Sincronização forçada cancelada - offline');
      return false;
    }

    return await syncPendingOperations();
  }

  /// Dispose do serviço
  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
    _pendingOperationsController.close();
    _database?.close();
    _isInitialized = false;
  }

  // ---- Compat: aliases e métodos legados usados em UI/tests ----
  Stream<SyncStatus> get syncStatus => syncStatusStream;

  Future<bool> forcSync() => forceSync();

  Future<void> addOfflineOperation({
    required String operationType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> data,
  }) async {
    // Mapeia string para OperationType
    final type = () {
      switch (operationType) {
        case 'create':
          return OperationType.create;
        case 'update':
          return OperationType.update;
        case 'delete':
          return OperationType.delete;
        default:
          return OperationType.create;
      }
    }();
    await addPendingOperation(
        type: type, entityType: entityType, entityId: entityId, data: data);
  }
}
