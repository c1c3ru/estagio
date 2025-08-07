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
        'assets/animations/student_page_animation .json',
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Icon(
              Icons.school,
              size: size * 0.6,
              color: Colors.blue.shade400,
            ),
          );
        },
      ),
    );
  }
}
