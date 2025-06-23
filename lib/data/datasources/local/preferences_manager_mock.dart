import 'preferences_manager.dart';
import 'in_memory_preferences_manager.dart';

class PreferencesManagerMock extends PreferencesManager {
  final InMemoryPreferencesManager _inMemory;

  PreferencesManagerMock(this._inMemory) : super(null);

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _inMemory.saveUserData(userData);
  }

  @override
  Map<String, dynamic>? getUserData() {
    return _inMemory.getUserData();
  }

  @override
  Future<void> removeUserData() async {
    await _inMemory.removeUserData();
  }

  @override
  Future<void> saveUserToken(String token) async {
    await _inMemory.saveUserToken(token);
  }

  @override
  String? getUserToken() {
    return _inMemory.getUserToken();
  }

  @override
  Future<void> removeUserToken() async {
    await _inMemory.removeUserToken();
  }

  // Métodos extras do PreferencesManager
  @override
  Future<void> saveThemeMode(String themeMode) async {
    // Não persiste tema no mock
  }

  @override
  String? getThemeMode() {
    return null;
  }

  @override
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    // Não persiste no mock
  }

  @override
  bool isFirstLaunch() {
    return true;
  }

  @override
  Future<void> clearAll() async {
    await _inMemory.removeUserData();
    await _inMemory.removeUserToken();
  }
}
