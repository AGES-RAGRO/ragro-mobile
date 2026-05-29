import 'package:equatable/equatable.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

class NotificationMarkedAsRead extends NotificationsEvent {
  const NotificationMarkedAsRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
