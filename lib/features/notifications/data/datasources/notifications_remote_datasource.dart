import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/models/notification_model.dart';

@lazySingleton
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._apiClient, this._authLocal);

  final ApiClient _apiClient;
  final AuthLocalDataSource _authLocal;

  /// Notifications are the same contract for both roles, served under different
  /// base paths: /customers/me/notifications vs /producers/me/notifications.
  /// We resolve the scope from the logged-in user's stored type so a single
  /// data source + bloc serves both the customer and producer shells.
  bool get _isProducer {
    // Stored value is UserType.name ('producer'); accept the API alias 'farmer'
    // too. Any other/absent value defaults to the customer scope.
    final stored = _authLocal.getUserType();
    return stored == 'producer' || stored == 'farmer';
  }

  String get _listPath => _isProducer
      ? ApiEndpoints.producerNotifications
      : ApiEndpoints.customerNotifications;

  String get _unreadCountPath => _isProducer
      ? ApiEndpoints.producerNotificationsUnreadCount
      : ApiEndpoints.customerNotificationsUnreadCount;

  String _readPath(String id) => _isProducer
      ? ApiEndpoints.producerNotificationRead(id)
      : ApiEndpoints.customerNotificationRead(id);

  String get _readAllPath => _isProducer
      ? ApiEndpoints.producerNotificationsReadAll
      : ApiEndpoints.customerNotificationsReadAll;

  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(_listPath);

      return _readList(response.data)
          .map(AppNotificationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      final error = e.error;
      if (error is NotFoundException) return const [];
      throw error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(_unreadCountPath);

      return _readCount(response.data);
    } on DioException catch (e) {
      final error = e.error;
      if (error is NotFoundException) return 0;
      throw error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch<void>(_readPath(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.patch<void>(_readAllPath);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  List<Map<String, dynamic>> _readList(dynamic data) {
    final rawList = _findList(data);
    return rawList.whereType<Map<String, dynamic>>().toList();
  }

  List<dynamic> _findList(dynamic data) {
    if (data is List<dynamic>) return data;

    if (data is Map<String, dynamic>) {
      for (final key in const [
        'data',
        'content',
        'items',
        'notifications',
        'result',
        'results',
        'list',
      ]) {
        final value = data[key];
        final list = _findList(value);
        if (list.isNotEmpty) return list;
      }
    }

    return const <dynamic>[];
  }

  int _readCount(dynamic data) {
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) return int.tryParse(data) ?? 0;
    if (data is Map<String, dynamic>) {
      for (final key in const ['count', 'unreadCount', 'unread_count', 'total']) {
        final value = data[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
      }
    }
    return 0;
  }
}
