import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';

class ProducerDashboardModel extends ProducerDashboard {
  const ProducerDashboardModel({
    required super.producerId,
    required super.producerName,
    required super.producerTitle,
    required super.avatarUrl,
    required super.coverUrl,
    required super.averageRating,
    required super.totalReviews,
    required super.totalSales,
    required super.salesGrowthPercent,
    required super.totalOrders,
    required super.ordersGrowthPercent,
    required super.stockPercentage,
    required super.stockChangePercent,
    required super.weeklyChartData,
    required super.currentMonth,
    required super.availability,
  });

  factory ProducerDashboardModel.fromJson({
    required String producerId,
    required Map<String, dynamic> profileJson,
    required Map<String, dynamic> monthlyJson,
    required Map<String, dynamic> weeklyJson,
  }) {
    final farmName =
        (profileJson['farmName'] as String? ??
                profileJson['farm_name'] as String? ??
                '')
            .trim();

    return ProducerDashboardModel(
      producerId: producerId,
      producerName: (profileJson['name'] as String? ?? '').trim(),
      producerTitle: farmName.isNotEmpty ? farmName : 'Produtor',
      avatarUrl: ApiEndpoints.resolveMediaUrl(
        profileJson['avatarS3'] as String? ??
            profileJson['avatar_s3'] as String? ??
            '',
      ),
      coverUrl: ApiEndpoints.resolveMediaUrl(
        profileJson['displayPhotoS3'] as String? ??
            profileJson['display_photo_s3'] as String? ??
            '',
      ),
      averageRating: (profileJson['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (profileJson['totalReviews'] as num?)?.toInt() ?? 0,
      totalSales: _metricDouble(monthlyJson['salesMetric'], 'currentValue'),
      salesGrowthPercent: _metricDouble(
        monthlyJson['salesMetric'],
        'percentageChange',
      ),
      totalOrders: _metricInt(monthlyJson['ordersMetric'], 'currentValue'),
      ordersGrowthPercent: _metricDouble(
        monthlyJson['ordersMetric'],
        'percentageChange',
      ),
      stockPercentage:
          (monthlyJson['stockSoldPercentage'] as num?)?.toDouble() ?? 0,
      stockChangePercent: _metricDouble(
        monthlyJson['stockMetric'],
        'percentageChange',
      ),
      weeklyChartData: _weeklySales(weeklyJson),
      currentMonth: _monthLabel((monthlyJson['month'] as num?)?.toInt()),
      availability: _availability(profileJson['availability']),
    );
  }

  static double _metricDouble(dynamic raw, String key) {
    if (raw is! Map<String, dynamic>) return 0;
    return (raw[key] as num?)?.toDouble() ?? 0;
  }

  static int _metricInt(dynamic raw, String key) {
    if (raw is! Map<String, dynamic>) return 0;
    return (raw[key] as num?)?.toInt() ?? 0;
  }

  static List<double> _weeklySales(Map<String, dynamic> json) {
    final values = List<double>.filled(7, 0);
    final dailySales = json['dailySales'];
    if (dailySales is! List) return values;

    for (final item in dailySales) {
      if (item is! Map<String, dynamic>) continue;
      final index = _weekdayIndex(item['dayOfWeek'] as String?);
      if (index == null) continue;
      values[index] = (item['salesAmount'] as num?)?.toDouble() ?? 0;
    }

    return values;
  }

  static int? _weekdayIndex(String? dayOfWeek) {
    final normalized = dayOfWeek?.toLowerCase().trim();
    return switch (normalized) {
      'segunda-feira' || 'segunda' => 0,
      'terça-feira' || 'terca-feira' || 'terça' || 'terca' => 1,
      'quarta-feira' || 'quarta' => 2,
      'quinta-feira' || 'quinta' => 3,
      'sexta-feira' || 'sexta' => 4,
      'sábado' || 'sabado' => 5,
      'domingo' => 6,
      _ => null,
    };
  }

  static List<DashboardAvailabilitySlot> _availability(dynamic raw) {
    final availability = <DashboardAvailabilitySlot>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          availability.add(
            DashboardAvailabilitySlot(
              weekday: (item['weekday'] as num?)?.toInt() ?? 0,
              opensAt: item['opensAt'] as String? ?? '',
              closesAt: item['closesAt'] as String? ?? '',
            ),
          );
        }
      }
    }
    return availability;
  }

  static String _monthLabel(int? month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    if (month == null || month < 1 || month > 12) return 'Atual';
    return months[month - 1];
  }
}
