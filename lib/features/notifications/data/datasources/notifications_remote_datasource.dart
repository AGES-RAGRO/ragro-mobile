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

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch<void>(ApiEndpoints.notificationRead(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  List<Map<String, dynamic>> _readList(dynamic data) {
    final rawList = switch (data) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map when map['data'] is List<dynamic> =>
        map['data'] as List<dynamic>,
      final Map<String, dynamic> map when map['content'] is List<dynamic> =>
        map['content'] as List<dynamic>,
      final Map<String, dynamic> map when map['items'] is List<dynamic> =>
        map['items'] as List<dynamic>,
      final Map<String, dynamic> map
          when map['notifications'] is List<dynamic> =>
        map['notifications'] as List<dynamic>,
      _ => const <dynamic>[],
    };

    return rawList.whereType<Map<String, dynamic>>().toList();
  }
}
