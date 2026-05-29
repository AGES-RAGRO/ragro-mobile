import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading({this.previousNotifications = const []});

  final List<AppNotificationEntity> previousNotifications;

  @override
  List<Object?> get props => [previousNotifications];
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.notifications);

  final List<AppNotificationEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationsFailure extends NotificationsState {
  const NotificationsFailure(
    this.message, {
    this.previousNotifications = const [],
  });

  final String message;
  final List<AppNotificationEntity> previousNotifications;

  @override
  List<Object?> get props => [message, previousNotifications];
}
