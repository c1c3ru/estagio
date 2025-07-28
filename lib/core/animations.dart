import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AssetAnimations {
  static const String loading = 'assets/animations/Loading_animations.json';
  static const String success = 'assets/animations/success_check_animation.json';
  static const String error = 'assets/animations/error_cross_animation.json';
  static const String student = 'assets/animations/student_page_animation .json';
  static const String supervisor = 'assets/animations/supervisor_page_animation.json';
  static const String passwordReset = 'assets/animations/password_reset_animation.json';
  static const String emailConfirmation = 'assets/animations/email_confirmations_animation.json';
}

class StudentAnimation extends StatelessWidget {
  final double? width;
  final double? height;
  
  const StudentAnimation({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AssetAnimations.student,
      width: width ?? 200,
      height: height ?? 200,
    );
  }
}

class SupervisorAnimation extends StatelessWidget {
  final double? width;
  final double? height;
  
  const SupervisorAnimation({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AssetAnimations.supervisor,
      width: width ?? 200,
      height: height ?? 200,
    );
  }
}

class PasswordResetAnimation extends StatelessWidget {
  final double? width;
  final double? height;
  
  const PasswordResetAnimation({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AssetAnimations.passwordReset,
      width: width ?? 200,
      height: height ?? 200,
    );
  }
}

class EmailConfirmationAnimation extends StatelessWidget {
  final double? width;
  final double? height;
  
  const EmailConfirmationAnimation({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AssetAnimations.emailConfirmation,
      width: width ?? 200,
      height: height ?? 200,
    );
  }
}