import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoadAllSuccess &&
                  state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                          NotificationMarkAllAsReadRequested(),
                        );
                  },
                  child: const Text('Marcar todas como lidas'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Limpar todas'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationSelecting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificationLoadAllSuccess) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma notificação',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você não tem notificações no momento',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(
                      NotificationLoadAllRequested(),
                    );
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<NotificationBloc>().add(
                              NotificationMarkAsReadRequested(
                                notificationId: notification.id,
                              ),
                            );
                      }
                    },
                    onDelete: () {
                      context.read<NotificationBloc>().add(
                            NotificationDeleteRequested(
                              notificationId: notification.id,
                            ),
                          );
                    },
                  );
                },
              ),
            );
          }

          if (state is NotificationSelectError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar notificações',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                            NotificationLoadAllRequested(),
                          );
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar todas as notificações'),
        content: const Text(
          'Tem certeza que deseja limpar todas as notificações? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(
                    NotificationClearAllRequested(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          notification.isRead ? null : AppColors.primaryLight.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _getNotificationColor(notification.type),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(notification.createdAt),
                          style: AppTextStyles.caption,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 18,
                          color: AppColors.textSecondary,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'info':
        return AppColors.info;
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'time_log':
        return AppColors.primary;
      default:
        return AppColors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_outlined;
      case 'error':
        return Icons.error_outline;
      case 'time_log':
        return Icons.access_time;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
