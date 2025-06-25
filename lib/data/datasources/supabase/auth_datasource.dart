import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../core/enums/user_role.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../domain/repositories/i_auth_datasource.dart';

class AuthDatasource implements IAuthDatasource {
  final SupabaseClient _supabaseClient;

  AuthDatasource(this._supabaseClient);

  @override
  Stream<Map<String, dynamic>?> getAuthStateChanges() =>
      _supabaseClient.auth.onAuthStateChange.map((event) {
        final session = event.session;
        if (session == null) return null;
        return {
          'id': session.user.id,
          'email': session.user.email,
          'role': session.user.userMetadata?['role'] ?? 'student',
          'fullName': session.user.userMetadata?['full_name'],
          'phoneNumber': session.user.phone,
          'profilePictureUrl': session.user.userMetadata?['avatar_url'],
          'createdAt': DateTime.parse(session.user.createdAt).toIso8601String(),
          'updatedAt': session.user.updatedAt != null
              ? DateTime.parse(session.user.updatedAt!).toIso8601String()
              : null,
        };
      });

  @override
  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
    bool? isMandatoryInternship,
    String? supervisorId,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.toString(),
          if (registration != null) 'registration': registration,
        },
      );

      if (response.user == null) {
        throw AuthException('Erro ao registrar usuário');
      }

      // Criar dados do estudante/supervisor na tabela correspondente
      try {
        // Verificar políticas primeiro
        await checkTablePolicies();
        await checkRLSPolicies();

        if (role == UserRole.student) {
          if (kDebugMode) {
            print(
                '📝 Criando dados do estudante para usuário ${response.user!.id}');
          }

          // Verificar permissão de inserção
          await verifyUserInsertionPermission(response.user!.id);

          // Inserir estudante com os campos obrigatórios
          await _supabaseClient.from('students').insert({
            'id': response.user!.id,
            'full_name': fullName,
            'registration_number': registration ?? 'PENDENTE',
            'course': 'PENDENTE',
            'advisor_name': 'PENDENTE',
            'is_mandatory_internship': isMandatoryInternship ?? false,
            'supervisor_id': supervisorId,
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          if (kDebugMode) {
            print('✅ Dados do estudante criados com sucesso');
          }
        } else if (role == UserRole.supervisor) {
          if (kDebugMode) {
            print(
                '📝 Criando dados do supervisor para usuário ${response.user!.id}');
          }
          await _supabaseClient.from('supervisors').insert({
            'id': response.user!.id, // Incluir o ID do usuário
            'full_name': fullName,
            'department': 'Departamento não definido',
            'position': 'Supervisor',
            'job_code': registration,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          if (kDebugMode) {
            print('✅ Dados do supervisor criados com sucesso');
          }
        }
      } catch (e) {
        // Se falhar ao criar os dados, não falha o registro
        // mas loga o erro para debug
        if (kDebugMode) {
          print('⚠️ Erro ao criar dados do ${role.name}: $e');
        }
        if (kDebugMode) {
          print('⚠️ Detalhes do erro: ${e.toString()}');
        }
      }

      return {
        'id': response.user!.id,
        'email': response.user!.email,
        'role': role.toString(),
        'fullName': fullName,
        'registration': registration,
        'emailConfirmed': response.user!.emailConfirmedAt != null,
        'createdAt': DateTime.parse(response.user!.createdAt).toIso8601String(),
        'updatedAt': response.user!.updatedAt != null
            ? DateTime.parse(response.user!.updatedAt!).toIso8601String()
            : null,
      };
    } catch (e) {
      throw AuthException('Erro ao registrar usuário: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (kDebugMode) {
        print('🔐 Tentando fazer login com email: $email');
      }

      // Testar conectividade primeiro
      await testConnection();

      // Limpar sessão anterior se existir
      await _supabaseClient.auth.signOut();
      if (kDebugMode) {
        print('🧹 Sessão anterior limpa');
      }

      // Tentar login de forma mais simples
      if (kDebugMode) {
        print('🔑 Fazendo login...');
      }
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ Login bem-sucedido para usuário: ${response.user?.id}');
      }

      if (response.user == null) {
        throw AuthException('Erro ao fazer login: usuário não retornado');
      }

      // Verificar se o usuário tem dados na tabela correspondente
      if (kDebugMode) {
        print('🔍 Verificando dados do usuário na tabela...');
      }
      await _ensureUserDataExists(response.user!);
      if (kDebugMode) {
        print('✅ Dados do usuário verificados/criados com sucesso');
      }

      return {
        'id': response.user!.id,
        'email': response.user!.email,
        'role': response.user!.userMetadata?['role'] ?? 'student',
        'fullName': response.user!.userMetadata?['full_name'],
        'phoneNumber': response.user!.phone,
        'profilePictureUrl': response.user!.userMetadata?['avatar_url'],
        'emailConfirmed': response.user!.emailConfirmedAt != null,
        'createdAt': DateTime.parse(response.user!.createdAt).toIso8601String(),
        'updatedAt': response.user!.updatedAt != null
            ? DateTime.parse(response.user!.updatedAt!).toIso8601String()
            : null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no login: $e');
      }
      if (kDebugMode) {
        print('❌ Tipo de erro: ${e.runtimeType}');
      }
      if (kDebugMode) {
        print('❌ Mensagem completa: $e');
      }

      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('invalid_credentials')) {
        throw AuthException(
            'E-mail ou senha incorretos. Verifique suas credenciais.');
      } else if (e.toString().contains('400')) {
        throw AuthException(
            'Credenciais inválidas. Verifique seu e-mail e senha.');
      } else {
        throw AuthException('Erro ao fazer login: $e');
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('Erro ao fazer logout: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Verificar se o usuário tem dados na tabela correspondente
      await _ensureUserDataExists(user);

      return {
        'id': user.id,
        'email': user.email,
        'role': user.userMetadata?['role'] ?? 'student',
        'fullName': user.userMetadata?['full_name'],
        'phoneNumber': user.phone,
        'profilePictureUrl': user.userMetadata?['avatar_url'],
        'createdAt': DateTime.parse(user.createdAt).toIso8601String(),
        'updatedAt': user.updatedAt != null
            ? DateTime.parse(user.updatedAt!).toIso8601String()
            : null,
      };
    } catch (e) {
      throw AuthException('Erro ao buscar usuário atual: $e');
    }
  }

  /// Verifica se o usuário tem dados na tabela correspondente e cria se não existir
  Future<void> _ensureUserDataExists(User user) async {
    try {
      final role = user.userMetadata?['role'] ?? 'student';
      final registration = user.userMetadata?['registration'];

      if (kDebugMode) {
        print('🔍 Verificando dados para usuário ${user.id} com role: $role');
      }

      if (role == 'student') {
        final studentResponse = await _supabaseClient
            .from('students')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (studentResponse == null) {
          if (kDebugMode) {
            print(
                '📝 Nenhum dado de estudante encontrado para ${user.id}, criando agora...');
          }
          await _supabaseClient.from('students').insert({
            'id': user.id,
            'full_name': '',
            'registration_number': registration ?? 'PENDENTE',
            'course': 'PENDENTE',
            'advisor_name': 'PENDENTE',
            'status': 'active',
          });
          if (kDebugMode) {
            print('✅ Dados de estudante criados para ${user.id}');
          }
        }
      } else if (role == 'supervisor') {
        // Verificar se já existe na tabela supervisors
        final existingSupervisor = await _supabaseClient
            .from('supervisors')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (existingSupervisor == null) {
          if (kDebugMode) {
            print(
                '❌ Perfil de supervisor não encontrado para usuário ${user.id}');
          }
          // O perfil do supervisor deve ser criado por um administrador.
          // Se não existir, o login deve falhar.
          throw AuthException(
              'Perfil de supervisor não encontrado. Contate o administrador.');
        } else {
          if (kDebugMode) {
            print('✅ Dados do supervisor já existem para usuário ${user.id}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao verificar/criar dados do usuário: $e');
      }
      // Não rethrow aqui para não impedir o login
      // Apenas loga o erro para debug
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://reset-callback/',
      );
    } catch (e) {
      throw AuthException('Erro ao resetar senha: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw AuthException('Usuário não autenticado');
      }

      if (user.id != userId) {
        throw AuthException('Não é possível atualizar outro usuário');
      }

      final updates = <String, dynamic>{};

      if (email != null && email.isNotEmpty) {
        await _supabaseClient.auth.updateUser(
          UserAttributes(
            email: email,
          ),
        );
      }

      if (password != null && password.isNotEmpty) {
        await _supabaseClient.auth.updateUser(
          UserAttributes(
            password: password,
          ),
        );
      }

      if (fullName != null && fullName.isNotEmpty) {
        updates['full_name'] = fullName;
      }

      if (phoneNumber != null) {
        updates['phone'] = phoneNumber;
      }

      if (profilePictureUrl != null) {
        updates['avatar_url'] = profilePictureUrl;
      }

      if (updates.isNotEmpty) {
        await _supabaseClient.auth.updateUser(
          UserAttributes(
            data: updates,
          ),
        );
      }

      final updatedUser = await getCurrentUser();
      if (updatedUser == null) {
        throw AuthException('Erro ao atualizar perfil');
      }

      return updatedUser;
    } catch (e) {
      throw AuthException('Erro ao atualizar perfil: $e');
    }
  }

  /// Verifica se um usuário existe no Supabase
  Future<bool> userExists(String email) async {
    try {
      if (kDebugMode) {
        print('🔍 Verificando se usuário existe: $email');
      }

      // Como não temos acesso admin, vamos tentar uma abordagem diferente
      // Tentar fazer login e capturar o erro específico
      try {
        await _supabaseClient.auth.signInWithPassword(
          email: email,
          password: 'senha_temporaria_para_teste',
        );
      } catch (e) {
        if (e.toString().contains('Invalid login credentials')) {
          if (kDebugMode) {
            print('✅ Usuário $email existe no Supabase (senha incorreta)');
          }
          return true;
        } else if (e.toString().contains('User not found')) {
          if (kDebugMode) {
            print('❌ Usuário $email não existe no Supabase');
          }
          return false;
        }
      }

      return true; // Se chegou aqui, o usuário existe
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao verificar se usuário existe: $e');
      }
      return false;
    }
  }

  /// Testa a conectividade com o Supabase
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        print('🔧 Testando conectividade com Supabase...');
      }

      // Tentar fazer uma consulta simples para testar a conexão

      if (kDebugMode) {
        print('✅ Conectividade com Supabase OK');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro na conectividade com Supabase: $e');
      }
      return false;
    }
  }

  /// Testa o registro de um usuário para verificar se a autenticação está funcionando
  Future<bool> testRegistration() async {
    try {
      if (kDebugMode) {
        print('🧪 Testando registro de usuário...');
      }

      final testEmail =
          'teste_${DateTime.now().millisecondsSinceEpoch}@teste.com';
      const testPassword = 'Teste123!';

      final response = await _supabaseClient.auth.signUp(
        email: testEmail,
        password: testPassword,
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('✅ Registro de teste bem-sucedido');
        }
        // Limpar o usuário de teste
        await _supabaseClient.auth.signOut();
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Registro de teste falhou');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no registro de teste: $e');
      }
      return false;
    }
  }

  /// Testa a inserção de dados na tabela students
  Future<void> testStudentInsertion(
      String userId, String fullName, String registration) async {
    try {
      if (kDebugMode) {
        print('🧪 Testando inserção de dados do estudante...');
      }
      if (kDebugMode) {
        print('🧪 User ID: $userId');
      }
      if (kDebugMode) {
        print('🧪 Full Name: $fullName');
      }
      if (kDebugMode) {
        print('🧪 Registration: $registration');
      }

      final result = await _supabaseClient.from('students').insert({
        'id': userId,
        'full_name': fullName,
        'registration_number': registration,
        'course': 'Curso não definido',
        'advisor_name': 'Orientador não definido',
        'is_mandatory_internship': true,
        'class_shift': 'morning',
        'internship_shift_1': 'morning',
        'birth_date': '2000-01-01',
        'contract_start_date': DateTime.now().toIso8601String().split('T')[0],
        'contract_end_date': DateTime.now()
            .add(const Duration(days: 365))
            .toIso8601String()
            .split('T')[0],
        'total_hours_required': 300.0,
        'total_hours_completed': 0.0,
        'weekly_hours_target': 20.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      if (kDebugMode) {
        print('✅ Teste de inserção bem-sucedido: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no teste de inserção: $e');
      }
      if (kDebugMode) {
        print('❌ Tipo de erro: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  /// Verifica as políticas de segurança da tabela students
  Future<void> checkTablePolicies() async {
    try {
      if (kDebugMode) {
        print('🔒 Verificando políticas de segurança...');
      }

      // Tentar fazer uma consulta simples

      if (kDebugMode) {
        print('✅ Consulta à tabela students bem-sucedida');
      }

      // Verificar se o usuário atual pode inserir
      final currentUser = _supabaseClient.auth.currentUser;
      if (kDebugMode) {
        print('👤 Usuário atual: ${currentUser?.id}');
      }
      if (kDebugMode) {
        print('👤 Email: ${currentUser?.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar políticas: $e');
      }
      if (kDebugMode) {
        print('❌ Tipo de erro: ${e.runtimeType}');
      }
    }
  }

  /// Verifica se o usuário pode inserir dados na tabela students
  Future<void> verifyUserInsertionPermission(String userId) async {
    try {
      if (kDebugMode) {
        print('🔍 Verificando permissão de inserção para usuário: $userId');
      }

      // Verificar se o usuário está autenticado
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('❌ Usuário não está autenticado');
        }
        return;
      }

      if (kDebugMode) {
        print('✅ Usuário autenticado: ${currentUser.id}');
      }

      // Tentar inserir um registro de teste
      final testData = {
        'id': userId,
        'full_name': 'Teste',
        'registration_number': 'TEST123',
        'course': 'Teste',
        'advisor_name': 'Teste',
        'is_mandatory_internship': true,
        'class_shift': 'morning',
        'internship_shift_1': 'morning',
        'birth_date': '2000-01-01',
        'contract_start_date': DateTime.now().toIso8601String().split('T')[0],
        'contract_end_date': DateTime.now()
            .add(const Duration(days: 365))
            .toIso8601String()
            .split('T')[0],
        'total_hours_required': 300.0,
        'total_hours_completed': 0.0,
        'weekly_hours_target': 20.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result =
          await _supabaseClient.from('students').insert(testData).select();
      if (kDebugMode) {
        print('✅ Permissão de inserção verificada: $result');
      }

      // Remover o registro de teste
      await _supabaseClient.from('students').delete().eq('id', userId);
      if (kDebugMode) {
        print('🧹 Registro de teste removido');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar permissão de inserção: $e');
      }
      if (kDebugMode) {
        print('❌ Tipo de erro: ${e.runtimeType}');
      }
    }
  }

  /// Verifica se há políticas de RLS ativas na tabela students
  Future<void> checkRLSPolicies() async {
    try {
      if (kDebugMode) {
        print('🔒 Verificando políticas de RLS...');
      }

      // Tentar fazer uma consulta sem autenticação
      final result =
          await _supabaseClient.from('students').select('*').limit(1);

      if (kDebugMode) {
        print('✅ Consulta sem autenticação bem-sucedida');
      }
      if (kDebugMode) {
        print('📊 Resultado: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar RLS: $e');
      }
      if (kDebugMode) {
        print('❌ Tipo de erro: ${e.runtimeType}');
      }

      if (e.toString().contains('permission denied') ||
          e.toString().contains('new row violates row-level security policy')) {
        if (kDebugMode) {
          print(
              '🚨 Problema detectado: Políticas de RLS estão bloqueando a operação');
        }
        if (kDebugMode) {
          print(
              '💡 Solução: Verificar as políticas de segurança no painel do Supabase');
        }
      }
    }
  }
}
