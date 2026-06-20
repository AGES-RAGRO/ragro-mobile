import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/domain/repositories/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remote, this._local);

  final NotificationsRemoteDataSource _remote;
  final NotificationsLocalDataSource _local;

  @override
  Future<List<AppNotificationEntity>> getNotifications() async {
    try {
      final remote = await _remote.getNotifications();
      await _local.cacheNotifications(remote);
      return remote;
    } on Exception {
      // Offline / server error: fall back to the last cached list, if any.
      final cached = _local.getCachedNotifications();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final count = await _remote.getUnreadCount();
      await _local.cacheUnreadCount(count);
      return count;
    } on Exception {
      return _local.getCachedUnreadCount();
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remote.markAsRead(id);
    await _local.markCachedAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remote.markAllAsRead();
    await _local.markAllCachedAsRead();
  }
}
