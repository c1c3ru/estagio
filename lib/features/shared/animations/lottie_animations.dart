import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Caminhos para animações Lottie
class LottieAssetPaths {
  static const String loading = 'assets/animations/Loading_animations.json';
  static const String success = 'assets/animations/success_check_animation.json';
  static const String successCheck = 'assets/animations/success_check_animation.json';
  static const String error = 'assets/animations/error_cross_animation.json';
  static const String errorCross = 'assets/animations/error_cross_animation.json';
  static const String empty = 'assets/animations/empty_state_animation.json';
  static const String notFound = 'assets/animations/404_not_found_animation.json';
  static const String confetti = 'assets/animations/confetti_animation.json';
  static const String emailConfirmation = 'assets/animations/email_confirmations_animation.json';
  static const String passwordReset = 'assets/animations/password_reset_animation.json';
  static const String student = 'assets/animations/student_page_animation .json';
  static const String supervisor = 'assets/animations/supervisor_page_animation.json';
  static const String internship = 'assets/animations/intership_animations.json';
  static const String form = 'assets/animations/Formulario_animation.json';
  static const String time = 'assets/animations/time_nimation.json';
  static const String loadingDots = 'assets/animations/loading_dots_animation.json';
}

/// Widget para exibir animações Lottie
class AppLottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool repeat;
  final bool reverse;
  final AnimationController? controller;

  const AppLottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.repeat = true,
    this.reverse = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.animation,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}

/// Widget de loading com animação Lottie
class LottieLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LottieLoadingWidget({
    super.key,
    this.message,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLottieAnimation(
          assetPath: LottieAssetPaths.loading,
          width: size,
          height: size,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Widget de sucesso com animação Lottie
class LottieSuccessWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LottieSuccessWidget({
    super.key,
    this.message,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLottieAnimation(
          assetPath: LottieAssetPaths.success,
          width: size,
          height: size,
          repeat: false,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Widget de erro com animação Lottie
class LottieErrorWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LottieErrorWidget({
    super.key,
    this.message,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLottieAnimation(
          assetPath: LottieAssetPaths.error,
          width: size,
          height: size,
          repeat: false,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Widget de estado vazio com animação Lottie
class LottieEmptyStateWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LottieEmptyStateWidget({
    super.key,
    this.message,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLottieAnimation(
          assetPath: LottieAssetPaths.empty,
          width: size,
          height: size,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}