import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gestao_de_estagio/data/datasources/local/preferences_manager.dart';


import 'auth_state_persistence_test.mocks.dart';

@GenerateMocks([PreferencesManager])
void main() {
  late MockPreferencesManager mockPreferencesManager;

  setUp(() {
    mockPreferencesManager = MockPreferencesManager();
  });

  group('Auth State Persistence', () {
    test('deve recuperar estado de autenticação salvo', () {
      final userData = {
        'id': '1',
        'email': 'test@test.com',
        'fullName': 'Test User',
        'role': 'student',
      };
      
      when(mockPreferencesManager.getUserData()).thenReturn(userData);
      when(mockPreferencesManager.getUserToken()).thenReturn('valid_token');

      final retrievedData = mockPreferencesManager.getUserData();
      final token = mockPreferencesManager.getUserToken();

      expect(retrievedData, isNotNull);
      expect(token, 'valid_token');
      expect(retrievedData!['email'], 'test@test.com');
    });

    test('deve limpar estado ao fazer logout', () async {
      when(mockPreferencesManager.removeUserData())
          .thenAnswer((_) async => {});
      when(mockPreferencesManager.removeUserToken())
          .thenAnswer((_) async => {});

      await mockPreferencesManager.removeUserData();
      await mockPreferencesManager.removeUserToken();

      verify(mockPreferencesManager.removeUserData());
      verify(mockPreferencesManager.removeUserToken());
    });
  });
}