import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/producer_management/data/models/producer_dashboard_model.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';

@lazySingleton
class ProducerManagementRemoteDataSource {
  final ApiClient _apiClient = getIt<ApiClient>();
  final AuthLocalDataSource _authLocal = getIt<AuthLocalDataSource>();

  /// Gets dashboard data for the authenticated producer.
  Future<ProducerDashboard> getDashboard({
    required int month,
    required int year,
  }) async {
    final producerId = _authLocal.getUserId();
    if (producerId == null || producerId.isEmpty) {
      throw const UnauthorizedException(
        'Sessão expirada. Faça login novamente.',
      );
    }

    try {
      final profileResponse = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producer(producerId),
      );
      final monthlyResponse = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producerDashboard,
        queryParameters: {'month': month, 'year': year},
      );
      final weeklyResponse = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producerDashboardWeek,
      );

      return ProducerDashboardModel.fromJson(
        producerId: producerId,
        profileJson: profileResponse.data ?? const <String, dynamic>{},
        monthlyJson: monthlyResponse.data ?? const <String, dynamic>{},
        weeklyJson: weeklyResponse.data ?? const <String, dynamic>{},
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
