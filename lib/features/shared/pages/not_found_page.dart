import 'package:flutter/material.dart';
import '../animations/lottie_animations.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie404Widget(
              message: 'Página não encontrada',
              size: 300,
            ),
            SizedBox(height: 12),
            Text(
              'A página que você tentou acessar não existe ou foi removida.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
