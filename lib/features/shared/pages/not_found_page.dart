import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/404_not_found_animation.json',
                height: 200),
            const SizedBox(height: 24),
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'A página que você tentou acessar não existe ou foi removida.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
