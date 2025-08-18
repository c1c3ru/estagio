import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_extensions.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.surface : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.primary : AppColors.white,
          elevation: isSecondary ? 0 : 2,
          side: isSecondary 
              ? const BorderSide(color: AppColors.primary)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.tokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(horizontal: context.tokens.spaceXl),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    SizedBox(width: context.tokens.spaceSm),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: isSecondary ? AppColors.primary : AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

