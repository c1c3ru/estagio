import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StudentAnimation extends StatelessWidget {
  final double size;
  final BoxFit fit;
  const StudentAnimation({super.key, this.size = 120, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/student_page_animation.json',
        fit: fit,
      ),
    );
  }
}
