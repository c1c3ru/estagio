// lib/features/auth/pages/supervisor_register_page.dart
import 'package:flutter/material.dart';
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
import '../../../core/utils/feedback_service.dart';
import '../../shared/animations/lottie_animations.dart';

class SupervisorRegisterPage extends StatefulWidget {
  const SupervisorRegisterPage({super.key});

  @override
  State<SupervisorRegisterPage> createState() => _SupervisorRegisterPageState();
}

class _SupervisorRegisterPageState extends State<SupervisorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registrationController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registrationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      Modular.get<AuthBloc>().add(
        RegisterRequested(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: UserRole.supervisor,
          registration: _registrationController.text.trim(),
        ),
      );
    }
  }

  void _onLoginPressed() {
    Modular.to.navigate('/');
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
            FeedbackService.showError(context, state.message);
          } else if (state is custom_auth.AuthEmailConfirmationRequired) {
            FeedbackService.showWarning(context, state.message);
            Modular.to
                .pushNamed('/auth/email-confirmation', arguments: state.email);
          } else if (state is custom_auth.AuthSuccess) {
            FeedbackService.showSuccess(
                context, 'Cadastro realizado com sucesso!');
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
                      // Animação de supervisor no topo
                      const SupervisorAnimation(size: 150),
                      const SizedBox(height: 16),
                      const Text(
                        'Cadastrar Supervisor',
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha os dados para se cadastrar como supervisor',
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
                      AuthTextField(
                        controller: _registrationController,
                        label: 'Matrícula SIAPE',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.siapeRegistration,
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _departmentController,
                        label: 'Departamento',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.business_outlined,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
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
