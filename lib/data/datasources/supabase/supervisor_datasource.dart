import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/filter_students_params.dart';

class SupervisorDatasource {
  final SupabaseClient _supabaseClient;

  SupervisorDatasource(this._supabaseClient);

  Future<List<Map<String, dynamic>>> getAllSupervisors() async {
    try {
      final response = await _supabaseClient
          .from('supervisors')
          .select('*, users(*)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar supervisores: $e');
    }
  }

  Future<Map<String, dynamic>?> getSupervisorById(String id) async {
    try {
      final response = await _supabaseClient
          .from('supervisors')
          .select('*, users(*)')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar supervisor: $e');
    }
  }

  Future<Map<String, dynamic>?> getSupervisorByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        return null;
      }
      
      final response = await _supabaseClient
          .from('supervisors')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar supervisor por usuário: $e');
    }
  }

  Future<Map<String, dynamic>> createSupervisor(
      Map<String, dynamic> supervisorData) async {
    try {
      final response = await _supabaseClient
          .from('supervisors')
          .insert(supervisorData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao criar supervisor: $e');
    }
  }

  Future<Map<String, dynamic>> updateSupervisor(
      String id, Map<String, dynamic> supervisorData) async {
    try {
      final response = await _supabaseClient
          .from('supervisors')
          .update(supervisorData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar supervisor: $e');
    }
  }

  Future<void> deleteSupervisor(String id) async {
    try {
      await _supabaseClient.from('supervisors').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir supervisor: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudents({
    String? supervisorId,
    FilterStudentsParams? filters,
  }) async {
    try {
      var query = _supabaseClient
          .from('students')
          .select('*,users(email)')
          .eq('status', 'active');

      if (supervisorId != null && supervisorId.isNotEmpty) {
        query = query.eq('supervisor_id', supervisorId);
      }

      if (filters != null) {
        if (filters.searchTerm != null && filters.searchTerm!.isNotEmpty) {
          query = query.ilike('full_name', '%${filters.searchTerm}%');
        }

        if (filters.status != null) {
          query = query.eq('status', filters.status.toString());
        }
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar estudantes: $e');
    }
  }

  Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    try {
      if (studentId.isEmpty) {
        return null;
      }
      
      final response = await _supabaseClient
          .from('students')
          .select('*, users(email)')
          .eq('id', studentId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar estudante: $e');
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

  Future<void> deleteStudent(String studentId) async {
    try {
      await _supabaseClient.from('students').delete().eq('id', studentId);
    } catch (e) {
      throw Exception('Erro ao excluir estudante: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllTimeLogs({
    String? studentId,
    bool pendingOnly = false,
  }) async {
    try {
      var query = _supabaseClient.from('time_logs').select('*, students(*)');

      if (studentId != null) {
        query = query.eq('student_id', studentId);
      }

      if (pendingOnly) {
        query = query.eq('approved', false);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros de tempo: $e');
    }
  }

  Future<Map<String, dynamic>> approveOrRejectTimeLog({
    required String timeLogId,
    required bool approved,
    required String supervisorId,
    String? rejectionReason,
  }) async {
    try {
      final data = {
        'approved': approved,
        'supervisor_id': supervisorId,
        'rejection_reason': rejectionReason,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('time_logs')
          .update(data)
          .eq('id', timeLogId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao aprovar/rejeitar registro de tempo: $e');
    }
  }
}
