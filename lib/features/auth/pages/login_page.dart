import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = Modular.get<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (state is AuthFailure) {
            FeedbackService.showError(context, state.message);
          } else if (state is AuthSuccess) {
            FeedbackService.showSuccess(context, AppStrings.loginSuccess);
            // Navegar para a página apropriada baseado no papel do usuário
            switch (state.user.role) {
              case UserRole.student:
                Modular.to.navigate('/student/');
                break;
              case UserRole.supervisor:
                Modular.to.navigate('/supervisor/');
                break;
              default:
                FeedbackService.showError(
                    context, 'Papel de usuário não suportado');
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: LoadingIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 64),
                  Image.asset(
                    'assets/images/estagio.png',
                    height: 120,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bem-vindo ao Sistema de Estágio',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faça login para continuar',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  const LoginForm(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Modular.to.pushNamed('/auth/forgot-password'),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Modular.to.pushNamed('/auth/register'),
                        child: const Text(AppStrings.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
