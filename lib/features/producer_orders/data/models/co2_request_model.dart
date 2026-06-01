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

/// Registra a economia de CO2 de uma rota otimizada (POST /co2/record-savings).
/// O backend calcula a economia = emissão(soma ida/volta) − emissão(otimizada).
class Co2SavingRequest extends Equatable {
  final double distanceOptimized;

  /// Distâncias origem→cada parada (km); o backend dobra cada uma (ida/volta)
  /// como baseline de "entregas separadas".
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
