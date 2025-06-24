// lib/features/shared/animations/loading_animation.dart
import 'package:flutter/material.dart';
import 'lottie_animations.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final String? message;
  const LoadingAnimation({super.key, this.size = 120, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLottieAnimation(
            assetPath: LottieAssetPaths.loadingDots,
            width: size,
            height: size,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: LoadingAnimation(
              message: message,
            ),
          ),
      ],
    );
  }
}
