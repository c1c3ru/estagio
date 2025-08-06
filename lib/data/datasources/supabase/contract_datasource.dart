import 'package:gestao_de_estagio/core/enums/contract_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContractDatasource {
  final SupabaseClient _supabaseClient;

  ContractDatasource(this._supabaseClient);

  Future<List<Map<String, dynamic>>> getAllContracts(
      {ContractStatus? status, String? studentId, String? supervisorId}) async {
    try {
      final response = await _supabaseClient.from('contracts').select('''
            *,
            students(*),
            supervisors(*)
          ''').order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar contratos: $e');
    }
  }

  Future<Map<String, dynamic>?> getContractById(String id) async {
    try {
      final response = await _supabaseClient.from('contracts').select('''
            *,
            students(*),
            supervisors(*)
          ''').eq('id', id).maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar contrato: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContractsByStudent(
      String studentId) async {
    try {
      final response = await _supabaseClient
          .from('contracts')
          .select('*')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar contratos do estudante: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContractsBySupervisor(
      String supervisorId) async {
    try {
      final response = await _supabaseClient
          .from('contracts')
          .select('''
            *,
            students(*)
          ''')
          .eq('supervisor_id', supervisorId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar contratos do supervisor: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getActiveContracts() async {
    try {
      final response = await _supabaseClient.from('contracts').select('''
            *,
            students(*),
            supervisors(*)
          ''').eq('status', 'active').order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar contratos ativos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContractsByStatus(String status) async {
    try {
      final response = await _supabaseClient.from('contracts').select('''
            *,
            students(*),
            supervisors(*)
          ''').eq('status', status).order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar contratos por status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getExpiringContracts(int daysAhead) async {
    try {
      final futureDate = DateTime.now().add(Duration(days: daysAhead));

      final response = await _supabaseClient
          .from('contracts')
          .select('''
            *,
            students(*),
            supervisors(*)
          ''')
          .eq('status', 'active')
          .lte('end_date', futureDate.toIso8601String())
          .order('end_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar contratos próximos do vencimento: $e');
    }
  }

  Future<Map<String, dynamic>> createContract(
      Map<String, dynamic> contractData) async {
    try {
      final dataToInsert = Map<String, dynamic>.from(contractData);
      
      // Remove o ID se estiver vazio
      if (dataToInsert['id'] == null || dataToInsert['id'] == '') {
        dataToInsert.remove('id');
      }
      
      // Validar campos obrigatórios
      if (dataToInsert['student_id'] == null || dataToInsert['student_id'] == '') {
        throw Exception('student_id é obrigatório');
      }
      
      if (dataToInsert['supervisor_id'] == null || dataToInsert['supervisor_id'] == '') {
        throw Exception('supervisor_id é obrigatório');
      }
      
      // Verificar se já existe contrato ativo para o estudante
      final activeContract = await getActiveContractByStudent(dataToInsert['student_id']);
      if (activeContract != null) {
        throw Exception('Estudante já possui um contrato ativo. Finalize o contrato atual antes de criar um novo.');
      }
      
      // Garantir valores corretos para status e contract_type
      if (dataToInsert['status'] == 'ativo') {
        dataToInsert['status'] = 'active';
      }
      if (dataToInsert['contract_type'] == null) {
        dataToInsert['contract_type'] = 'Obrigatório';
      }
      
      final response = await _supabaseClient
          .from('contracts')
          .insert(dataToInsert)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao criar contrato: $e');
    }
  }

  Future<Map<String, dynamic>> updateContract(
      String id, Map<String, dynamic> contractData) async {
    try {
      final response = await _supabaseClient
          .from('contracts')
          .update(contractData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar contrato: $e');
    }
  }

  Future<void> deleteContract(String id) async {
    try {
      await _supabaseClient.from('contracts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir contrato: $e');
    }
  }

  Future<Map<String, dynamic>> updateContractStatus(
      String id, String status) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('contracts')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar status do contrato: $e');
    }
  }

  Future<Map<String, dynamic>> activateContract(String id) async {
    return await updateContractStatus(id, 'active');
  }

  Future<Map<String, dynamic>> suspendContract(String id) async {
    return await updateContractStatus(id, 'suspended');
  }

  Future<Map<String, dynamic>> completeContract(String id) async {
    return await updateContractStatus(id, 'completed');
  }

  Future<Map<String, dynamic>> cancelContract(String id) async {
    return await updateContractStatus(id, 'cancelled');
  }

  Future<Map<String, dynamic>?> getActiveContractByStudent(
      String studentId) async {
    try {
      final response = await _supabaseClient
          .from('contracts')
          .select('*')
          .eq('student_id', studentId)
          .eq('status', 'active')
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar contrato ativo do estudante: $e');
    }
  }

  Future<Map<String, dynamic>> getContractStatistics() async {
    try {
      final response = await _supabaseClient.rpc('get_contract_statistics');

      return response as Map<String, dynamic>;
    } catch (e) {
      // Fallback para cálculo manual se a função RPC não existir
      final allContracts = await getAllContracts();

      final stats = {
        'total': allContracts.length,
        'active': allContracts.where((c) => c['status'] == 'active').length,
        'completed':
            allContracts.where((c) => c['status'] == 'completed').length,
        'suspended':
            allContracts.where((c) => c['status'] == 'suspended').length,
        'cancelled':
            allContracts.where((c) => c['status'] == 'cancelled').length,
      };

      return stats;
    }
  }

  Future<List<Map<String, dynamic>>> searchContracts({
    String? company,
    String? position,
    String? status,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
  }) async {
    try {
      var query = _supabaseClient.from('contracts').select('''
            *,
            students(*),
            supervisors(*)
          ''');

      if (company != null && company.isNotEmpty) {
        query = query.ilike('company', '%$company%');
      }

      if (position != null && position.isNotEmpty) {
        query = query.ilike('position', '%$position%');
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (startDateFrom != null) {
        query = query.gte('start_date', startDateFrom.toIso8601String());
      }

      if (startDateTo != null) {
        query = query.lte('start_date', startDateTo.toIso8601String());
      }

      if (endDateFrom != null) {
        query = query.gte('end_date', endDateFrom.toIso8601String());
      }

      if (endDateTo != null) {
        query = query.lte('end_date', endDateTo.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao pesquisar contratos: $e');
    }
  }
}
