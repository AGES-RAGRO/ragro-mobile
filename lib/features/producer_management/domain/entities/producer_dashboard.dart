import 'package:equatable/equatable.dart';

class DashboardAvailabilitySlot extends Equatable {
  const DashboardAvailabilitySlot({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
  });

  final int weekday; // 0=Sun, 1=Mon ... 6=Sat
  final String opensAt;
  final String closesAt;

  @override
  List<Object?> get props => [weekday, opensAt, closesAt];
}

class ProducerDashboard extends Equatable {
  const ProducerDashboard({
    required this.producerName,
    required this.producerTitle,
    required this.avatarUrl,
    required this.coverUrl,
    required this.totalSales,
    required this.salesGrowthPercent,
    required this.totalOrders,
    required this.ordersGrowthPercent,
    required this.stockPercentage,
    required this.stockChangePercent,
    required this.weeklyChartData,
    required this.currentMonth,
    required this.availability,
  });

  final String producerName;
  final String producerTitle;
  final String avatarUrl;
  final String coverUrl;
  final double totalSales;
  final double salesGrowthPercent;
  final int totalOrders;
  final double ordersGrowthPercent;
  final double stockPercentage;
  final double stockChangePercent;
  final List<double> weeklyChartData; // 7 values: S,T,Q,Q,S,S,D
  final String currentMonth;
  final List<DashboardAvailabilitySlot> availability;

  @override
  List<Object?> get props => [
    producerName,
    producerTitle,
    avatarUrl,
    coverUrl,
    totalSales,
    salesGrowthPercent,
    totalOrders,
    ordersGrowthPercent,
    stockPercentage,
    stockChangePercent,
    weeklyChartData,
    currentMonth,
    availability,
  ];
}
