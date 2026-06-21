import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationEntity>> getNotifications();

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
