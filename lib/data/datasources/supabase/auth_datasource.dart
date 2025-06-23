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
        if (role == UserRole.student) {
          await _supabaseClient.from('students').insert({
            // 'id': response.user!.id, // O ID será preenchido pelo default no DB (auth.uid())
            'full_name': fullName,
            'registration_number': registration,
            'course': 'Curso não definido',
            'advisor_name': 'Orientador não definido',
            'is_mandatory_internship': true,
            'class_shift': 'morning',
            'internship_shift_1': 'morning',
            'birth_date': '2000-01-01',
            'contract_start_date':
                DateTime.now().toIso8601String().split('T')[0],
            'contract_end_date': DateTime.now()
                .add(const Duration(days: 365))
                .toIso8601String()
                .split('T')[0],
            'total_hours_required': 300.0,
            'total_hours_completed': 0.0,
            'weekly_hours_target': 20.0,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        } else if (role == UserRole.supervisor) {
          await _supabaseClient.from('supervisors').insert({
            // 'id': response.user!.id, // O ID será preenchido pelo default no DB (auth.uid())
            'full_name': fullName,
            'department': 'Departamento não definido',
            'position': 'Supervisor',
            'job_code': registration,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        // Se falhar ao criar os dados, não falha o registro
        // mas loga o erro para debug
        print('⚠️ Erro ao criar dados do ${role.name}: $e');
      }

      return {
        'id': response.user!.id,
        'email': response.user!.email,
        'role': role.toString(),
        'fullName': fullName,
        'registration': registration,
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
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Erro ao fazer login');
      }

      // Verificar se o usuário tem dados na tabela correspondente
      await _ensureUserDataExists(response.user!);

      return {
        'id': response.user!.id,
        'email': response.user!.email,
        'role': response.user!.userMetadata?['role'] ?? 'student',
        'fullName': response.user!.userMetadata?['full_name'],
        'phoneNumber': response.user!.phone,
        'profilePictureUrl': response.user!.userMetadata?['avatar_url'],
        'createdAt': DateTime.parse(response.user!.createdAt).toIso8601String(),
        'updatedAt': response.user!.updatedAt != null
            ? DateTime.parse(response.user!.updatedAt!).toIso8601String()
            : null,
      };
    } catch (e) {
      throw AuthException('Erro ao fazer login: $e');
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
      final fullName = user.userMetadata?['full_name'] ?? '';
      final registration = user.userMetadata?['registration'];

      if (role == 'student') {
        // Verificar se já existe na tabela students
        final existingStudent = await _supabaseClient
            .from('students')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingStudent == null) {
          // Criar dados do estudante
          await _supabaseClient.from('students').insert({
            // 'id': user.id, // O ID será preenchido pelo default no DB (auth.uid())
            'full_name': fullName,
            'registration_number': registration,
            'course': 'Curso não definido',
            'advisor_name': 'Orientador não definido',
            'is_mandatory_internship': true,
            'class_shift': 'morning',
            'internship_shift_1': 'morning',
            'birth_date': '2000-01-01',
            'contract_start_date':
                DateTime.now().toIso8601String().split('T')[0],
            'contract_end_date': DateTime.now()
                .add(const Duration(days: 365))
                .toIso8601String()
                .split('T')[0],
            'total_hours_required': 300.0,
            'total_hours_completed': 0.0,
            'weekly_hours_target': 20.0,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          ('✅ Dados do estudante criados para usuário ${user.id}');
        }
      } else if (role == 'supervisor') {
        // Verificar se já existe na tabela supervisors
        final existingSupervisor = await _supabaseClient
            .from('supervisors')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (existingSupervisor == null) {
          // O perfil do supervisor deve ser criado por um administrador.
          // Se não existir, o login deve falhar.
          throw AuthException(
              'Perfil de supervisor não encontrado. Contate o administrador.');
        }
      }
    } catch (e) {
      print('⚠️ Erro ao verificar/criar dados do usuário: $e');
      rethrow;
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
}
