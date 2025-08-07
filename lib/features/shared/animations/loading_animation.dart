import 'package:flutter/material.dart';
import 'lottie_animations.dart';

/// Widget de loading animado
class LoadingAnimation extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingAnimation({
    super.key,
    this.message,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
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
        ),
      ),
    );
  }
}

/// Widget de loading simples com CircularProgressIndicator
class SimpleLoadingAnimation extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const SimpleLoadingAnimation({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color ?? Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
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

/// Widget de loading inline
class InlineLoadingAnimation extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const InlineLoadingAnimation({
    super.key,
    this.message,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color ?? Theme.of(context).colorScheme.primary,
            strokeWidth: 2,
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 12),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}