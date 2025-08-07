import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimeLogDatasource {
  final SupabaseClient _supabaseClient;

  TimeLogDatasource(this._supabaseClient);

  Future<List<Map<String, dynamic>>> getAllTimeLogs() async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('*, students(*)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros de horas: $e');
    }
  }

  Future<Map<String, dynamic>?> getTimeLogById(String id) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('*, students(*)')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar registro de horas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTimeLogsByStudent(
      String studentId) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('*')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros do estudante: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTimeLogsByDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('*')
          .eq('student_id', studentId)
          .gte('log_date', startDate.toIso8601String().split('T')[0])
          .lte('log_date', endDate.toIso8601String().split('T')[0])
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros por período: $e');
    }
  }

  Future<Map<String, dynamic>?> getActiveTimeLog(String studentId) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('*')
          .eq('student_id', studentId)
          .isFilter('check_out_time', null)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar registro ativo: $e');
    }
  }

  Future<Map<String, dynamic>> createTimeLog(
      Map<String, dynamic> timeLogData) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 TimeLogDatasource: createTimeLog chamado com dados: $timeLogData');
      }
      
      final dataToInsert = Map<String, dynamic>.from(timeLogData);
      
      // Remove campos UUID se estiverem vazios ou nulos
      final uuidFields = ['id', 'supervisor_id'];
      for (final field in uuidFields) {
        if (dataToInsert[field] == null || 
            dataToInsert[field] == '' || 
            dataToInsert[field] == 'null') {
          dataToInsert.remove(field);
        }
      }
      
      // Validar campos obrigatórios
      if (dataToInsert['student_id'] == null || dataToInsert['student_id'] == '') {
        throw Exception('student_id é obrigatório');
      }
      if (dataToInsert['log_date'] == null || dataToInsert['log_date'] == '') {
        throw Exception('log_date é obrigatório');
      }
      if (dataToInsert['check_in_time'] == null || dataToInsert['check_in_time'] == '') {
        throw Exception('check_in_time é obrigatório');
      }
      
      if (kDebugMode) {
        debugPrint('🔵 TimeLogDatasource: Dados finais para inserção: $dataToInsert');
      }
      
      final response = await _supabaseClient
          .from('time_logs')
          .insert(dataToInsert)
          .select()
          .single();

      if (kDebugMode) {
        debugPrint('🔵 TimeLogDatasource: Resposta do Supabase: $response');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 TimeLogDatasource: Erro detalhado ao criar registro: $e');
      }
      throw Exception('Erro ao criar registro de horas: $e');
    }
  }



  Future<void> deleteTimeLog(String id) async {
    try {
      await _supabaseClient.from('time_logs').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir registro de horas: $e');
    }
  }

  Future<Map<String, dynamic>> clockIn(String studentId,
      {String? notes}) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 TimeLogDatasource: Iniciando clockIn para studentId: $studentId');
      }
      
      // Verificar se studentId é válido
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      
      // Verificar se já existe um registro ativo
      final activeLog = await getActiveTimeLog(studentId);
      if (activeLog != null) {
        throw Exception('Já existe um registro de entrada ativo');
      }

      final now = DateTime.now();
      final timeLogData = {
        'student_id': studentId,
        'log_date': now.toIso8601String().split('T')[0], // YYYY-MM-DD format
        'check_in_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}', // HH:MM:SS format
        'description': notes?.isNotEmpty == true ? notes : null,
        'approved': false,
      };
      
      // Remove campos nulos ou vazios
      timeLogData.removeWhere((key, value) => value == null || value == '');
      
      if (kDebugMode) {
        debugPrint('🔵 TimeLogDatasource: Dados para inserção: $timeLogData');
      }

      final result = await createTimeLog(timeLogData);
      if (kDebugMode) {
        debugPrint('🔵 TimeLogDatasource: Registro criado com sucesso: ${result['id']}');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 TimeLogDatasource: Erro ao registrar entrada: $e');
      }
      throw Exception('Erro ao registrar entrada: $e');
    }
  }

  Future<Map<String, dynamic>> clockOut(String studentId,
      {String? notes}) async {
    try {
      // Verificar se studentId é válido
      if (studentId.isEmpty) {
        throw Exception('ID do estudante não pode estar vazio');
      }
      
      // Buscar registro ativo
      final activeLog = await getActiveTimeLog(studentId);
      if (activeLog == null) {
        throw Exception('Nenhum registro de entrada ativo encontrado');
      }

      final now = DateTime.now();
      final checkInTime = activeLog['check_in_time'] as String;
      
      // Parse do horário de entrada
      final checkInParts = checkInTime.split(':');
      final logDate = DateTime.parse(activeLog['log_date']);
      final checkInDateTime = DateTime(
        logDate.year, logDate.month, logDate.day,
        int.parse(checkInParts[0]), 
        int.parse(checkInParts[1]),
        checkInParts.length > 2 ? int.parse(checkInParts[2]) : 0
      );
      
      // Calcular duração
      final duration = now.difference(checkInDateTime);
      final hoursLogged = (duration.inMinutes / 60.0);
      
      final updateData = {
        'check_out_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
        'hours_logged': double.parse(hoursLogged.toStringAsFixed(2)), // Arredondar para 2 casas decimais
        'description': notes?.isNotEmpty == true ? notes : activeLog['description'],
      };
      
      // Remove campos nulos
      updateData.removeWhere((key, value) => value == null);

      return await updateTimeLogData(activeLog['id'], updateData);
    } catch (e) {
      throw Exception('Erro ao registrar saída: $e');
    }
  }

  /// Método para compatibilidade com repositório
  Future<Duration> getTotalHoursByPeriod(
    String studentId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await getTotalHoursByStudent(studentId, start, end);
    final hours = result['total_hours'] as double;
    return Duration(minutes: (hours * 60).round());
  }

  /// Obtém registros pendentes de aprovação
  Future<List<Map<String, dynamic>>> getPendingTimeLogs(String supervisorId) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('''
            *,
            students!inner(*)
          ''')
          .eq('students.supervisor_id', supervisorId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros pendentes: $e');
    }
  }

  /// Atualiza registro com motivo de rejeição
  Future<Map<String, dynamic>> updateTimeLog(
    String id, 
    Map<String, dynamic> timeLogData, {
    String? rejectionReason,
  }) async {
    if (rejectionReason != null) {
      timeLogData['rejection_reason'] = rejectionReason;
    }
    return await updateTimeLogData(id, timeLogData);
  }

  Future<Map<String, dynamic>> updateTimeLogData(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar registro: $e');
    }
  }

  Future<Map<String, dynamic>> getTotalHoursByStudent(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response =
          await _supabaseClient.rpc('calculate_total_hours', params: {
        'student_id_param': studentId,
        'start_date_param': startDate.toIso8601String(),
        'end_date_param': endDate.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      // Fallback para cálculo manual se a função RPC não existir
      final timeLogs =
          await getTimeLogsByDateRange(studentId, startDate, endDate);

      double totalHours = 0;
      int completedLogs = 0;

      for (final log in timeLogs) {
        if (log['check_out_time'] != null) {
          final logDate = DateTime.parse(log['log_date']);
          final checkInTime = log['check_in_time'] as String;
          final checkOutTime = log['check_out_time'] as String;

          final checkInDateTime = DateTime.parse(
              '${logDate.toIso8601String().split('T')[0]}T$checkInTime');
          final checkOutDateTime = DateTime.parse(
              '${logDate.toIso8601String().split('T')[0]}T$checkOutTime');

          final duration = checkOutDateTime.difference(checkInDateTime);
          totalHours += duration.inMinutes / 60.0;
          completedLogs++;
        }
      }

      return {
        'total_hours': totalHours,
        'completed_logs': completedLogs,
        'total_logs': timeLogs.length,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getTimeLogsBySupervisor(
      String supervisorId) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('''
            *,
            students!inner(
              *,
              users(*)
            )
          ''')
          .eq('students.supervisor_id', supervisorId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros do supervisor: $e');
    }
  }
}
