import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_estagio/data/datasources/local/cache_manager.dart';

void main() {
  late CacheManager cacheManager;

  setUp(() {
    cacheManager = CacheManager();
  });

  group('CacheManager - Estado Temporário', () {
    test('deve armazenar e recuperar dados', () {
      cacheManager.put('test_key', 'test_value');
      
      final value = cacheManager.get<String>('test_key');
      
      expect(value, 'test_value');
    });

    test('deve expirar dados após TTL', () async {
      cacheManager.put('test_key', 'test_value', 
          ttl: const Duration(milliseconds: 100));
      
      await Future.delayed(const Duration(milliseconds: 150));
      
      final value = cacheManager.get<String>('test_key');
      expect(value, isNull);
    });

    test('deve limpar cache específico de estudante', () {
      cacheManager.putOnlineColleagues(['colleague1']);
      cacheManager.putTimeLogsHistory(['log1']);
      
      cacheManager.clearStudentData();
      
      expect(cacheManager.getOnlineColleagues(), isNull);
      expect(cacheManager.getTimeLogsHistory(), isNull);
    });

    test('deve limpar dados de formulário', () {
      cacheManager.putFormData('login', {'email': 'test@test.com'});
      
      cacheManager.clearFormData();
      
      expect(cacheManager.getFormData('login'), isNull);
    });
  });
}