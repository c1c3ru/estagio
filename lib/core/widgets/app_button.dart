// lib/core/widgets/app_button.dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart'; // Para padding/borderRadius

enum AppButtonType { elevated, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minWidth;
  final double? minHeight;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.elevated,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.minWidth,
    this.minHeight = 48.0, // Altura padrão para boa tocabilidade
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;
    final theme = Theme.of(context);

    Widget child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ??
                    (type == AppButtonType.elevated
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18), // Tamanho do ícone ajustado
                const SizedBox(width: AppConstants.paddingSmall),
              ],
              Text(text),
            ],
          );

    switch (type) {
      case AppButtonType.elevated:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: theme.elevatedButtonTheme.style?.copyWith(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return (backgroundColor ?? theme.colorScheme.primary)
                      .withOpacity(0.5);
                }
                return backgroundColor ?? theme.colorScheme.primary;
              },
            ),
            foregroundColor: MaterialStateProperty.all(
                foregroundColor ?? theme.colorScheme.onPrimary),
            minimumSize:
                MaterialStateProperty.all(Size(minWidth ?? 0, minHeight ?? 48)),
          ),
          child: child,
        );
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: (isLoading || isDisabled)
                  ? (foregroundColor ?? theme.colorScheme.primary)
                      .withOpacity(0.5)
                  : (foregroundColor ?? theme.colorScheme.primary),
            ),
            minimumSize: Size(minWidth ?? 0, minHeight ?? 48),
          ).merge(theme.outlinedButtonTheme.style),
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            minimumSize: Size(minWidth ?? 0, minHeight ?? 48),
          ).merge(theme.textButtonTheme.style),
          child: child,
        );
    }
  }
}
