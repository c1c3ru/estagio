class InMemoryPreferencesManager {
  final Map<String, dynamic> _storage = {};

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    _storage['userData'] = userData;
  }

  Map<String, dynamic>? getUserData() {
    return _storage['userData'] as Map<String, dynamic>?;
  }

  Future<void> removeUserData() async {
    _storage.remove('userData');
  }

  Future<void> saveUserToken(String token) async {
    _storage['userToken'] = token;
  }

  String? getUserToken() {
    return _storage['userToken'] as String?;
  }

  Future<void> removeUserToken() async {
    _storage.remove('userToken');
  }
}
