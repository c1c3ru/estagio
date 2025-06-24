// lib/features/auth/presentation/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/core/enums/user_role.dart';
import 'package:gestao_de_estagio/features/shared/animations/lottie_animations.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registrationController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = Modular.get<AuthBloc>();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      _authBloc.add(RegisterRequested(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        registration: _selectedRole == UserRole.student
            ? _registrationController.text.trim()
            : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthRegistrationSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          Modular.to.popAndPushNamed('/auth/login');
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Center(
              child: AppLottieAnimation(
                assetPath: 'assets/animations/Formulario_animation.json',
                height: 140,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _fullNameController,
              labelText: AppStrings.fullName,
              hintText: 'Seu nome completo',
              prefixIcon: Icons.person_outline,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Nome completo'),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _registrationController,
              labelText: 'Matrícula de aluno',
              hintText: 'Digite sua matrícula (12 dígitos)',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              validator: Validators.studentRegistration,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              key: const Key('email_field'),
              labelText: AppStrings.email,
              hintText: 'seuemail@exemplo.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => Validators.email(value),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              labelText: AppStrings.password,
              hintText: 'Crie uma senha',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => Validators.password(value, minLength: 6),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmPasswordController,
              labelText: AppStrings.confirmPassword,
              hintText: 'Confirme sua senha',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) =>
                  Validators.confirmPassword(_passwordController.text, value),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitRegister(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: AppStrings.selectRole,
                prefixIcon: Icon(Icons.badge_outlined,
                    color: theme.inputDecorationTheme.prefixIconColor),
                border: theme.inputDecorationTheme.border,
              ),
              items: UserRole.values
                  .where((role) => role != UserRole.supervisor)
                  .map((UserRole role) {
                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role.displayName),
                );
              }).toList(),
              onChanged: (UserRole? newValue) {
                setState(() {
                  if (newValue != null) {
                    _selectedRole = newValue;
                  }
                });
              },
              validator: (value) =>
                  value == null ? 'Selecione um perfil válido' : null,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              bloc: _authBloc,
              builder: (context, state) {
                return AppButton(
                  text: AppStrings.register,
                  isLoading: state is AuthLoading,
                  onPressed: state is AuthLoading ? null : _submitRegister,
                  minWidth: double.infinity,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
