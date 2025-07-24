import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
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
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
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
      builder: (context) => LoadingAnimation(message: message),
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
            Icon(
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
            Icon(
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
    // Mostra loading
    if (loadingMessage != null) {
      showLoading(context, message: loadingMessage);
    }

    try {
      // Executa operação
      final result = await operation();

      // Esconde loading
      if (loadingMessage != null) {
        hideLoading(context);
      }

      // Mostra sucesso
      if (showSuccessToast && successMessage != null) {
        showSuccess(context, successMessage);
      }

      onSuccess?.call();
      return result;
    } catch (error) {
      // Esconde loading
      if (loadingMessage != null) {
        hideLoading(context);
      }

      // Mostra erro
      final errorMessage = errorMessageBuilder?.call(error) ?? 
          'Ocorreu um erro inesperado. Tente novamente.';

      if (showErrorDialog) {
        showErrorDialog(
          context,
          title: 'Erro',
          message: errorMessage,
        );
      } else {
        showError(context, errorMessage);
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
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        return await executeWithFeedback<T>(
          context,
          operation: operation,
          loadingMessage: loadingMessage,
          successMessage: successMessage,
          showErrorDialog: false,
        );
      } catch (error) {
        attempt++;
        
        if (attempt >= maxRetries) {
          // Última tentativa falhou
          final errorMessage = errorMessageBuilder?.call(error, attempt) ??
              'Operação falhou após $maxRetries tentativas.';
          
          showErrorDialog(
            context,
            title: 'Erro',
            message: errorMessage,
          );
          rethrow;
        } else {
          // Mostra erro e pergunta se quer tentar novamente
          final retry = await showConfirmationDialog(
            context,
            title: 'Erro na operação',
            message: 'Tentativa ${attempt} de $maxRetries falhou. Tentar novamente?',
            confirmText: 'Tentar novamente',
            cancelText: 'Cancelar',
            icon: Icons.refresh,
          );
          
          if (retry != true) {
            rethrow;
          }
        }
      }
    }
    
    throw Exception('Operação falhou após $maxRetries tentativas');
  }

  // Previne instanciação
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
          child: const Text(AppStrings.close),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            child: const Text(AppStrings.tryAgain),
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
