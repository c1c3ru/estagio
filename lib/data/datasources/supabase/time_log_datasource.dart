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
      final response = await _supabaseClient
          .from('time_logs')
          .insert(timeLogData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao criar registro de horas: $e');
    }
  }

  Future<Map<String, dynamic>> updateTimeLog(
      String id, Map<String, dynamic> timeLogData) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .update(timeLogData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar registro de horas: $e');
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
      // Verificar se já existe um registro ativo
      final activeLog = await getActiveTimeLog(studentId);
      if (activeLog != null) {
        throw Exception('Já existe um registro de entrada ativo');
      }

      final now = DateTime.now();
      final timeLogData = {
        'student_id': studentId,
        'log_date': now.toIso8601String().split('T')[0],
        'check_in_time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00',
        'description': notes,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      return await createTimeLog(timeLogData);
    } catch (e) {
      throw Exception('Erro ao registrar entrada: $e');
    }
  }

  Future<Map<String, dynamic>> clockOut(String studentId,
      {String? notes}) async {
    try {
      // Buscar registro ativo
      final activeLog = await getActiveTimeLog(studentId);
      if (activeLog == null) {
        throw Exception('Nenhum registro de entrada ativo encontrado');
      }

      final now = DateTime.now();
      final updateData = {
        'check_out_time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00',
        'description': notes ?? activeLog['description'],
        'updated_at': now.toIso8601String(),
      };

      return await updateTimeLog(activeLog['id'], updateData);
    } catch (e) {
      throw Exception('Erro ao registrar saída: $e');
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
