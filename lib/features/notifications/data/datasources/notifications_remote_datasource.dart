import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/notifications/data/models/notification_model.dart';

@lazySingleton
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.notifications,
      );

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
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.notificationsUnreadCount,
      );

      return _readCount(response.data);
    } on DioException catch (e) {
      final error = e.error;
      if (error is NotFoundException) return 0;
      throw error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch<void>(ApiEndpoints.notificationRead(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.patch<void>(ApiEndpoints.notificationsReadAll);
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
