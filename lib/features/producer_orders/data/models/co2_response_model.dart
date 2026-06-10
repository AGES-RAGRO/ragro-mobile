import 'package:equatable/equatable.dart';

class Co2CalculationResponse extends Equatable {

  const Co2CalculationResponse({
    required this.co2Emission,
    required this.distanceKm,
    required this.vehicleType,
    required this.fuelType,
    this.averageConsumption,
  });

  factory Co2CalculationResponse.fromJson(Map<String, dynamic> json) {
    return Co2CalculationResponse(
      co2Emission: (json['co2Emission'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String,
      fuelType: json['fuelType'] as String,
      averageConsumption: (json['averageConsumption'] as num?)?.toDouble(),
    );
  }
  final double co2Emission;
  final double distanceKm;
  final String vehicleType;
  final String fuelType;
  final double? averageConsumption;

  @override
  List<Object?> get props => [
        co2Emission,
        distanceKm,
        vehicleType,
        fuelType,
        averageConsumption,
      ];
}
