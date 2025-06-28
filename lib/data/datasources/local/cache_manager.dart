class CacheManager {
  final Map<String, CacheItem> _cache = {};

  void put(String key, dynamic data, {Duration? ttl}) {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = CacheItem(data: data, expiry: expiry);
  }

  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    if (item.expiry != null && DateTime.now().isAfter(item.expiry!)) {
      _cache.remove(key);
      return null;
    }

    return item.data as T?;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  bool containsKey(String key) {
    final item = _cache[key];
    if (item == null) return false;

    if (item.expiry != null && DateTime.now().isAfter(item.expiry!)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere(
        (key, item) => item.expiry != null && now.isAfter(item.expiry!));
  }

  // ===== MÉTODOS ESPECÍFICOS PARA DADOS DE ESTUDANTES =====

  // Lista de colegas online - TTL: 5 minutos (dados mudam frequentemente)
  void putOnlineColleagues(List<dynamic> colleagues) {
    put('online_colleagues', colleagues, ttl: const Duration(minutes: 5));
  }

  List<dynamic>? getOnlineColleagues() {
    return get<List<dynamic>>('online_colleagues');
  }

  // Histórico de time logs - TTL: 1 hora
  void putTimeLogsHistory(List<dynamic> timeLogs) {
    put('time_logs_history', timeLogs, ttl: const Duration(hours: 1));
  }

  List<dynamic>? getTimeLogsHistory() {
    return get<List<dynamic>>('time_logs_history');
  }

  // Contratos ativos - TTL: 2 horas
  void putActiveContracts(List<dynamic> contracts) {
    put('active_contracts', contracts, ttl: const Duration(hours: 2));
  }

  List<dynamic>? getActiveContracts() {
    return get<List<dynamic>>('active_contracts');
  }

  // ===== MÉTODOS ESPECÍFICOS PARA DADOS DE SUPERVISORES =====

  // Lista de estudantes supervisionados - TTL: 1 hora
  void putSupervisedStudents(List<dynamic> students) {
    put('supervised_students', students, ttl: const Duration(hours: 1));
  }

  List<dynamic>? getSupervisedStudents() {
    return get<List<dynamic>>('supervised_students');
  }

  // Time logs pendentes de aprovação - TTL: 30 minutos
  void putPendingTimeLogs(List<dynamic> timeLogs) {
    put('pending_time_logs', timeLogs, ttl: const Duration(minutes: 30));
  }

  List<dynamic>? getPendingTimeLogs() {
    return get<List<dynamic>>('pending_time_logs');
  }

  // Estatísticas de contratos - TTL: 2 horas
  void putContractStatistics(Map<String, dynamic> statistics) {
    put('contract_statistics', statistics, ttl: const Duration(hours: 2));
  }

  Map<String, dynamic>? getContractStatistics() {
    return get<Map<String, dynamic>>('contract_statistics');
  }

  // ===== MÉTODOS PARA CACHE DE IMAGENS =====

  // Cache de imagens de perfil - TTL: 24 horas
  void putProfileImage(String userId, String imageUrl) {
    put('profile_image_$userId', imageUrl, ttl: const Duration(hours: 24));
  }

  String? getProfileImage(String userId) {
    return get<String>('profile_image_$userId');
  }

  // Cache de imagens gerais - TTL: 12 horas
  void putImage(String key, String imageUrl) {
    put('image_$key', imageUrl, ttl: const Duration(hours: 12));
  }

  String? getImage(String key) {
    return get<String>('image_$key');
  }

  // ===== MÉTODOS PARA DADOS DE FORMULÁRIOS =====

  // Dados de formulários - TTL: 1 hora (para não perder dados em caso de erro)
  void putFormData(String formKey, Map<String, dynamic> formData) {
    put('form_data_$formKey', formData, ttl: const Duration(hours: 1));
  }

  Map<String, dynamic>? getFormData(String formKey) {
    return get<Map<String, dynamic>>('form_data_$formKey');
  }

  void removeFormData(String formKey) {
    remove('form_data_$formKey');
  }

  // ===== MÉTODOS PARA DADOS DE SINCRONIZAÇÃO =====

  // Última sincronização - TTL: 1 hora
  void putLastSync(String dataType, DateTime lastSync) {
    put('last_sync_$dataType', lastSync.toIso8601String(),
        ttl: const Duration(hours: 1));
  }

  DateTime? getLastSync(String dataType) {
    final syncString = get<String>('last_sync_$dataType');
    if (syncString != null) {
      return DateTime.tryParse(syncString);
    }
    return null;
  }

  // ===== MÉTODOS DE LIMPEZA ESPECÍFICOS =====

  void clearStudentData() {
    remove('online_colleagues');
    remove('time_logs_history');
    remove('active_contracts');
  }

  void clearSupervisorData() {
    remove('supervised_students');
    remove('pending_time_logs');
    remove('contract_statistics');
  }

  void clearImageCache() {
    final keysToRemove = <String>[];
    for (final key in _cache.keys) {
      if (key.startsWith('image_') || key.startsWith('profile_image_')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  void clearFormData() {
    final keysToRemove = <String>[];
    for (final key in _cache.keys) {
      if (key.startsWith('form_data_')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  // ===== MÉTODOS DE ESTATÍSTICAS =====

  int getCacheSize() {
    return _cache.length;
  }

  List<String> getCacheKeys() {
    return _cache.keys.toList();
  }

  bool isExpired(String key) {
    final item = _cache[key];
    if (item == null) return true;
    if (item.expiry == null) return false;
    return DateTime.now().isAfter(item.expiry!);
  }
}

class CacheItem {
  final dynamic data;
  final DateTime? expiry;

  CacheItem({required this.data, this.expiry});
}
