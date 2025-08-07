import 'package:flutter/material.dart';
import 'navigator_key.dart';
import '../constants/app_colors.dart';
// import '../constants/app_strings.dart'; // Removed: Unused import
import '../../features/shared/animations/loading_animation.dart';
import '../../features/shared/animations/lottie_animations.dart';

enum FeedbackType { success, error, warning, info }

class FeedbackService {
  static const _defaultSuccessDuration = Duration(seconds: 3);
  static const _defaultErrorDuration = Duration(seconds: 4);
  static const _defaultWarningDuration = Duration(seconds: 3);
  static const _defaultInfoDuration = Duration(seconds: 3);

  /// Exibe toast de sucesso
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      duration: duration ?? _defaultSuccessDuration,
      icon: icon ?? Icons.check_circle,
    );
  }

  /// Exibe toast de erro
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      duration: duration ?? _defaultErrorDuration,
      icon: icon ?? Icons.error,
    );
  }

  /// Exibe toast de aviso
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      duration: duration ?? _defaultWarningDuration,
      icon: icon ?? Icons.warning,
    );
  }

  /// Exibe toast de informação
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
      duration: duration ?? _defaultInfoDuration,
      icon: icon ?? Icons.info,
    );
  }

  /// Exibe toast personalizado
  static void showCustomToast(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Duration? duration,
    IconData? icon,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: backgroundColor,
      duration: duration ?? _defaultInfoDuration,
      icon: icon,
      textColor: textColor,
      onTap: onTap,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Duration duration,
    IconData? icon,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor ?? Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      );
  }

  /// Exibe diálogo de loading simples
  static Future<void> showLoading(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => const LoadingAnimation(), // Added const
    );
  }

  /// Esconde diálogo de loading
  static void hideLoading(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Exibe overlay de loading sobre a tela atual
  static OverlayEntry showLoadingOverlay(
    BuildContext context, {
    String? message,
    Color? backgroundColor,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: backgroundColor ?? Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
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
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    return overlayEntry;
  }

  /// Exibe diálogo de confirmação
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDangerous ? AppColors.error : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDangerous ? AppColors.error : null,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ??
                  (isDangerous ? AppColors.error : AppColors.primary),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe diálogo de erro com opção de retry
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String retryText = 'Tentar novamente',
    String closeText = 'Fechar',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLottieAnimation(
              assetPath: LottieAssetPaths.errorCross,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              closeText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                retryText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Exibe diálogo de sucesso
  static Future<void> showSuccessDialog(
    BuildContext context, {
    String title = 'Sucesso!',
    String? message,
    String closeText = 'OK',
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLottieAnimation(
              assetPath: LottieAssetPaths.successCheck,
              height: 120,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              closeText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe diálogo de progresso
  static Future<void> showProgressDialog(
    BuildContext context, {
    required String title,
    double? progress,
    String? message,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ProgressDialog(
        // Added const
        title: title,
        progress: progress,
        message: message,
      ),
    );
  }

  /// Wrapper para executar operação com feedback visual automático
  static Future<T> executeWithFeedback<T>(
    BuildContext context, {
    required Future<T> Function() operation,
    String? loadingMessage,
    String? successMessage,
    String Function(dynamic error)? errorMessageBuilder,
    bool showSuccessToast = true,
    bool showErrorDialog = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    // Captura referências antes do await para evitar uso de context após operações assíncronas
    
    final messenger = ScaffoldMessenger.of(context);

    if (loadingMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(loadingMessage)),
      );
    }

    try {
      final result = await operation();
      // Fecha loading
      navigatorKey.currentState?.pop();
      if (showSuccessToast && successMessage != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
      onSuccess?.call();
      return result;
    } catch (error) {
      navigatorKey.currentState?.pop();
      final errorMessage = errorMessageBuilder?.call(error) ??
          'Ocorreu um erro inesperado. Tente novamente.';
      if (showErrorDialog) {
        messenger.showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      onError?.call();
      rethrow;
    }
  }

  /// Wrapper para executar operação com retry automático
  static Future<T> executeWithRetry<T>(
    BuildContext context, {
    required Future<T> Function() operation,
    int maxRetries = 3,
    String? loadingMessage,
    String? successMessage,
    String Function(dynamic error, int attempt)? errorMessageBuilder,
  }) async {
    
    final messenger = ScaffoldMessenger.of(context);
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final result = await FeedbackService.executeWithFeedback<T>(
          navigatorKey.currentContext!,
          operation: operation,
          loadingMessage: loadingMessage,
          successMessage: successMessage,
          showErrorDialog: false,
        );
        return result;
      } catch (error) {
        attempt++;
        final errorMessage = errorMessageBuilder?.call(error, attempt) ??
            'Operação falhou após $maxRetries tentativas.';
        if (attempt >= maxRetries) {
          messenger.showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          throw Exception(errorMessage);
        } else {
          // Mostra erro e pergunta se deseja tentar novamente
          final retry = await showDialog<bool>(
            context: navigatorKey.currentContext!, 
            builder: (dialogContext) => AlertDialog(
              title: const Text('Erro na operação'),
              content: Text(
                  'Tentativa $attempt de $maxRetries falhou. Tentar novamente?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
          if (retry != true) {
            throw Exception(errorMessage);
          }
        }
      }
    }
    throw Exception('Operação falhou após $maxRetries tentativas');
  }


  // Previne instanciação da classe
  FeedbackService._();
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
              'Fechar'), // Antes usava AppStrings.close, agora valor fixo
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            child: const Text(
                'Tentar novamente'), // Antes usava AppStrings.tryAgain, agora valor fixo
          ),
      ],
    );
  }
}

class ProgressDialog extends StatelessWidget {
  final String title;
  final double? progress;
  final String? message;

  const ProgressDialog({
    super.key,
    required this.title,
    this.progress,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            Column(
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text('${(progress! * 100).toInt()}%'),
              ],
            )
          else
            const LoadingAnimation(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
