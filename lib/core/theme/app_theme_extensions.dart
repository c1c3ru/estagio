import 'package:flutter/material.dart';

/// Tokens de design do app, expostos via ThemeExtension para evitar
/// o uso de "constantes soltas" espalhadas pelo código.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;

  final double strokeThin;
  final double strokeRegular;
  final double strokeThick;

  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;

  const AppTokens({
    this.radiusXs = 4,
    this.radiusSm = 8,
    this.radiusMd = 12,
    this.radiusLg = 16,
    this.spaceXs = 4,
    this.spaceSm = 8,
    this.spaceMd = 12,
    this.spaceLg = 16,
    this.spaceXl = 24,
    this.strokeThin = 1,
    this.strokeRegular = 2,
    this.strokeThick = 3,
    this.shadowSm = const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],
    this.shadowMd = const [
      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
    ],
  });

  @override
  AppTokens copyWith({
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? strokeThin,
    double? strokeRegular,
    double? strokeThick,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
  }) {
    return AppTokens(
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      strokeThin: strokeThin ?? this.strokeThin,
      strokeRegular: strokeRegular ?? this.strokeRegular,
      strokeThick: strokeThick ?? this.strokeThick,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      radiusXs: lerpDouble(radiusXs, other.radiusXs, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t)!,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t)!,
      strokeThin: lerpDouble(strokeThin, other.strokeThin, t)!,
      strokeRegular: lerpDouble(strokeRegular, other.strokeRegular, t)!,
      strokeThick: lerpDouble(strokeThick, other.strokeThick, t)!,
      shadowSm: BoxShadow.lerpList(shadowSm, other.shadowSm, t) ?? shadowSm,
      shadowMd: BoxShadow.lerpList(shadowMd, other.shadowMd, t) ?? shadowMd,
    );
  }

  static AppTokens standard() => const AppTokens();
}

extension BuildContextTokens on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>() ?? AppTokens.standard();
}

// Util para interpolar doubles sem importar "dart:ui" diretamente
double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0;
  b ??= 0;
  return a * (1.0 - t) + b * t;
}
