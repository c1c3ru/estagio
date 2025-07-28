import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmailConfirmationAnimation extends StatelessWidget {
  final double size;
  final BoxFit fit;
  const EmailConfirmationAnimation({Key? key, this.size = 120, this.fit = BoxFit.contain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/email_confirmations_animation.json',
        fit: fit,
      ),
    );
  }
}
