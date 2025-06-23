import 'package:dartz/dartz.dart';
import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/supabase/notification_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepository implements INotificationRepository {
  final NotificationDatasource _datasource;

  NotificationRepository(this._datasource);

  @override
  Future<Either<AppFailure, NotificationEntity>> createNotification(
      NotificationEntity notification) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);
      final result =
          await _datasource.createNotification(notificationModel.toJson());
      return Right(NotificationModel.fromJson(result).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, List<NotificationEntity>>> getAllNotifications(
      String userId) async {
    try {
      final result = await _datasource.getAllNotifications(userId);
      final notifications =
          result.map((e) => NotificationModel.fromJson(e).toEntity()).toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> markAsRead(String notificationId) async {
    try {
      await _datasource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> markAllAsRead(String userId) async {
    try {
      await _datasource.markAllAsRead(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteNotification(
      String notificationId) async {
    try {
      await _datasource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> clearAllNotifications(String userId) async {
    try {
      await _datasource.clearAllNotifications(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
