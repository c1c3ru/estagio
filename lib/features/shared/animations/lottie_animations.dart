// lib/features/shared/animations/lottie_animations.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Adicione lottie: ^versao ao seu pubspec.yaml

class LottieAssetPaths {
  // Defina os caminhos para os seus ficheiros Lottie JSON aqui
  // Certifique-se que estes ficheiros existem na sua pasta assets/animations/
  static const String emptyState =
      'assets/animations/empty_state_animation.json';
  static const String loadingDots =
      'assets/animations/loading_dots_animation.json';
  static const String successCheck =
      'assets/animations/success_check_animation.json';
  static const String errorCross =
      'assets/animations/error_cross_animation.json';
  static const String confetti = 'assets/animations/confetti_animation.json';
  static const String pageNotFound =
      'assets/animations/404_not_found_animation.json';
  static const String timeAnimation = 'assets/animations/time_nimation.json';
  static const String passwordReset =
      'assets/animations/Formulario_animation.json';
  static const String studentAnimation =
      'assets/animations/student_page_animation .json';
  static const String supervisorAnimation =
      'assets/animations/supervisor_page_animation.json';
  static const String emailConfirmation =
      'assets/animations/email_confirmations_animation.json';
  static const String internshipAnimation =
      'assets/animations/intership_animations.json';
  static const String loadingAnimation =
      'assets/animations/Loading_animations.json';
  // Adicione mais conforme necessário

  // Previne instanciação
  LottieAssetPaths._();
}

// Um widget reutilizável para exibir uma animação Lottie
class AppLottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool animate;
  final LottieDelegates? delegates;
  final Animation<double>? controller; // Para controlo externo da animação
  final FrameRate? frameRate; // Otimização de performance

  const AppLottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
    this.delegates,
    this.controller,
    this.frameRate,
  });

  @override
  Widget build(BuildContext context) {
    // Tenta carregar a animação. Se o asset não existir, Lottie mostrará um erro no console.
    // Você pode adicionar uma verificação de existência do asset se necessário,
    // mas geralmente o Lottie lida bem com isso mostrando um placeholder.
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
        delegates: delegates,
        controller: controller,
        // Otimizações de performance
        frameRate: frameRate,
        // Opcional: um errorBuilder para lidar com falhas ao carregar o Lottie
        errorBuilder: (context, error, stackTrace) {
          // logger.e('Erro ao carregar animação Lottie: $assetPath', error: error, stackTrace: stackTrace);
          return Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).disabledColor,
              size: width ??
                  height ??
                  50, // Usa a dimensão fornecida ou um padrão
            ),
          );
        },
      ),
    );
  }
}

// Exemplos de widgets pré-configurados
class EmptyStateAnimation extends StatelessWidget {
  final double size;
  const EmptyStateAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return AppLottieAnimation(
      assetPath: LottieAssetPaths.emptyState,
      width: size,
      height: size,
      repeat: false, // Geralmente animações de estado vazio não repetem
    );
  }
}

class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onLoaded; // Callback quando a animação é carregada
  final VoidCallback?
      onComplete; // Callback quando a animação termina (se não repetir)

  const SuccessAnimation(
      {super.key, this.size = 100, this.onLoaded, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      // Usando Lottie.asset diretamente para aceder ao controller
      LottieAssetPaths.successCheck,
      width: size,
      height: size,
      repeat: false,
      frameRate: const FrameRate(30), // Otimização de performance
      onLoaded: (composition) {
        onLoaded?.call();
      },
      controller: useAnimationController(
          onComplete: onComplete,
          context: context), // Exemplo de uso de um controller
    );
  }
}

// Widgets específicos para o app
class StudentAnimation extends StatelessWidget {
  final double size;
  final bool repeat;

  const StudentAnimation({super.key, this.size = 150, this.repeat = true});

  @override
  Widget build(BuildContext context) {
    return AppLottieAnimation(
      assetPath: LottieAssetPaths.studentAnimation,
      width: size,
      height: size,
      repeat: repeat,
    );
  }
}

class SupervisorAnimation extends StatelessWidget {
  final double size;
  final bool repeat;

  const SupervisorAnimation({super.key, this.size = 150, this.repeat = true});

  @override
  Widget build(BuildContext context) {
    return AppLottieAnimation(
      assetPath: LottieAssetPaths.supervisorAnimation,
      width: size,
      height: size,
      repeat: repeat,
    );
  }
}

class PasswordResetAnimation extends StatelessWidget {
  final double size;
  final bool repeat;

  const PasswordResetAnimation(
      {super.key, this.size = 200, this.repeat = true});

  @override
  Widget build(BuildContext context) {
    return AppLottieAnimation(
      assetPath: LottieAssetPaths.passwordReset,
      width: size,
      height: size,
      repeat: repeat,
    );
  }
}

class EmailConfirmationAnimation extends StatelessWidget {
  final double size;
  final bool repeat;

  const EmailConfirmationAnimation(
      {super.key, this.size = 120, this.repeat = true});

  @override
  Widget build(BuildContext context) {
    return AppLottieAnimation(
      assetPath: LottieAssetPaths.emailConfirmation,
      width: size,
      height: size,
      repeat: repeat,
    );
  }
}

// Hook simples para criar e descartar um AnimationController (exemplo, pode ser melhorado)
// Para uso mais robusto, considere hooks_riverpod ou flutter_hooks
AnimationController useAnimationController({
  required BuildContext context, // Necessário para vsync
  Duration? duration,
  VoidCallback? onComplete,
}) {
  // Este é um exemplo muito simplificado e não segue as melhores práticas para hooks.
  // Numa aplicação real, use um pacote de hooks ou um StatefulWidget para gerir o controller.
  // Apenas para ilustração de como passar um controller.

  final tickerProvider = NavigatorState();
  final controller = AnimationController(
    vsync: tickerProvider,
    duration: duration,
  );
  if (onComplete != null) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });
  }
  // controller.dispose() precisaria ser chamado.
  return controller;
}
