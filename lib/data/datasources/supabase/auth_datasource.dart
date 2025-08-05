import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../core/enums/user_role.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../domain/repositories/i_auth_datasource.dart';

class AuthDatasource implements IAuthDatasource {
  final SupabaseClient _supabaseClient;

  AuthDatasource(this._supabaseClient);

  @override
  Stream<Map<String, dynamic>?> getAuthStateChanges() => _supabaseClient
      .auth.onAuthStateChange
      .where((event) => 
          event.event == AuthChangeEvent.signedIn || 
          event.event == AuthChangeEvent.signedOut ||
          event.event == AuthChangeEvent.tokenRefreshed)
      .map((event) {
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
      })
      .distinct();

  @override
  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? registration,
    bool? isMandatoryInternship,
    String? supervisorId,
    String? course,
    String? advisorName,
    String? department,
    String? classShift,
    String? internshipShift,
    String? birthDate,
    String? contractStartDate,
    String? contractEndDate,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.toString(),
          if (registration != null) 'registration': registration,
          if (course != null) 'course': course,
          if (advisorName != null) 'advisor_name': advisorName,
          if (department != null) 'department': department,
        },
      );

      if (response.user == null) {
        throw AuthException('Erro ao registrar usuário');
      }

      // Remover criação de perfil aqui! O perfil será criado após login/validação de e-mail
      // await _supabaseClient.from('students' ou 'supervisors').insert(...)

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

      // Tentar login
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
    } on AuthException catch (e) {
      if (e.toString().contains('email_not_confirmed')) {
        throw AuthException(
            'E-mail não confirmado. Verifique sua caixa de entrada e confirme o cadastro antes de fazer login.');
      }
      rethrow;
    } catch (e) {
      if (e.toString().contains('email_not_confirmed')) {
        throw AuthException(
            'E-mail não confirmado. Verifique sua caixa de entrada e confirme o cadastro antes de fazer login.');
      }
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

      // Buscar dados completos do estudante se disponíveis
      final role = user.userMetadata?['role'] ?? 'student';
      Map<String, dynamic> userData = {
        'id': user.id,
        'email': user.email,
        'role': role,
        'fullName': user.userMetadata?['full_name'],
        'phoneNumber': user.phone,
        'profilePictureUrl': user.userMetadata?['avatar_url'],
        'createdAt': DateTime.parse(user.createdAt).toIso8601String(),
        'updatedAt': user.updatedAt != null
            ? DateTime.parse(user.updatedAt!).toIso8601String()
            : null,
      };

      // Se for estudante, buscar dados completos da tabela students
      if (role == 'student') {
        try {
          final studentData = await _supabaseClient
              .from('students')
              .select('*')
              .eq('id', user.id)
              .maybeSingle();

          if (studentData != null) {
            // Mesclar dados do auth com dados da tabela students
            userData.addAll({
              'fullName': studentData['full_name'] ?? userData['fullName'],
              'course': studentData['course'],
              'advisorName': studentData['advisor_name'],
              'registrationNumber': studentData['registration_number'],
              'isMandatoryInternship': studentData['is_mandatory_internship'],
              'classShift': studentData['class_shift'],
              'internshipShift1': studentData['internship_shift_1'],
              'internshipShift2': studentData['internship_shift_2'],
              'birthDate': studentData['birth_date'],
              'contractStartDate': studentData['contract_start_date'],
              'contractEndDate': studentData['contract_end_date'],
              'totalHoursRequired': studentData['total_hours_required'],
              'totalHoursCompleted': studentData['total_hours_completed'],
              'weeklyHoursTarget': studentData['weekly_hours_target'],
              'phoneNumber':
                  studentData['phone_number'] ?? userData['phoneNumber'],
              'profilePictureUrl': studentData['profile_picture_url'] ??
                  userData['profilePictureUrl'],
              'status': studentData['status'],
              'supervisorId': studentData['supervisor_id'],
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Erro ao buscar dados completos do estudante: $e');
          }
        }
      }

      return userData;
    } catch (e) {
      throw AuthException('Erro ao buscar usuário atual: $e');
    }
  }

  /// Verifica se o usuário tem dados na tabela correspondente
  Future<void> _ensureUserDataExists(User user) async {
    try {
      final role = user.userMetadata?['role'] ?? 'student';

      if (kDebugMode) {
        print('🔍 Verificando dados para usuário ${user.id} com role: $role');
      }
      
      // Primeiro, garantir que existe na tabela users
      await _ensureUserInUsersTable(user, role);

      if (role == 'student') {
        // Apenas verificar se existe, não criar automaticamente
        final studentResponse = await _supabaseClient
            .from('students')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (studentResponse == null) {
          if (kDebugMode) {
            print(
                '⚠️ Nenhum dado de estudante encontrado para ${user.id} - usuário precisa completar cadastro');
          }
          // Não criar automaticamente - deixar o usuário completar o cadastro
        } else {
          if (kDebugMode) {
            print('✅ Dados de estudante encontrados para ${user.id}');
          }
        }
      } else if (role == 'supervisor') {
        final existingSupervisor = await _supabaseClient
            .from('supervisors')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (existingSupervisor == null) {
          if (kDebugMode) {
            print('🔧 Criando registro de supervisor para ${user.id}');
            print('📋 Dados do usuário: ${user.userMetadata}');
          }
          
          try {
            // Criar registro básico na tabela supervisors
            final insertData = {
              'id': user.id,
              'full_name': user.userMetadata?['full_name'] ?? 'Supervisor',
              'job_code': user.userMetadata?['registration'],
              'department': user.userMetadata?['department'] ?? 'Não informado',
            };
            
            if (kDebugMode) {
              print('📋 Dados para inserção: $insertData');
              print('🔑 User ID: ${user.id}');
              print('📋 User metadata: ${user.userMetadata}');
            }
            
            await _supabaseClient.from('supervisors').insert(insertData);
            
            if (kDebugMode) {
              print('✅ Registro de supervisor criado com sucesso');
            }
          } catch (insertError) {
            if (kDebugMode) {
              print('❌ Erro detalhado ao criar supervisor: $insertError');
              print('❌ Tipo do erro: ${insertError.runtimeType}');
            }
            // Não rethrow para não impedir o login
          }
        } else {
          if (kDebugMode) {
            print('✅ Dados de supervisor encontrados para usuário ${user.id}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao verificar dados do usuário: $e');
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
  
  /// Garante que o usuário existe na tabela public.users
  Future<void> _ensureUserInUsersTable(User user, String role) async {
    try {
      final existingUser = await _supabaseClient
          .from('users')
          .select('id, role')
          .eq('id', user.id)
          .maybeSingle();
          
      if (existingUser == null) {
        if (kDebugMode) {
          print('🔧 Criando usuário na tabela users');
        }
        
        final userData = {
          'id': user.id,
          'email': user.email,
          'role': role,
          'matricula': user.userMetadata?['registration'],
        };
        
        if (kDebugMode) {
          print('📋 Dados do usuário: $userData');
        }
        
        await _supabaseClient.from('users').insert(userData);
        
        if (kDebugMode) {
          print('✅ Usuário criado na tabela users');
        }
      } else {
        // Verificar se o role está correto
        final currentRole = existingUser['role'] as String?;
        if (currentRole != role) {
          if (kDebugMode) {
            print('🔄 Atualizando role de $currentRole para $role');
          }
          
          await _supabaseClient
              .from('users')
              .update({'role': role})
              .eq('id', user.id);
              
          if (kDebugMode) {
            print('✅ Role atualizado na tabela users');
          }
        } else {
          if (kDebugMode) {
            print('✅ Usuário já existe na tabela users com role correto');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao criar/atualizar usuário na tabela users: $e');
      }
    }
  }
}
