import 'package:flutter/material.dart';
import '../animations/lottie_animations.dart';

/// Dialog animado para feedback de sucesso, erro ou informação
class AnimatedFeedbackDialog extends StatelessWidget {
  final String title;
  final String message;
  final FeedbackType type;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final bool autoClose;
  final Duration autoCloseDuration;

  const AnimatedFeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onConfirm,
    this.confirmText,
    this.autoClose = false,
    this.autoCloseDuration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimation(),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!autoClose) _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    String assetPath;
    switch (type) {
      case FeedbackType.success:
        assetPath = LottieAssetPaths.success;
        break;
      case FeedbackType.error:
        assetPath = LottieAssetPaths.error;
        break;
      case FeedbackType.confetti:
        assetPath = LottieAssetPaths.confetti;
        break;
    }

    return AppLottieAnimation(
      assetPath: assetPath,
      height: 120,
      repeat: type == FeedbackType.confetti,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (onConfirm != null) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColor(context),
            ),
            child: Text(confirmText ?? 'OK'),
          ),
        ],
      ],
    );
  }

  Color _getColor(BuildContext context) {
    switch (type) {
      case FeedbackType.success:
        return Colors.green;
      case FeedbackType.error:
        return Theme.of(context).colorScheme.error;
      case FeedbackType.confetti:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// Método estático para mostrar dialog de sucesso
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String? confirmText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AnimatedFeedbackDialog(
        title: title,
        message: message,
        type: FeedbackType.success,
        onConfirm: onConfirm,
        confirmText: confirmText,
      ),
    );
  }

  /// Método estático para mostrar dialog de erro
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String? confirmText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AnimatedFeedbackDialog(
        title: title,
        message: message,
        type: FeedbackType.error,
        onConfirm: onConfirm,
        confirmText: confirmText,
      ),
    );
  }

  /// Método estático para mostrar dialog de celebração
  static Future<void> showCelebration(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String? confirmText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AnimatedFeedbackDialog(
        title: title,
        message: message,
        type: FeedbackType.confetti,
        onConfirm: onConfirm,
        confirmText: confirmText,
      ),
    );
  }
}

/// Auto-closing dialog que fecha automaticamente após um tempo
class AutoClosingFeedbackDialog extends StatefulWidget {
  final String title;
  final String message;
  final FeedbackType type;
  final Duration duration;

  const AutoClosingFeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AutoClosingFeedbackDialog> createState() => _AutoClosingFeedbackDialogState();
}

class _AutoClosingFeedbackDialogState extends State<AutoClosingFeedbackDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFeedbackDialog(
      title: widget.title,
      message: widget.message,
      type: widget.type,
      autoClose: true,
    );
  }


}

enum FeedbackType {
  success,
  error,
  confetti,
}