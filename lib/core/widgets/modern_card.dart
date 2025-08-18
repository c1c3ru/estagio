import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool useGlassmorphism;
  final Color? backgroundColor;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.useGlassmorphism = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: t.spaceLg, vertical: t.spaceSm),
      decoration: BoxDecoration(
        color: useGlassmorphism 
            ? Colors.white.withOpacity(0.1)
            : backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: useGlassmorphism 
            ? Border.all(color: Colors.white.withOpacity(0.2))
            : Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          if (!useGlassmorphism)
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t.radiusLg),
        child: useGlassmorphism
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: padding ?? EdgeInsets.all(t.spaceLg),
                  child: child,
                ),
              )
            : Container(
                padding: padding ?? EdgeInsets.all(t.spaceLg),
                child: child,
              ),
      ),
    );
  }
}