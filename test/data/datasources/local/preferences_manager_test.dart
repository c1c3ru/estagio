import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestao_de_estagio/data/datasources/local/preferences_manager.dart';

import 'preferences_manager_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late PreferencesManager preferencesManager;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    preferencesManager = PreferencesManager(mockSharedPreferences);
  });

  group('PreferencesManager - Persistência', () {
    test('deve salvar e recuperar token', () async {
      when(mockSharedPreferences.setString('user_token', 'test_token'))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getString('user_token'))
          .thenReturn('test_token');

      await preferencesManager.saveUserToken('test_token');
      final token = preferencesManager.getUserToken();

      expect(token, 'test_token');
    });

    test('deve salvar dados de formulário', () async {
      final formData = {'email': 'test@test.com'};
      when(mockSharedPreferences.setString('form_data_login', any))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getString('form_data_login'))
          .thenReturn('{"email":"test@test.com"}');

      await preferencesManager.saveFormData('login', formData);
      final retrievedData = preferencesManager.getFormData('login');

      expect(retrievedData, formData);
    });

    test('deve limpar todos os dados', () async {
      when(mockSharedPreferences.clear()).thenAnswer((_) async => true);

      await preferencesManager.clearAll();

      verify(mockSharedPreferences.clear());
    });
  });
}