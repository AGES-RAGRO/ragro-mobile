import 'package:equatable/equatable.dart';

class Co2CalculationRequest extends Equatable {

  const Co2CalculationRequest({
    required this.distanceKm,
    required this.vehicleType,
    required this.fuelType,
    this.averageConsumption,
  });
  final double distanceKm;
  final String vehicleType;
  final String fuelType;
  final double? averageConsumption;

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
/// backend computes savings = emission(baseline) − emission(optimized).
class Co2SavingRequest extends Equatable {

  const Co2SavingRequest({
    required this.distanceOptimized,
    required this.distanceNonOptimized,
    required this.vehicleType,
    required this.fuelType,
    this.averageConsumption,
  });
  final double distanceOptimized;

  /// Round-trip baseline (km) from the server (Route Matrix) alongside the
  /// persisted route.
  final double distanceNonOptimized;
  final String vehicleType;
  final String fuelType;
  final double? averageConsumption;

  Map<String, dynamic> toJson() {
    return {
      'distanceOptimized': distanceOptimized,
      'distanceNonOptimized': distanceNonOptimized,
      'vehicleType': vehicleType,
      'fuelType': fuelType,
      if (averageConsumption != null) 'averageConsumption': averageConsumption,
    };
  }

  @override
  List<Object?> get props => [
    distanceOptimized,
    distanceNonOptimized,
    vehicleType,
    fuelType,
    averageConsumption,
  ];
}
