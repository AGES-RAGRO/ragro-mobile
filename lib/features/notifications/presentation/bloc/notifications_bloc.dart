import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/get_notifications.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/get_unread_notifications_count.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(
    this._getNotifications,
    this._getUnreadNotificationsCount,
    this._markAllNotificationsAsRead,
    this._markNotificationAsRead,
  ) : super(const NotificationsInitial()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsUnreadCountRequested>(_onUnreadCountRequested);
    on<NotificationsRefreshed>(_onRefreshed);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<NotificationsAllMarkedAsRead>(_onAllMarkedAsRead);
  }

  final GetNotifications _getNotifications;
  final GetUnreadNotificationsCount _getUnreadNotificationsCount;
  final MarkAllNotificationsAsRead _markAllNotificationsAsRead;
  final MarkNotificationAsRead _markNotificationAsRead;

  List<AppNotificationEntity> _notifications = const [];
  int _unreadCount = 0;

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

  Future<void> _onUnreadCountRequested(
    NotificationsUnreadCountRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    await _loadUnreadCount(emit);
  }

  Future<void> _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final wasUnread = _notifications.any((notification) {
        return notification.id == event.id && !notification.read;
      });
      await _markNotificationAsRead(event.id);

      _notifications = _notifications.map((notification) {
        if (notification.id != event.id) return notification;
        return notification.copyWith(read: true);
      }).toList();
      if (wasUnread && _unreadCount > 0) {
        _unreadCount -= 1;
      }

      emit(NotificationsLoaded(_notifications, unreadCount: _unreadCount));
    } on Exception catch (e) {
      emit(
        NotificationsFailure(
          e.toString(),
          previousNotifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  Future<void> _onAllMarkedAsRead(
    NotificationsAllMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _markAllNotificationsAsRead();

      _notifications = _notifications.map((notification) {
        return notification.copyWith(read: true);
      }).toList();
      _unreadCount = 0;

      emit(NotificationsLoaded(_notifications, unreadCount: _unreadCount));
    } on Exception catch (e) {
      emit(
        NotificationsFailure(
          e.toString(),
          previousNotifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  Future<void> _loadNotifications(Emitter<NotificationsState> emit) async {
    final previousNotifications = List<AppNotificationEntity>.from(
      _notifications,
    );
    emit(
      NotificationsLoading(
        previousNotifications: previousNotifications,
        unreadCount: _unreadCount,
      ),
    );

    try {
      _notifications = await _getNotifications();
      _unreadCount = await _getUnreadNotificationsCount();
      emit(NotificationsLoaded(_notifications, unreadCount: _unreadCount));
    } on Exception catch (e) {
      emit(
        NotificationsFailure(
          e.toString(),
          previousNotifications: previousNotifications,
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  Future<void> _loadUnreadCount(Emitter<NotificationsState> emit) async {
    try {
      _unreadCount = await _getUnreadNotificationsCount();
      final currentNotifications = List<AppNotificationEntity>.from(
        _notifications,
      );
      emit(
        NotificationsLoaded(currentNotifications, unreadCount: _unreadCount),
      );
    } on Exception catch (e) {
      emit(
        NotificationsFailure(
          e.toString(),
          previousNotifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    }
  }
}
