// lib/features/shared/animations/loading_animation.dart
import 'package:flutter/material.dart';
import 'lottie_animations.dart'; // Para LottieAssetPaths e AppLottieAnimation

class LottieLoadingIndicator extends StatelessWidget {
  final double size;
  final String? message; // Mensagem opcional abaixo da animação

  const LottieLoadingIndicator({
    super.key,
    this.size = 80.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLottieAnimation(
            assetPath:
                LottieAssetPaths.loadingDots, // Use o seu asset de loading
            width: size,
            height: size,
            repeat: true,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}

// Um widget de overlay de loading com animação Lottie
class LottieLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double opacity;
  final Color? backgroundColor; // Cor do overlay
  final String? loadingMessage;

  const LottieLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.opacity = 0.3,
    this.backgroundColor,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (backgroundColor ?? Colors.black).withOpacity(opacity),
              child: LottieLoadingIndicator(
                size: 100, // Tamanho maior para overlay
                message: loadingMessage,
              ),
            ),
          ),
      ],
    );
  }
}
