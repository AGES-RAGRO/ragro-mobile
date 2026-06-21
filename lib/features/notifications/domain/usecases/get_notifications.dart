import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/domain/repositories/notifications_repository.dart';

@lazySingleton
class GetNotifications {
  const GetNotifications(this._repository);

  final NotificationsRepository _repository;

  Future<List<AppNotificationEntity>> call() {
    return _repository.getNotifications();
  }
}
