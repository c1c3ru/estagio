import 'package:flutter/material.dart';
import '../../core/theme/app_theme_extensions.dart';

class EmptyDataWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;

  const EmptyDataWidget({
    super.key,
    required this.message,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: context.tokens.spaceLg),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: context.tokens.spaceLg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ],
      ),
    );
  }
}