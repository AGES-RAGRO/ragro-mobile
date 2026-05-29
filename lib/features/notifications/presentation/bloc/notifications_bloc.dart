import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/get_notifications.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._getNotifications, this._markNotificationAsRead)
      : super(const NotificationsInitial()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsRefreshed>(_onRefreshed);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
  }

  final GetNotifications _getNotifications;
  final MarkNotificationAsRead _markNotificationAsRead;

  List<AppNotificationEntity> _notifications = const [];

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    await _loadNotifications(emit);
  }

  Future<void> _onRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationsState> emit,
  ) async {
    await _loadNotifications(emit);
  }

  Future<void> _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _markNotificationAsRead(event.id);

      _notifications = _notifications.map((notification) {
        if (notification.id != event.id) return notification;
        return notification.copyWith(read: true);
      }).toList();

      emit(NotificationsLoaded(_notifications));
    } on Exception catch (e) {
      emit(
        NotificationsFailure(
          e.toString(),
          previousNotifications: _notifications,
        ),
      );
    }
  }

  Future<void> _loadNotifications(Emitter<NotificationsState> emit) async {
    final previousNotifications = List<AppNotificationEntity>.from(
      _notifications,
    );
    emit(NotificationsLoading(previousNotifications: previousNotifications));

    try {
      _notifications = await _getNotifications();
      emit(NotificationsLoaded(_notifications));
    } on Exception catch (e) {
      emit(
        NotificationsFailure(
          e.toString(),
          previousNotifications: previousNotifications,
        ),
      );
    }
  }
}
