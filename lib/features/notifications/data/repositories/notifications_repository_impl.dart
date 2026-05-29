import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/domain/repositories/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._dataSource);

  final NotificationsRemoteDataSource _dataSource;

  @override
  Future<List<AppNotificationEntity>> getNotifications() {
    return _dataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String id) {
    return _dataSource.markAsRead(id);
  }
}
