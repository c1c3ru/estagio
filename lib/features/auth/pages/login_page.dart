import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/feedback_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../../shared/animations/lottie_animations.dart';
import '../../shared/animations/loading_animation.dart';

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
    if (kDebugMode) {
      print('🟡 LoginPage: initState chamado');
    }
    _authBloc = Modular.get<AuthBloc>();
    if (kDebugMode) {
      print('🟡 LoginPage: AuthBloc obtido com sucesso');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🟡 LoginPage: build chamado');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (kDebugMode) {
            print('🟡 LoginPage: Estado recebido: ${state.runtimeType}');
          }
          if (state is AuthFailure) {
            FeedbackService.showError(context, state.message);
          } else if (state is AuthEmailConfirmationRequired) {
            FeedbackService.showWarning(context, state.message);
            Modular.to
                .pushNamed('/auth/email-confirmation', arguments: state.email);
          } else if (state is AuthProfileIncomplete) {
            // Redirecionar para a tela de completar perfil conforme o papel do usuário
            if (state.user.role == UserRole.student) {
              Modular.to.navigate('/student/profile');
            } else if (state.user.role == UserRole.supervisor) {
              Modular.to.navigate('/supervisor/profile');
            }
          } else if (state is AuthSuccess) {
            FeedbackService.showSuccess(context, AppStrings.loginSuccess);
            // Navegar para a página apropriada baseado no papel do usuário
            switch (state.user.role) {
              case UserRole.student:
                Modular.to.navigate('/student');
                break;
              case UserRole.supervisor:
                Modular.to.navigate('/supervisor');
                break;
            }
          }
        },
        builder: (context, state) {
          if (kDebugMode) {
            print(
                '🟡 LoginPage: Builder chamado, estado: ${state.runtimeType}');
          }

          if (state is AuthLoading) {
            return const Center(child: LoadingAnimation());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 64),
                  const AppLottieAnimation(
                    assetPath: 'assets/animations/intership_animations.json',
                    height: 180,
                    frameRate: FrameRate(30),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () =>
                            Modular.to.pushNamed('/auth/register-type'),
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
