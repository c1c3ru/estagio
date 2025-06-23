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

  Future<List<Map<String, dynamic>>> getTimeLogsByStudent(String studentId) async {
    try {
      final response = await _supabaseClient
          .from('time_logs')
          .select('*')
          .eq('student_id', studentId)
          .order('clock_in', ascending: false);

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
          .gte('clock_in', startDate.toIso8601String())
          .lte('clock_in', endDate.toIso8601String())
          .order('clock_in', ascending: false);

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
          .isFilter('clock_out', null)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar registro ativo: $e');
    }
  }

  Future<Map<String, dynamic>> createTimeLog(Map<String, dynamic> timeLogData) async {
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

  Future<Map<String, dynamic>> updateTimeLog(String id, Map<String, dynamic> timeLogData) async {
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
      await _supabaseClient
          .from('time_logs')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir registro de horas: $e');
    }
  }

  Future<Map<String, dynamic>> clockIn(String studentId, {String? notes}) async {
    try {
      // Verificar se já existe um registro ativo
      final activeLog = await getActiveTimeLog(studentId);
      if (activeLog != null) {
        throw Exception('Já existe um registro de entrada ativo');
      }

      final timeLogData = {
        'student_id': studentId,
        'clock_in': DateTime.now().toIso8601String(),
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await createTimeLog(timeLogData);
    } catch (e) {
      throw Exception('Erro ao registrar entrada: $e');
    }
  }

  Future<Map<String, dynamic>> clockOut(String studentId, {String? notes}) async {
    try {
      // Buscar registro ativo
      final activeLog = await getActiveTimeLog(studentId);
      if (activeLog == null) {
        throw Exception('Nenhum registro de entrada ativo encontrado');
      }

      final updateData = {
        'clock_out': DateTime.now().toIso8601String(),
        'notes': notes ?? activeLog['notes'],
        'updated_at': DateTime.now().toIso8601String(),
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
      final response = await _supabaseClient
          .rpc('calculate_total_hours', params: {
        'student_id_param': studentId,
        'start_date_param': startDate.toIso8601String(),
        'end_date_param': endDate.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      // Fallback para cálculo manual se a função RPC não existir
      final timeLogs = await getTimeLogsByDateRange(studentId, startDate, endDate);
      
      double totalHours = 0;
      int completedLogs = 0;
      
      for (final log in timeLogs) {
        if (log['clock_out'] != null) {
          final clockIn = DateTime.parse(log['clock_in']);
          final clockOut = DateTime.parse(log['clock_out']);
          final duration = clockOut.difference(clockIn);
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

  Future<List<Map<String, dynamic>>> getTimeLogsBySupervisor(String supervisorId) async {
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

