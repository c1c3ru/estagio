import 'dart:convert';

class CacheItem<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheItem({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

class AppCache {
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;
  AppCache._internal();

  final Map<String, CacheItem> _cache = {};

  // Cache padrão de 5 minutos
  static const Duration _defaultTtl = Duration(minutes: 5);

  void put<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = CacheItem(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTtl,
    );
  }

  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;
    
    if (item.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    return item.data as T?;
  }

  bool has(String key) {
    final item = _cache[key];
    if (item == null) return false;
    
    if (item.isExpired) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  void clearExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  int get size => _cache.length;

  // Métodos específicos para diferentes tipos de dados
  void cacheStudents(List<Map<String, dynamic>> students) {
    put('students_list', students, ttl: const Duration(minutes: 10));
  }

  List<Map<String, dynamic>>? getCachedStudents() {
    return get<List<Map<String, dynamic>>>('students_list');
  }

  void cacheStudent(String studentId, Map<String, dynamic> student) {
    put('student_$studentId', student, ttl: const Duration(minutes: 15));
  }

  Map<String, dynamic>? getCachedStudent(String studentId) {
    return get<Map<String, dynamic>>('student_$studentId');
  }

  void cacheContracts(String studentId, List<Map<String, dynamic>> contracts) {
    put('contracts_$studentId', contracts, ttl: const Duration(minutes: 10));
  }

  List<Map<String, dynamic>>? getCachedContracts(String studentId) {
    return get<List<Map<String, dynamic>>>('contracts_$studentId');
  }

  void cacheTimeLogs(String studentId, List<Map<String, dynamic>> timeLogs) {
    put('timelogs_$studentId', timeLogs, ttl: const Duration(minutes: 5));
  }

  List<Map<String, dynamic>>? getCachedTimeLogs(String studentId) {
    return get<List<Map<String, dynamic>>>('timelogs_$studentId');
  }

  void invalidateStudentCache(String studentId) {
    remove('student_$studentId');
    remove('contracts_$studentId');
    remove('timelogs_$studentId');
  }

  void invalidateAllStudentsCache() {
    remove('students_list');
    final studentKeys = _cache.keys
        .where((key) => key.startsWith('student_') || 
                       key.startsWith('contracts_') || 
                       key.startsWith('timelogs_'))
        .toList();
    
    for (final key in studentKeys) {
      remove(key);
    }
  }
}