import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gestao_de_estagio/core/animations.dart';

/// Widget reutilizável para exibir a animação de página não encontrada (404).
class NotFound404Animation extends StatelessWidget {
  final double height;
  final bool repeat;
  final EdgeInsetsGeometry? padding;

  const NotFound404Animation({
    super.key,
    this.height = 200,
    this.repeat = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      child: Lottie.asset(
        AssetAnimations.notFound404,
        height: height,
        repeat: repeat,
      ),
    );
  }
}
