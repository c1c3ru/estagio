// lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = Modular.get<AuthBloc>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _authBloc.add(LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppTextField(
              controller: _emailController,
              labelText: AppStrings.email,
              hintText: 'seuemail@exemplo.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
              suffixIcon: Icons.clear,
              onSuffixIconPressed: () {
                _emailController.clear();
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              labelText: AppStrings.password,
              hintText: 'Sua senha',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => Validators.password(value, minLength: 6),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitLogin(),
              suffixIcon: Icons.clear,
              onSuffixIconPressed: () {
                _passwordController.clear();
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Modular.to.pushNamed('/auth/forgot-password');
                },
                child: const Text(AppStrings.forgotPassword),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              bloc: _authBloc,
              builder: (context, state) {
                return AppButton(
                  text: AppStrings.login,
                  isLoading: state is AuthLoading,
                  onPressed: state is AuthLoading ? null : _submitLogin,
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
