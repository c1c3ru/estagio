import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_event.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as custom_auth;
import 'package:gestao_de_estagio/features/auth/widgets/auth_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/validators.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registrationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.student;

  // Novos campos para estágio obrigatório e supervisor
  bool? _isMandatoryInternship;
  String? _selectedSupervisorId;
  List<Map<String, dynamic>> _supervisors = [];
  bool _loadingSupervisors = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = UserRole.student;
    _fetchSupervisors();
  }

  Future<void> _fetchSupervisors() async {
    setState(() => _loadingSupervisors = true);
    try {
      final supabase = Modular.get<SupabaseClient>();
      final response = await supabase
          .from('supervisors')
          .select('id, full_name')
          .order('full_name');
      setState(() {
        _supervisors = List<Map<String, dynamic>>.from(response);
        _loadingSupervisors = false;
      });
    } catch (e) {
      setState(() => _loadingSupervisors = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar supervisores: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == UserRole.student) {
        if (_isMandatoryInternship == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Informe se o estágio é obrigatório.')),
          );
          return;
        }
        if (_selectedSupervisorId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecione um supervisor.')),
          );
          return;
        }
      }
      Modular.get<AuthBloc>().add(
        RegisterRequested(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          registration: _selectedRole == UserRole.student
              ? _registrationController.text.trim()
              : null,
          isMandatoryInternship:
              _selectedRole == UserRole.student ? _isMandatoryInternship : null,
          supervisorId:
              _selectedRole == UserRole.student ? _selectedSupervisorId : null,
        ),
      );
    }
  }

  void _onLoginPressed() {
    Modular.to.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, custom_auth.AuthState>(
        listener: (context, state) {
          if (state is custom_auth.AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is custom_auth.AuthEmailConfirmationRequired) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
            // Navegar para a página de confirmação de email
            Modular.to
                .pushNamed('/auth/email-confirmation', arguments: state.email);
          } else if (state is custom_auth.AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cadastro realizado com sucesso!')),
            );
            Modular.to.navigate('/');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cadastro de Estudante/Bolsista/Estagiário',
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha os dados para se cadastrar como estudante, bolsista ou estagiário',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AuthTextField(
                        controller: _nameController,
                        label: 'Nome Completo',
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppStrings.fieldRequired;
                          }
                          if (value!.length < 2) {
                            return 'Nome deve ter pelo menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 20),
                      // Matrícula de estudante/bolsista/estagiário
                      AuthTextField(
                        controller: _registrationController,
                        label: 'Matrícula do estudante/bolsista/estagiário',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.studentRegistration,
                      ),
                      const SizedBox(height: 20),
                      // Estágio obrigatório
                      SwitchListTile(
                        title: const Text('Estágio obrigatório?'),
                        value: _isMandatoryInternship ?? false,
                        onChanged: (value) {
                          setState(() => _isMandatoryInternship = value);
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 20),
                      // Seleção de supervisor
                      _loadingSupervisors
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: _selectedSupervisorId,
                              decoration: const InputDecoration(
                                labelText: 'Supervisor do Estágio',
                                prefixIcon:
                                    Icon(Icons.supervisor_account_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: _supervisors
                                  .map((supervisor) => DropdownMenuItem(
                                        value: supervisor['id'] as String,
                                        child: Text(
                                            supervisor['full_name'] as String),
                                      ))
                                  .toList(),
                              onChanged: (id) {
                                setState(() => _selectedSupervisorId = id);
                              },
                            ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) =>
                            Validators.password(value, minLength: 6),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) => Validators.confirmPassword(
                            _passwordController.text, value),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botão de cadastro
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: state is custom_auth.AuthLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Cadastrar',
                                  style: TextStyle(fontSize: 17)),
                          onPressed: state is custom_auth.AuthLoading
                              ? null
                              : _onRegisterPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _onLoginPressed,
                        child: const Text('Já tem uma conta? Entrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
