import 'package:equatable/equatable.dart';

class Co2CalculationResponse extends Equatable {
  final double co2Emission;
  final double distanceKm;
  final String vehicleType;
  final String fuelType;
  final double? averageConsumption;

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

  @override
  List<Object?> get props => [
    co2Emission,
    distanceKm,
    vehicleType,
    fuelType,
    averageConsumption,
  ];
}

class Co2EmissionRecord extends Equatable {
  const Co2EmissionRecord({
    required this.id,
    required this.routeDistanceKm,
    required this.co2Emission,
    required this.vehicleType,
    required this.fuelType,
    required this.createdAt,
  });

  factory Co2EmissionRecord.fromJson(Map<String, dynamic> json) {
    return Co2EmissionRecord(
      id: json['id'] as String,
      routeDistanceKm: (json['routeDistanceKm'] as num).toDouble(),
      co2Emission: (json['co2Emission'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String,
      fuelType: json['fuelType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final double routeDistanceKm;
  final double co2Emission;
  final String vehicleType;
  final String fuelType;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    routeDistanceKm,
    co2Emission,
    vehicleType,
    fuelType,
    createdAt,
  ];
}
