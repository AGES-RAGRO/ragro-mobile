import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationEntity>> getNotifications();

  Future<void> markAsRead(String id);
}
