import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';


@lazySingleton
class ProducerManagementRemoteDataSource {
  final ApiClient _apiClient = getIt<ApiClient>();
  final AuthLocalDataSource _authLocal = getIt<AuthLocalDataSource>();

  /// Gets dashboard data for the authenticated producer.
  Future<ProducerDashboard> getDashboard() async {
    final producerId = _authLocal.getUserId();
    if (producerId == null || producerId.isEmpty) {
      throw const UnauthorizedException(
        'Sessão expirada. Faça login novamente.',
      );
    }

    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producer(producerId),
      );

      final data = response.data ?? const <String, dynamic>{};
      final farmName =
          (data['farmName'] as String? ?? data['farm_name'] as String? ?? '')
              .trim();

      final rawAvailability = data['availability'];
      final availability = <DashboardAvailabilitySlot>[];
      if (rawAvailability is List) {
        for (final item in rawAvailability) {
          if (item is Map<String, dynamic>) {
            availability.add(DashboardAvailabilitySlot(
              weekday: (item['weekday'] as num?)?.toInt() ?? 0,
              opensAt: item['opensAt'] as String? ?? '',
              closesAt: item['closesAt'] as String? ?? '',
            ));
          }
        }
      }

      return ProducerDashboard(
        producerName: (data['name'] as String? ?? '').trim(),
        producerTitle: farmName.isNotEmpty ? farmName : 'Produtor',
        avatarUrl: ApiEndpoints.resolveMediaUrl(
            data['avatarS3'] as String? ?? data['avatar_s3'] as String? ?? ''),
        coverUrl: ApiEndpoints.resolveMediaUrl(
            data['displayPhotoS3'] as String? ?? data['display_photo_s3'] as String? ?? ''),
        totalSales: 0,
        salesGrowthPercent: 0,
        totalOrders: (data['totalOrders'] as num?)?.toInt() ?? 0,
        ordersGrowthPercent: 0,
        stockPercentage: 0,
        stockChangePercent: 0,
        weeklyChartData: const [0, 0, 0, 0, 0, 0, 0],
        currentMonth: 'Atual',
        availability: availability,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
