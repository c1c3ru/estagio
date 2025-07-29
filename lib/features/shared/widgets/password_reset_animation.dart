import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PasswordResetAnimation extends StatelessWidget {
  final double size;
  final BoxFit fit;
  const PasswordResetAnimation({super.key, this.size = 120, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/password_reset_animation.json',
        fit: fit,
      ),
    );
  }
}