import 'package:equatable/equatable.dart';

class Co2CalculationRequest extends Equatable {
  final double distanceKm;
  final String vehicleType;
  final String fuelType;
  final double? averageConsumption;

  const Co2CalculationRequest({
    required this.distanceKm,
    required this.vehicleType,
    required this.fuelType,
    this.averageConsumption,
  });

  Map<String, dynamic> toJson() {
    return {
      'distanceKm': distanceKm,
      'vehicleType': vehicleType,
      'fuelType': fuelType,
      if (averageConsumption != null) 'averageConsumption': averageConsumption,
    };
  }

  @override
  List<Object?> get props => [distanceKm, vehicleType, fuelType, averageConsumption];
}

/// Records an optimized route's CO2 savings (POST /co2/record-savings). The
/// backend computes savings = emission(round-trip sum) − emission(optimized).
class Co2SavingRequest extends Equatable {
  final double distanceOptimized;

  /// Origin→each-stop distances (km); the backend doubles each (round-trip) as
  /// the "separate deliveries" baseline.
  final List<double> separateDeliveryDistances;
  final String vehicleType;
  final String fuelType;
  final double? averageConsumption;

  const Co2SavingRequest({
    required this.distanceOptimized,
    required this.separateDeliveryDistances,
    required this.vehicleType,
    required this.fuelType,
    this.averageConsumption,
  });

  Map<String, dynamic> toJson() {
    return {
      'distanceOptimized': distanceOptimized,
      'separateDeliveryDistances': separateDeliveryDistances,
      'vehicleType': vehicleType,
      'fuelType': fuelType,
      if (averageConsumption != null) 'averageConsumption': averageConsumption,
    };
  }

  @override
  List<Object?> get props => [
    distanceOptimized,
    separateDeliveryDistances,
    vehicleType,
    fuelType,
    averageConsumption,
  ];
}
