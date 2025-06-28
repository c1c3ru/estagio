import 'package:flutter/foundation.dart';
import 'preferences_manager.dart';
import 'cache_manager.dart';

class LocalStorageService {
  final PreferencesManager _preferencesManager;
  final CacheManager _cacheManager;

  LocalStorageService(this._preferencesManager, this._cacheManager);

  // ===== DADOS DE AUTENTICAÇÃO =====

  Future<void> saveUserToken(String token) async {
    await _preferencesManager.saveUserToken(token);
  }

  String? getUserToken() {
    return _preferencesManager.getUserToken();
  }

  Future<void> removeUserToken() async {
    await _preferencesManager.removeUserToken();
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _preferencesManager.saveUserData(userData);
  }

  Map<String, dynamic>? getUserData() {
    return _preferencesManager.getUserData();
  }

  Future<void> removeUserData() async {
    await _preferencesManager.removeUserData();
  }

  // ===== CONFIGURAÇÕES DE TEMA =====

  Future<void> saveThemeMode(String themeMode) async {
    await _preferencesManager.saveThemeMode(themeMode);
  }

  String? getThemeMode() {
    return _preferencesManager.getThemeMode();
  }

  // ===== CONFIGURAÇÕES DE NOTIFICAÇÕES =====

  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _preferencesManager.saveNotificationSettings(settings);
  }

  Map<String, dynamic>? getNotificationSettings() {
    return _preferencesManager.getNotificationSettings();
  }

  // ===== CONFIGURAÇÕES DE SINCRONIZAÇÃO =====

  Future<void> saveSyncSettings(Map<String, dynamic> settings) async {
    await _preferencesManager.saveSyncSettings(settings);
  }

  Map<String, dynamic>? getSyncSettings() {
    return _preferencesManager.getSyncSettings();
  }

  // ===== DADOS DE ESTUDANTES =====

  // Lista de colegas online - Cache + Preferences (para funcionamento offline)
  Future<void> saveOnlineColleagues(
      List<Map<String, dynamic>> colleagues) async {
    // Salvar no cache para acesso rápido
    _cacheManager.putOnlineColleagues(colleagues);
    // Salvar no preferences para funcionamento offline
    await _preferencesManager.saveOnlineColleagues(colleagues);
  }

  List<Map<String, dynamic>>? getOnlineColleagues() {
    // Tentar cache primeiro (mais rápido)
    final cached = _cacheManager.getOnlineColleagues();
    if (cached != null) {
      return cached.cast<Map<String, dynamic>>();
    }
    // Se não estiver no cache, buscar do preferences
    return _preferencesManager.getOnlineColleagues();
  }

  // Histórico de time logs - Cache + Preferences
  Future<void> saveTimeLogsHistory(List<Map<String, dynamic>> timeLogs) async {
    _cacheManager.putTimeLogsHistory(timeLogs);
    await _preferencesManager.saveTimeLogsHistory(timeLogs);
  }

  List<Map<String, dynamic>>? getTimeLogsHistory() {
    final cached = _cacheManager.getTimeLogsHistory();
    if (cached != null) {
      return cached.cast<Map<String, dynamic>>();
    }
    return _preferencesManager.getTimeLogsHistory();
  }

  // Contratos ativos - Cache + Preferences
  Future<void> saveActiveContracts(List<Map<String, dynamic>> contracts) async {
    _cacheManager.putActiveContracts(contracts);
    await _preferencesManager.saveActiveContracts(contracts);
  }

  List<Map<String, dynamic>>? getActiveContracts() {
    final cached = _cacheManager.getActiveContracts();
    if (cached != null) {
      return cached.cast<Map<String, dynamic>>();
    }
    return _preferencesManager.getActiveContracts();
  }

  // ===== DADOS DE SUPERVISORES =====

  // Lista de estudantes supervisionados - Cache + Preferences
  Future<void> saveSupervisedStudents(
      List<Map<String, dynamic>> students) async {
    _cacheManager.putSupervisedStudents(students);
    await _preferencesManager.saveSupervisedStudents(students);
  }

  List<Map<String, dynamic>>? getSupervisedStudents() {
    final cached = _cacheManager.getSupervisedStudents();
    if (cached != null) {
      return cached.cast<Map<String, dynamic>>();
    }
    return _preferencesManager.getSupervisedStudents();
  }

  // Time logs pendentes de aprovação - Cache + Preferences
  Future<void> savePendingTimeLogs(List<Map<String, dynamic>> timeLogs) async {
    _cacheManager.putPendingTimeLogs(timeLogs);
    await _preferencesManager.savePendingTimeLogs(timeLogs);
  }

  List<Map<String, dynamic>>? getPendingTimeLogs() {
    final cached = _cacheManager.getPendingTimeLogs();
    if (cached != null) {
      return cached.cast<Map<String, dynamic>>();
    }
    return _preferencesManager.getPendingTimeLogs();
  }

  // Estatísticas de contratos - Cache + Preferences
  Future<void> saveContractStatistics(Map<String, dynamic> statistics) async {
    _cacheManager.putContractStatistics(statistics);
    await _preferencesManager.saveContractStatistics(statistics);
  }

  Map<String, dynamic>? getContractStatistics() {
    final cached = _cacheManager.getContractStatistics();
    if (cached != null) {
      return cached;
    }
    return _preferencesManager.getContractStatistics();
  }

  // ===== CACHE DE IMAGENS =====

  // Cache de imagens de perfil - Apenas cache (não precisa persistir)
  void saveProfileImage(String userId, String imageUrl) {
    _cacheManager.putProfileImage(userId, imageUrl);
  }

  String? getProfileImage(String userId) {
    return _cacheManager.getProfileImage(userId);
  }

  // Cache de imagens gerais - Apenas cache
  void saveImage(String key, String imageUrl) {
    _cacheManager.putImage(key, imageUrl);
  }

  String? getImage(String key) {
    return _cacheManager.getImage(key);
  }

  // ===== DADOS DE FORMULÁRIOS =====

  // Dados de formulários - Cache + Preferences (para não perder dados)
  Future<void> saveFormData(
      String formKey, Map<String, dynamic> formData) async {
    _cacheManager.putFormData(formKey, formData);
    await _preferencesManager.saveFormData(formKey, formData);
  }

  Map<String, dynamic>? getFormData(String formKey) {
    final cached = _cacheManager.getFormData(formKey);
    if (cached != null) {
      return cached;
    }
    return _preferencesManager.getFormData(formKey);
  }

  Future<void> removeFormData(String formKey) async {
    _cacheManager.removeFormData(formKey);
    await _preferencesManager.removeFormData(formKey);
  }

  // ===== CONTROLE DE SINCRONIZAÇÃO =====

  void saveLastSync(String dataType, DateTime lastSync) {
    _cacheManager.putLastSync(dataType, lastSync);
  }

  DateTime? getLastSync(String dataType) {
    return _cacheManager.getLastSync(dataType);
  }

  // ===== MÉTODOS DE LIMPEZA =====

  Future<void> clearStudentData() async {
    _cacheManager.clearStudentData();
    await _preferencesManager.clearStudentData();
  }

  Future<void> clearSupervisorData() async {
    _cacheManager.clearSupervisorData();
    await _preferencesManager.clearSupervisorData();
  }

  void clearImageCache() {
    _cacheManager.clearImageCache();
  }

  Future<void> clearFormData() async {
    _cacheManager.clearFormData();
    await _preferencesManager.clearFormData();
  }

  Future<void> clearAll() async {
    _cacheManager.clear();
    await _preferencesManager.clearAll();
  }

  // ===== MÉTODOS DE ESTATÍSTICAS =====

  int getCacheSize() {
    return _cacheManager.getCacheSize();
  }

  List<String> getCacheKeys() {
    return _cacheManager.getCacheKeys();
  }

  void cleanExpiredCache() {
    _cacheManager.cleanExpired();
  }

  // ===== MÉTODOS DE DEBUG =====

  void logStorageInfo() {
    if (kDebugMode) {
      print('📊 LocalStorage Info:');
      print('  Cache size: ${getCacheSize()}');
      print('  Cache keys: ${getCacheKeys()}');
      print(
          '  User data: ${getUserData() != null ? 'Present' : 'Not present'}');
      print('  Theme mode: ${getThemeMode()}');
      print(
          '  Notification settings: ${getNotificationSettings() != null ? 'Present' : 'Not present'}');
    }
  }
}
