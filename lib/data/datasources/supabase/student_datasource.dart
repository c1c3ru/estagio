import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDatasource {
  final SupabaseClient _supabaseClient;

  StudentDatasource(this._supabaseClient);

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*, users(*)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar estudantes: $e');
    }
  }

  Future<Map<String, dynamic>?> getStudentById(String id) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*, users(*)')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar estudante: $e');
    }
  }

  Future<Map<String, dynamic>?> getStudentByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        return null;
      }
      
      final response = await _supabaseClient
          .from('students')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar estudante por usuário: $e');
    }
  }

  Future<Map<String, dynamic>> createStudent(
      Map<String, dynamic> studentData) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .insert(studentData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao criar estudante: $e');
    }
  }

  Future<Map<String, dynamic>> updateStudent(
      String id, Map<String, dynamic> studentData) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .update(studentData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar estudante: $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _supabaseClient.from('students').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir estudante: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsBySupervisor(
      String supervisorId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*, users(*)')
          .eq('supervisor_id', supervisorId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar estudantes do supervisor: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentDashboard(String studentId) async {
    try {
      if (kDebugMode) {
        print(
            '🟢 StudentDatasource: Buscando dashboard para studentId: $studentId');
      }

      // Buscar dados do estudante pelo ID
      final studentResponse = await _supabaseClient
          .from('students')
          .select('*, users(*)')
          .eq('id', studentId)
          .maybeSingle();

      if (studentResponse == null) {
        if (kDebugMode) {
          print(
              '⚠️ Nenhum dado de estudante encontrado para $studentId - usuário precisa completar cadastro');
        }
        return {
          'student': null,
          'timeStats': {
            'hoursThisWeek': 0.0,
            'hoursThisMonth': 0.0,
            'recentLogs': [],
            'activeTimeLog': null,
          },
          'contracts': [],
        };
      }

      if (kDebugMode) {
        print(
            '🟢 StudentDatasource: Dados do estudante encontrados: ${studentResponse['full_name']}');
      }

      // Buscar logs de tempo do estudante (últimos 30 dias)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final timeLogsResponse = await _supabaseClient
          .from('time_logs')
          .select('*')
          .eq('student_id', studentResponse['id'])
          .gte('log_date', thirtyDaysAgo.toIso8601String().split('T')[0])
          .order('log_date', ascending: false);

      if (kDebugMode) {
        print(
            '🟢 StudentDatasource: ${timeLogsResponse.length} logs de tempo encontrados');
      }

      // Buscar contratos ativos do estudante
      final contractsResponse = await _supabaseClient
          .from('contracts')
          .select('*')
          .eq('student_id', studentResponse['id'])
          .eq('status', 'active')
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print(
            '🟢 StudentDatasource: ${contractsResponse.length} contratos ativos encontrados');
      }

      // Calcular estatísticas de tempo
      double totalHoursThisWeek = 0.0;
      double totalHoursThisMonth = 0.0;
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      for (final log in timeLogsResponse) {
        final logDate = DateTime.parse(log['log_date']);
        final hours = log['hours_logged'] ?? 0.0;

        if (logDate.isAfter(monthStart)) {
          totalHoursThisMonth += hours;
        }
        if (logDate.isAfter(weekStart)) {
          totalHoursThisWeek += hours;
        }
      }

      // Buscar log ativo (sem check_out_time)
      Map<String, dynamic>? activeTimeLog;
      try {
        activeTimeLog = timeLogsResponse.firstWhere(
          (log) => log['check_out_time'] == null,
        );
        if (kDebugMode) {
          print('🟢 StudentDatasource: Log ativo encontrado');
        }
      } catch (e) {
        // Nenhum log ativo encontrado
        activeTimeLog = null;
        if (kDebugMode) {
          print('🟢 StudentDatasource: Nenhum log ativo encontrado');
        }
      }

      final dashboardData = {
        'student': studentResponse,
        'timeStats': {
          'hoursThisWeek': totalHoursThisWeek,
          'hoursThisMonth': totalHoursThisMonth,
          'recentLogs': timeLogsResponse.take(10).toList(), // Últimos 10 logs
          'activeTimeLog': activeTimeLog,
        },
        'contracts': contractsResponse,
      };

      if (kDebugMode) {
        print('🟢 StudentDatasource: Dashboard montado com sucesso');
      }
      return dashboardData;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 StudentDatasource: Erro ao buscar dashboard: $e');
      }
      return {
        'student': null,
        'timeStats': {
          'hoursThisWeek': 0.0,
          'hoursThisMonth': 0.0,
          'recentLogs': [],
          'activeTimeLog': null,
        },
        'contracts': [],
      };
    }
  }


}
