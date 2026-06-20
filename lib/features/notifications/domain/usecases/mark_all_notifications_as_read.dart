import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/domain/repositories/notifications_repository.dart';

@lazySingleton
class MarkAllNotificationsAsRead {
  const MarkAllNotificationsAsRead(this._repository);

  final NotificationsRepository _repository;

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}
