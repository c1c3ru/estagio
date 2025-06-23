import 'package:dartz/dartz.dart';
import '../../core/errors/app_exceptions.dart';
import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<Either<AppFailure, List<NotificationEntity>>> getAllNotifications(
      String userId);
  Future<Either<AppFailure, NotificationEntity>> createNotification(
      NotificationEntity notification);
  Future<Either<AppFailure, void>> markAsRead(String notificationId);
  Future<Either<AppFailure, void>> markAllAsRead(String userId);
  Future<Either<AppFailure, void>> deleteNotification(String notificationId);
  Future<Either<AppFailure, void>> clearAllNotifications(String userId);
}
