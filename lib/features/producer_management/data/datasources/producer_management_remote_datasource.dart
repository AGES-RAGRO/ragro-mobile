import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';

@lazySingleton
class ProducerManagementRemoteDataSource {
  /// Gets dashboard data for the authenticated producer.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<ProducerDashboard> getDashboard() async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.producerDashboard,
  ///     );
  ///     return ProducerDashboard.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<ProducerDashboard> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const ProducerDashboard(
      producerName: 'João Silva',
      producerTitle: 'Produtor Orgânico Certificado',
      avatarUrl: '',
      totalSales: 42850.0,
      salesGrowthPercent: 18.5,
      totalOrders: 128,
      ordersGrowthPercent: 12.0,
      stockPercentage: 85.0,
      stockChangePercent: -2.0,
      weeklyChartData: [3200, 4100, 2800, 5600, 4800, 3900, 2200],
      currentMonth: 'Março/26',
    );
  }
}
