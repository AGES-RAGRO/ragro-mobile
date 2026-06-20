import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/domain/repositories/notifications_repository.dart';

@lazySingleton
class MarkNotificationAsRead {
  const MarkNotificationAsRead(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String id) {
    return _repository.markAsRead(id);
  }
}
