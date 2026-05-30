import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial({this.unreadCount = 0});

  final int unreadCount;

  @override
  List<Object?> get props => [unreadCount];
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading({
    this.previousNotifications = const [],
    this.unreadCount = 0,
  });

  final List<AppNotificationEntity> previousNotifications;
  final int unreadCount;

  @override
  List<Object?> get props => [previousNotifications, unreadCount];
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.notifications, {this.unreadCount = 0});

  final List<AppNotificationEntity> notifications;
  final int unreadCount;

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsFailure extends NotificationsState {
  const NotificationsFailure(
    this.message, {
    this.previousNotifications = const [],
    this.unreadCount = 0,
  });

  final String message;
  final List<AppNotificationEntity> previousNotifications;
  final int unreadCount;

  @override
  List<Object?> get props => [message, previousNotifications, unreadCount];
}
