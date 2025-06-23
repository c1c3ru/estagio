import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/i_notification_repository.dart';
import '../../../domain/repositories/i_auth_repository.dart'; // Assuming you have this

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoadAllRequested extends NotificationEvent {}

class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class NotificationMarkAllAsReadRequested extends NotificationEvent {}

class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class NotificationClearAllRequested extends NotificationEvent {}

class NotificationCreateRequested extends NotificationEvent {
  final NotificationEntity notification;

  const NotificationCreateRequested({required this.notification});

  @override
  List<Object> get props => [notification];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

// Loading States
class NotificationLoading extends NotificationState {}

class NotificationSelecting extends NotificationState {}

class NotificationInserting extends NotificationState {}

class NotificationUpdating extends NotificationState {}

class NotificationDeleting extends NotificationState {}

// Success States
class NotificationLoadAllSuccess extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationLoadAllSuccess({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object> get props => [notifications, unreadCount];
}

class NotificationMarkAsReadSuccess extends NotificationState {
  final String notificationId;

  const NotificationMarkAsReadSuccess({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class NotificationMarkAllAsReadSuccess extends NotificationState {}

class NotificationDeleteSuccess extends NotificationState {
  final String deletedId;

  const NotificationDeleteSuccess({required this.deletedId});

  @override
  List<Object> get props => [deletedId];
}

class NotificationClearAllSuccess extends NotificationState {}

class NotificationCreateSuccess extends NotificationState {
  final NotificationEntity notification;

  const NotificationCreateSuccess({required this.notification});

  @override
  List<Object> get props => [notification];
}

// Error States
class NotificationSelectError extends NotificationState {
  final String message;

  const NotificationSelectError({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationInsertError extends NotificationState {
  final String message;

  const NotificationInsertError({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationUpdateError extends NotificationState {
  final String message;

  const NotificationUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationDeleteError extends NotificationState {
  final String message;

  const NotificationDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final INotificationRepository _notificationRepository;
  final IAuthRepository _authRepository; // To get current user

  NotificationBloc({
    required INotificationRepository notificationRepository,
    required IAuthRepository authRepository,
  })  : _notificationRepository = notificationRepository,
        _authRepository = authRepository,
        super(NotificationInitial()) {
    on<NotificationLoadAllRequested>(_onNotificationLoadAllRequested);
    on<NotificationMarkAsReadRequested>(_onNotificationMarkAsReadRequested);
    on<NotificationMarkAllAsReadRequested>(
        _onNotificationMarkAllAsReadRequested);
    on<NotificationDeleteRequested>(_onNotificationDeleteRequested);
    on<NotificationClearAllRequested>(_onNotificationClearAllRequested);
    on<NotificationCreateRequested>(_onNotificationCreateRequested);
  }

  Future<String> _getUserId() async {
    final user = await _authRepository.getCurrentUser();
    return user.fold((l) => throw l, (r) => r!.id);
  }

  Future<void> _onNotificationLoadAllRequested(
    NotificationLoadAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationSelecting());
    try {
      final userId = await _getUserId();
      final result = await _notificationRepository.getAllNotifications(userId);
      result.fold(
        (failure) => emit(NotificationSelectError(message: failure.message)),
        (notifications) {
          final unreadCount = notifications.where((n) => !n.isRead).length;
          emit(NotificationLoadAllSuccess(
              notifications: notifications, unreadCount: unreadCount));
        },
      );
    } catch (e) {
      emit(NotificationSelectError(message: e.toString()));
    }
  }

  Future<void> _onNotificationMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationUpdating());
    try {
      final result =
          await _notificationRepository.markAsRead(event.notificationId);
      result.fold(
        (failure) => emit(NotificationUpdateError(message: failure.message)),
        (_) => emit(NotificationMarkAsReadSuccess(
            notificationId: event.notificationId)),
      );
    } catch (e) {
      emit(NotificationUpdateError(message: e.toString()));
    }
  }

  Future<void> _onNotificationMarkAllAsReadRequested(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationUpdating());
    try {
      final userId = await _getUserId();
      final result = await _notificationRepository.markAllAsRead(userId);
      result.fold(
        (failure) => emit(NotificationUpdateError(message: failure.message)),
        (_) => emit(NotificationMarkAllAsReadSuccess()),
      );
    } catch (e) {
      emit(NotificationUpdateError(message: e.toString()));
    }
  }

  Future<void> _onNotificationDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationDeleting());
    try {
      final result = await _notificationRepository
          .deleteNotification(event.notificationId);
      result.fold(
        (failure) => emit(NotificationDeleteError(message: failure.message)),
        (_) => emit(NotificationDeleteSuccess(deletedId: event.notificationId)),
      );
    } catch (e) {
      emit(NotificationDeleteError(message: e.toString()));
    }
  }

  Future<void> _onNotificationClearAllRequested(
    NotificationClearAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationDeleting());
    try {
      final userId = await _getUserId();
      final result =
          await _notificationRepository.clearAllNotifications(userId);
      result.fold(
        (failure) => emit(NotificationDeleteError(message: failure.message)),
        (_) => emit(NotificationClearAllSuccess()),
      );
    } catch (e) {
      emit(NotificationDeleteError(message: e.toString()));
    }
  }

  Future<void> _onNotificationCreateRequested(
    NotificationCreateRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationInserting());
    try {
      final result =
          await _notificationRepository.createNotification(event.notification);
      result.fold(
        (failure) => emit(NotificationInsertError(message: failure.message)),
        (notification) =>
            emit(NotificationCreateSuccess(notification: notification)),
      );
    } catch (e) {
      emit(NotificationInsertError(message: e.toString()));
    }
  }
}
