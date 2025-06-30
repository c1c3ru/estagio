import 'package:flutter/material.dart';
import 'package:gestao_de_estagio/core/theme/app_text_styles.dart';
import 'package:gestao_de_estagio/features/shared/animations/lottie_animations.dart';

class EmptyDataWidget extends StatelessWidget {
  final String message;
  final double animationSize;

  const EmptyDataWidget({
    super.key,
    required this.message,
    this.animationSize = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EmptyStateAnimation(size: animationSize),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.h6.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
