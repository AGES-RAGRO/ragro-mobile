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
