import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gestao_de_estagio/domain/entities/time_log_entity.dart';
import 'package:gestao_de_estagio/domain/repositories/i_time_log_repository.dart';
import 'package:gestao_de_estagio/domain/usecases/time_log/clock_in_usecase.dart';

import 'clock_in_usecase_test.mocks.dart';

@GenerateMocks([ITimeLogRepository])
void main() {
  late ClockInUsecase usecase;
  late MockITimeLogRepository mockRepository;

  setUp(() {
    mockRepository = MockITimeLogRepository();
    usecase = ClockInUsecase(mockRepository);
  });

  final tTimeLog = TimeLogEntity(
    id: '1',
    studentId: 'student1',
    logDate: DateTime.now(),
    checkInTime: '08:00',
    createdAt: DateTime.now(),
  );

  group('ClockInUsecase', () {
    test('deve fazer clock-in com sucesso', () async {
      when(mockRepository.getActiveTimeLog('student1'))
          .thenAnswer((_) async => const Right(null));
      when(mockRepository.clockIn('student1', notes: anyNamed('notes')))
          .thenAnswer((_) async => Right(tTimeLog));

      final result = await usecase('student1', notes: 'Iniciando trabalho');

      expect(result, Right(tTimeLog));
    });

    test('deve falhar se já existe registro ativo', () async {
      when(mockRepository.getActiveTimeLog('student1'))
          .thenAnswer((_) async => Right(tTimeLog));

      final result = await usecase('student1');

      expect(result.isLeft(), true);
    });
  });
}
