import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart' as custom_auth;
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    if (_selectedRole == UserRole.student) {
      _fetchSupervisors();
    }
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
                        'Criar Conta',
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha os dados para se cadastrar',
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
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppStrings.fieldRequired;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Usuário',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: UserRole.values.map((role) {
                                return RadioListTile<UserRole>(
                                  title: Text(role.displayName),
                                  value: role,
                                  groupValue: _selectedRole,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _registrationController,
                        label: _selectedRole == UserRole.supervisor
                            ? 'Matrícula SIAPE'
                            : 'Matrícula de Aluno',
                        hint: _selectedRole == UserRole.supervisor
                            ? 'Digite sua matrícula SIAPE (6 dígitos)'
                            : 'Digite sua matrícula (12 dígitos)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.badge_outlined,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            _selectedRole == UserRole.supervisor ? 6 : 12,
                          ),
                        ],
                        validator: (value) {
                          if (_selectedRole == UserRole.supervisor) {
                            return Validators.siapeRegistration(value);
                          } else {
                            return Validators.studentRegistration(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppStrings.fieldRequired;
                          }
                          if (value!.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppStrings.fieldRequired;
                          }
                          if (value != _passwordController.text) {
                            return AppStrings.passwordsDontMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedRole == UserRole.student) ...[
                        // Campo Estágio obrigatório
                        Row(
                          children: [
                            const Text('Estágio obrigatório?'),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                value: _isMandatoryInternship,
                                items: const [
                                  DropdownMenuItem(
                                      value: true, child: Text('Sim')),
                                  DropdownMenuItem(
                                      value: false, child: Text('Não')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _isMandatoryInternship = v),
                                decoration: const InputDecoration(
                                  labelText: 'Estágio obrigatório?',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null ? 'Obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Campo Supervisor
                        _loadingSupervisors
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                value: _selectedSupervisorId,
                                items: _supervisors
                                    .map((s) => DropdownMenuItem<String>(
                                          value: s['id'] as String?,
                                          child:
                                              Text(s['full_name'] ?? s['id']),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedSupervisorId = v),
                                decoration: const InputDecoration(
                                  labelText: 'Supervisor',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null ? 'Obrigatório' : null,
                              ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, custom_auth.AuthState>(
                        builder: (context, state) {
                          return AuthButton(
                            text: AppStrings.register,
                            onPressed: state is custom_auth.AuthLoading
                                ? null
                                : _onRegisterPressed,
                            isLoading: state is custom_auth.AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _onLoginPressed,
                        child: RichText(
                          text: const TextSpan(
                            style: AppTextStyles.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Já tem uma conta? ',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                              TextSpan(
                                text: AppStrings.login,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
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
