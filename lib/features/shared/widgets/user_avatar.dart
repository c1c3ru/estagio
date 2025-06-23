// lib/features/shared/widgets/user_avatar.dart
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name; // Nome completo para extrair iniciais
  final double radius;
  final double fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor; // Cor para as iniciais

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24.0, // Raio padrão para CircleAvatar
    this.fontSize = 16.0, // Tamanho da fonte para as iniciais
    this.backgroundColor,
    this.foregroundColor,
  });

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final bool hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    ImageProvider? backgroundImage;
    if (hasImage) {
      // Tenta carregar a imagem da rede.
      // Considerar adicionar tratamento de erro para NetworkImage (ex: errorBuilder)
      // ou usar um pacote como cached_network_image.
      try {
        backgroundImage = NetworkImage(imageUrl!);
      } catch (e) {
        // logger.w('Erro ao carregar NetworkImage para UserAvatar: $e');
        backgroundImage = null; // Fallback se a URL for inválida
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBackgroundColor,
      backgroundImage: backgroundImage,
      onBackgroundImageError: hasImage
          ? (_, __) {
              // Fallback se a imagem da rede não carregar, mas não queremos mostrar o texto sobre o erro.
              // O CircleAvatar já mostra o child se backgroundImage falhar.
              // No entanto, para forçar o child (iniciais) se a imagem falhar,
              // poderíamos ter um estado ou usar um FutureBuilder/Image.network com errorBuilder.
              // Para simplificar, se a URL for fornecida mas falhar, pode mostrar o backgroundColor.
              // Se quisermos mostrar as iniciais em caso de erro de imagem, a lógica seria mais complexa aqui.
            }
          : null,
      child: (backgroundImage == null ||
              !hasImage) // Mostra iniciais se não houver imagem ou se falhar (simplificado)
          ? Text(
              _initials,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: effectiveForegroundColor,
              ),
            )
          : null,
    );
  }
}
