import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/domain/repositories/notifications_repository.dart';

@lazySingleton
class GetUnreadNotificationsCount {
  const GetUnreadNotificationsCount(this._repository);

  final NotificationsRepository _repository;

  Future<int> call() {
    return _repository.getUnreadCount();
  }
}
