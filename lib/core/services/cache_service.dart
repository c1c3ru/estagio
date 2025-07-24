// lib/core/services/cache_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Serviço responsável por gerenciar cache local usando SQLite
/// para suporte offline e sincronização de dados
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Database? _database;
  bool _isInitialized = false;

  /// Verifica se o serviço foi inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa o banco de dados local
  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print('💾 CacheService: Inicializando banco de dados local...');
      }

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'estagio_cache.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onUpgrade: _upgradeDatabase,
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ CacheService: Banco de dados inicializado em: $path');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao inicializar banco: $e');
      }
      return false;
    }
  }

  /// Cria as tabelas do banco de dados
  Future<void> _createTables(Database db, int version) async {
    if (kDebugMode) {
      print('💾 CacheService: Criando tabelas do banco...');
    }

    // Tabela para cache genérico de dados
    await db.execute('''
      CREATE TABLE cache_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        data TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        expires_at INTEGER,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // Tabela para operações pendentes (para sincronização)
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        max_retries INTEGER DEFAULT 3,
        status TEXT DEFAULT 'pending'
      )
    ''');

    // Tabela para metadados de sincronização
    await db.execute('''
      CREATE TABLE sync_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT UNIQUE NOT NULL,
        last_sync_at INTEGER,
        sync_version INTEGER DEFAULT 1,
        total_records INTEGER DEFAULT 0
      )
    ''');

    // Índices para melhor performance
    await db.execute('CREATE INDEX idx_cache_key ON cache_data(key)');
    await db.execute('CREATE INDEX idx_cache_entity_type ON cache_data(entity_type)');
    await db.execute('CREATE INDEX idx_cache_expires_at ON cache_data(expires_at)');
    await db.execute('CREATE INDEX idx_pending_status ON pending_operations(status)');
    await db.execute('CREATE INDEX idx_pending_entity_type ON pending_operations(entity_type)');

    if (kDebugMode) {
      print('✅ CacheService: Tabelas criadas com sucesso');
    }
  }

  /// Atualiza o banco de dados para versões mais recentes
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('💾 CacheService: Atualizando banco da versão $oldVersion para $newVersion');
    }
    // Implementar migrações futuras aqui
  }

  /// Armazena dados no cache
  Future<bool> cacheData({
    required String key,
    required Map<String, dynamic> data,
    required String entityType,
    Duration? expiresIn,
    String syncStatus = 'synced',
  }) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final expiresAt = expiresIn != null ? now + expiresIn.inMilliseconds : null;

      await _database!.insert(
        'cache_data',
        {
          'key': key,
          'data': jsonEncode(data),
          'entity_type': entityType,
          'created_at': now,
          'updated_at': now,
          'expires_at': expiresAt,
          'sync_status': syncStatus,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (kDebugMode) {
        print('💾 CacheService: Dados armazenados - Key: $key, Type: $entityType');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao armazenar dados: $e');
      }
      return false;
    }
  }

  /// Recupera dados do cache
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      final result = await _database!.query(
        'cache_data',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      final record = result.first;
      final expiresAt = record['expires_at'] as int?;
      
      // Verificar se expirou
      if (expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await deleteCachedData(key);
        return null;
      }

      final data = jsonDecode(record['data'] as String) as Map<String, dynamic>;
      
      if (kDebugMode) {
        print('💾 CacheService: Dados recuperados - Key: $key');
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao recuperar dados: $e');
      }
      return null;
    }
  }

  /// Recupera múltiplos dados por tipo de entidade
  Future<List<Map<String, dynamic>>> getCachedDataByType(String entityType) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      
      final result = await _database!.query(
        'cache_data',
        where: 'entity_type = ? AND (expires_at IS NULL OR expires_at > ?)',
        whereArgs: [entityType, now],
        orderBy: 'updated_at DESC',
      );

      final dataList = result.map((record) {
        final data = jsonDecode(record['data'] as String) as Map<String, dynamic>;
        data['_cache_key'] = record['key'];
        data['_cache_updated_at'] = record['updated_at'];
        data['_cache_sync_status'] = record['sync_status'];
        return data;
      }).toList();

      if (kDebugMode) {
        print('💾 CacheService: ${dataList.length} registros recuperados para tipo: $entityType');
      }

      return dataList;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao recuperar dados por tipo: $e');
      }
      return [];
    }
  }

  /// Remove dados do cache
  Future<bool> deleteCachedData(String key) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      await _database!.delete(
        'cache_data',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (kDebugMode) {
        print('💾 CacheService: Dados removidos - Key: $key');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao remover dados: $e');
      }
      return false;
    }
  }

  /// Adiciona operação pendente para sincronização
  Future<bool> addPendingOperation({
    required String operationType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> data,
    int maxRetries = 3,
  }) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      await _database!.insert('pending_operations', {
        'operation_type': operationType,
        'entity_type': entityType,
        'entity_id': entityId,
        'data': jsonEncode(data),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'max_retries': maxRetries,
        'status': 'pending',
      });

      if (kDebugMode) {
        print('💾 CacheService: Operação pendente adicionada - Type: $operationType, Entity: $entityType');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao adicionar operação pendente: $e');
      }
      return false;
    }
  }

  /// Recupera operações pendentes para sincronização
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      final result = await _database!.query(
        'pending_operations',
        where: 'status = ? AND retry_count < max_retries',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
      );

      return result.map((record) {
        final data = Map<String, dynamic>.from(record);
        data['data'] = jsonDecode(record['data'] as String);
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao recuperar operações pendentes: $e');
      }
      return [];
    }
  }

  /// Marca operação como concluída
  Future<bool> markOperationCompleted(int operationId) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      await _database!.update(
        'pending_operations',
        {'status': 'completed'},
        where: 'id = ?',
        whereArgs: [operationId],
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao marcar operação como concluída: $e');
      }
      return false;
    }
  }

  /// Incrementa contador de tentativas de uma operação
  Future<bool> incrementOperationRetry(int operationId) async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      await _database!.rawUpdate(
        'UPDATE pending_operations SET retry_count = retry_count + 1 WHERE id = ?',
        [operationId],
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao incrementar tentativas: $e');
      }
      return false;
    }
  }

  /// Limpa dados expirados do cache
  Future<int> clearExpiredData() async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final deletedCount = await _database!.delete(
        'cache_data',
        where: 'expires_at IS NOT NULL AND expires_at <= ?',
        whereArgs: [now],
      );

      if (kDebugMode) {
        print('💾 CacheService: $deletedCount registros expirados removidos');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao limpar dados expirados: $e');
      }
      return 0;
    }
  }

  /// Limpa todo o cache
  Future<bool> clearAllCache() async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      await _database!.delete('cache_data');
      await _database!.delete('pending_operations');
      await _database!.delete('sync_metadata');

      if (kDebugMode) {
        print('💾 CacheService: Todo o cache foi limpo');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao limpar cache: $e');
      }
      return false;
    }
  }

  /// Obtém estatísticas do cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (!_isInitialized || _database == null) {
        throw Exception('CacheService não inicializado');
      }

      final cacheCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM cache_data'),
      ) ?? 0;

      final pendingCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM pending_operations WHERE status = "pending"'),
      ) ?? 0;

      final expiredCount = Sqflite.firstIntValue(
        await _database!.rawQuery(
          'SELECT COUNT(*) FROM cache_data WHERE expires_at IS NOT NULL AND expires_at <= ?',
          [DateTime.now().millisecondsSinceEpoch],
        ),
      ) ?? 0;

      return {
        'totalCachedItems': cacheCount,
        'pendingOperations': pendingCount,
        'expiredItems': expiredCount,
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao obter estatísticas: $e');
      }
      return {
        'totalCachedItems': 0,
        'pendingOperations': 0,
        'expiredItems': 0,
        'isInitialized': false,
        'error': e.toString(),
      };
    }
  }

  /// Libera recursos do serviço
  Future<void> dispose() async {
    try {
      await _database?.close();
      _database = null;
      _isInitialized = false;
      
      if (kDebugMode) {
        print('💾 CacheService: Serviço finalizado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheService: Erro ao finalizar serviço: $e');
      }
    }
  }
}
