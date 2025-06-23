// lib/features/shared/widgets/animated_transitions.dart
import 'package:flutter/material.dart';

// Exemplo de uma transição de página com Fade
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300), // Duração padrão
    super.settings,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: duration,
        );
}

// Exemplo de uma transição de página com Slide (da direita para a esquerda)
class SlideRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideRightPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Começa da direita
            const end = Offset.zero;
            const curve = Curves.easeOutCubic; // Curva de animação

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

// Exemplo de uma transição de página com Scale (Zoom)
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScalePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8, // Começa com 80% do tamanho
                end: 1.0,
              )
                  .chain(CurveTween(curve: Curves.easeOutCubic))
                  .animate(animation),
              child: FadeTransition(
                // Adiciona um fade para suavizar
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: duration,
        );
}

// Você pode adicionar mais transições personalizadas aqui (ex: SlideUp, Size, etc.)

// Como usar com flutter_modular (exemplo):
// No seu [Feature]Module:
// r.child('/sua-rota', child: (_) => SuaPagina(), transition: TransitionType.custom, customTransition: CustomTransition(
//   transitionBuilder: (context, animation, secondaryAnimation, child) {
//      // Use um dos PageRouteBuilders acima ou crie o seu aqui
//      // Exemplo com Fade:
//      return FadeTransition(opacity: animation, child: child);
//   },
//   transitionDuration: Duration(milliseconds: 300),
// ));
//
// Ou, para navegação manual com Modular.to.push():
// Modular.to.push(FadePageRoute(child: SuaNovaPagina()));
// Modular.to.push(SlideRightPageRoute(child: SuaNovaPagina()));
