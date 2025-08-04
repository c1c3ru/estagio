import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import 'package:gestao_de_estagio/data/datasources/supabase/time_log_datasource.dart';
import 'package:gestao_de_estagio/data/repositories/time_log_repository.dart';
import 'package:gestao_de_estagio/domain/entities/time_log_entity.dart';

import 'time_log_repository_test.mocks.dart';

@GenerateMocks([TimeLogDatasource])
void main() {
  late TimeLogRepository repository;
  late MockTimeLogDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockTimeLogDatasource();
    repository = TimeLogRepository(mockDatasource);
  });

  final tTimeLogData = {
    'id': '1',
    'student_id': 'student1',
    'log_date': '2024-01-01',
    'check_in_time': '08:00:00',
    'created_at': '2024-01-01T08:00:00Z',
  };

  group('TimeLogRepository', () {
    test('deve retornar time logs quando datasource retorna dados', () async {
      when(mockDatasource.getTimeLogsByStudent('student1'))
          .thenAnswer((_) async => [tTimeLogData]);

      final result = await repository.getTimeLogsByStudent('student1');

      expect(result.isRight(), true);
      verify(mockDatasource.getTimeLogsByStudent('student1'));
    });

    test('deve retornar falha quando datasource lança exceção', () async {
      when(mockDatasource.getTimeLogsByStudent('student1'))
          .thenThrow(Exception('Erro de conexão'));

      final result = await repository.getTimeLogsByStudent('student1');

      expect(result.isLeft(), true);
    });

    test('deve fazer clock-in com sucesso', () async {
      when(mockDatasource.clockIn('student1', notes: anyNamed('notes')))
          .thenAnswer((_) async => tTimeLogData);

      final result = await repository.clockIn('student1', notes: 'Teste');

      expect(result.isRight(), true);
      verify(mockDatasource.clockIn('student1', notes: 'Teste'));
    });
  });
}