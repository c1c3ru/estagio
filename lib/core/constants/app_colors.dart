import 'package:flutter/material.dart';

class AppColors {
  // Cores Primárias
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFC7D2FE);
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1E1B4B);

  // Cores Secundárias
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFFA7F3D0);
  static const Color secondaryContainer = Color(0xFFECFDF5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF064E3B);

  // Cores Neutras
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  static const Color greyLight = Color(0xFFF8FAFC);
  static const Color greyDark = Color(0xFF374151);

  // Cores de Status
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFE65100);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF1976D2);

  // Cores de Fundo
  static const Color background = Color(0xFFFEFEFE);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF1F2937);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Cores de Texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFD1D5DB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFF1F2937);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFF1F2937);

  // Cores de Borda
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);
  static const Color borderFocus = Color(0xFF6366F1);
  static const Color borderError = Color(0xFFF44336);
  static const Color borderSuccess = Color(0xFF4CAF50);
  static const Color borderWarning = Color(0xFFFF9800);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineVariant = Color(0xFFF3F4F6);

  // Cores de Sombra
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color elevation1 = Color(0x0A000000);
  static const Color elevation2 = Color(0x14000000);
  static const Color elevation3 = Color(0x1F000000);

  // Cores de Status Específicas
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusInactive = Color(0xFF9CA3AF);
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF6366F1);
  static const Color statusTerminated = Color(0xFFEF4444);
  static const Color statusExpired = Color(0xFF6B7280);
  static const Color statusUnknown = Color(0xFFD1D5DB);
  static const Color statusApproved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusDraft = Color(0xFF9CA3AF);

  // Cores de Acento
  static const Color accent1 = Color(0xFFEC4899); // Rosa
  static const Color accent2 = Color(0xFF8B5CF6); // Violeta
  static const Color accent3 = Color(0xFF06B6D4); // Ciano
  static const Color accent4 = Color(0xFFF97316); // Laranja
  static const Color accent5 = Color(0xFFEAB308); // Amarelo
  static const Color accent6 = Color(0xFF84CC16); // Lima

  // Cores de Gradiente
  static const Color gradientStart = Color(0xFF6366F1);
  static const Color gradientEnd = Color(0xFF8B5CF6);
  static const Color gradientSecondaryStart = Color(0xFF10B981);
  static const Color gradientSecondaryEnd = Color(0xFF06B6D4);

  // Cores de Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayDark = Color(0xB3000000);
  static const Color scrim = Color(0x66000000);

  // Cores de Destaque
  static const Color highlight = Color(0xFFEEF2FF);
  static const Color highlightSecondary = Color(0xFFECFDF5);
  static const Color selection = Color(0x336366F1);
  static const Color focus = Color(0x1A6366F1);
  static const Color hover = Color(0x0D6366F1);
  static const Color pressed = Color(0x1F6366F1);

  // Cores de Card
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x0A000000);

  // Cores de Input
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputFocus = Color(0xFF6366F1);
  static const Color inputError = Color(0xFFF44336);
  static const Color inputDisabled = Color(0xFFF3F4F6);

  // Cores de Botão
  static const Color buttonPrimary = Color(0xFF6366F1);
  static const Color buttonSecondary = Color(0xFF10B981);
  static const Color buttonDanger = Color(0xFFEF4444);
  static const Color buttonWarning = Color(0xFFF59E0B);
  static const Color buttonInfo = Color(0xFF3B82F6);
  static const Color buttonDisabled = Color(0xFFD1D5DB);

  // Cores de Navegação
  static const Color navigationBackground = Color(0xFFFFFFFF);
  static const Color navigationSelected = Color(0xFF6366F1);
  static const Color navigationUnselected = Color(0xFF9CA3AF);
  static const Color navigationIndicator = Color(0xFFEEF2FF);

  // Cores de Divisor
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFFD1D5DB);

  // Cores de Badge
  static const Color badgeBackground = Color(0xFFEF4444);
  static const Color badgeText = Color(0xFFFFFFFF);

  // Cores de Chip
  static const Color chipBackground = Color(0xFFF3F4F6);
  static const Color chipSelected = Color(0xFFEEF2FF);
  static const Color chipText = Color(0xFF374151);
  static const Color chipSelectedText = Color(0xFF6366F1);
}
