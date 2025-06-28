import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesManager {
  final SharedPreferences? _prefs;

  PreferencesManager(this._prefs);

  // User Token
  Future<void> saveUserToken(String token) async {
    if (_prefs != null) {
      await _prefs!.setString('user_token', token);
    }
  }

  String? getUserToken() {
    return _prefs?.getString('user_token');
  }

  Future<void> removeUserToken() async {
    await _prefs?.remove('user_token');
  }

  // User Data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (_prefs != null) {
      await _prefs!.setString('user_data', jsonEncode(userData));
    }
  }

  Map<String, dynamic>? getUserData() {
    if (_prefs == null) return null;
    final userDataString = _prefs!.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs?.remove('user_data');
  }

  // Theme
  Future<void> saveThemeMode(String themeMode) async {
    if (_prefs != null) {
      await _prefs!.setString('theme_mode', themeMode);
    }
  }

  String? getThemeMode() {
    return _prefs?.getString('theme_mode');
  }

  // First Launch
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    if (_prefs != null) {
      await _prefs!.setBool('is_first_launch', isFirstLaunch);
    }
  }

  bool isFirstLaunch() {
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  // Lista de colegas online
  Future<void> saveOnlineColleagues(
      List<Map<String, dynamic>> colleagues) async {
    if (_prefs != null) {
      await _prefs!.setString('online_colleagues', jsonEncode(colleagues));
    }
  }

  List<Map<String, dynamic>>? getOnlineColleagues() {
    if (_prefs == null) return null;
    final colleaguesString = _prefs!.getString('online_colleagues');
    if (colleaguesString != null) {
      final List<dynamic> decoded = jsonDecode(colleaguesString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Histórico de time logs
  Future<void> saveTimeLogsHistory(List<Map<String, dynamic>> timeLogs) async {
    if (_prefs != null) {
      await _prefs!.setString('time_logs_history', jsonEncode(timeLogs));
    }
  }

  List<Map<String, dynamic>>? getTimeLogsHistory() {
    if (_prefs == null) return null;
    final timeLogsString = _prefs!.getString('time_logs_history');
    if (timeLogsString != null) {
      final List<dynamic> decoded = jsonDecode(timeLogsString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Contratos ativos
  Future<void> saveActiveContracts(List<Map<String, dynamic>> contracts) async {
    if (_prefs != null) {
      await _prefs!.setString('active_contracts', jsonEncode(contracts));
    }
  }

  List<Map<String, dynamic>>? getActiveContracts() {
    if (_prefs == null) return null;
    final contractsString = _prefs!.getString('active_contracts');
    if (contractsString != null) {
      final List<dynamic> decoded = jsonDecode(contractsString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Lista de estudantes supervisionados
  Future<void> saveSupervisedStudents(
      List<Map<String, dynamic>> students) async {
    if (_prefs != null) {
      await _prefs!.setString('supervised_students', jsonEncode(students));
    }
  }

  List<Map<String, dynamic>>? getSupervisedStudents() {
    if (_prefs == null) return null;
    final studentsString = _prefs!.getString('supervised_students');
    if (studentsString != null) {
      final List<dynamic> decoded = jsonDecode(studentsString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Time logs pendentes de aprovação
  Future<void> savePendingTimeLogs(List<Map<String, dynamic>> timeLogs) async {
    if (_prefs != null) {
      await _prefs!.setString('pending_time_logs', jsonEncode(timeLogs));
    }
  }

  List<Map<String, dynamic>>? getPendingTimeLogs() {
    if (_prefs == null) return null;
    final timeLogsString = _prefs!.getString('pending_time_logs');
    if (timeLogsString != null) {
      final List<dynamic> decoded = jsonDecode(timeLogsString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Estatísticas de contratos
  Future<void> saveContractStatistics(Map<String, dynamic> statistics) async {
    if (_prefs != null) {
      await _prefs!.setString('contract_statistics', jsonEncode(statistics));
    }
  }

  Map<String, dynamic>? getContractStatistics() {
    if (_prefs == null) return null;
    final statisticsString = _prefs!.getString('contract_statistics');
    if (statisticsString != null) {
      return jsonDecode(statisticsString) as Map<String, dynamic>;
    }
    return null;
  }

  // Configurações de notificações do usuário
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    if (_prefs != null) {
      await _prefs!.setString('notification_settings', jsonEncode(settings));
    }
  }

  Map<String, dynamic>? getNotificationSettings() {
    if (_prefs == null) return null;
    final settingsString = _prefs!.getString('notification_settings');
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return null;
  }

  // Configurações de sincronização
  Future<void> saveSyncSettings(Map<String, dynamic> settings) async {
    if (_prefs != null) {
      await _prefs!.setString('sync_settings', jsonEncode(settings));
    }
  }

  Map<String, dynamic>? getSyncSettings() {
    if (_prefs == null) return null;
    final settingsString = _prefs!.getString('sync_settings');
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return null;
  }

  // Dados de formulários (para não perder dados em caso de erro)
  Future<void> saveFormData(
      String formKey, Map<String, dynamic> formData) async {
    if (_prefs != null) {
      await _prefs!.setString('form_data_$formKey', jsonEncode(formData));
    }
  }

  Map<String, dynamic>? getFormData(String formKey) {
    if (_prefs == null) return null;
    final formDataString = _prefs!.getString('form_data_$formKey');
    if (formDataString != null) {
      return jsonDecode(formDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeFormData(String formKey) async {
    await _prefs?.remove('form_data_$formKey');
  }

  // Limpar dados específicos por categoria
  Future<void> clearStudentData() async {
    await _prefs?.remove('online_colleagues');
    await _prefs?.remove('time_logs_history');
    await _prefs?.remove('active_contracts');
  }

  Future<void> clearSupervisorData() async {
    await _prefs?.remove('supervised_students');
    await _prefs?.remove('pending_time_logs');
    await _prefs?.remove('contract_statistics');
  }

  Future<void> clearFormData() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('form_data_')) {
        await _prefs?.remove(key);
      }
    }
  }

  // Clear All
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
