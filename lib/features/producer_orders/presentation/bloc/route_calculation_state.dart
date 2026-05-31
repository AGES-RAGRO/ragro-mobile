import 'package:equatable/equatable.dart';

enum RouteCalculationStatus { initial, calculating, calculated, error }

class RouteCalculationState extends Equatable {
  final RouteCalculationStatus status;
  final double? calculatedCo2;
  final String? errorMessage;
  final String selectedVehicle;
  final String selectedFuel;
  final String averageConsumption;
  final Set<String> confirmedDeliveries;
  final int totalDurationMins;
  final double totalDistanceKm;
  final double? producerLat;
  final double? producerLng;

  const RouteCalculationState({
    this.status = RouteCalculationStatus.initial,
    this.calculatedCo2,
    this.errorMessage,
    this.selectedVehicle = 'Carro',
    this.selectedFuel = 'Gasolina',
    this.averageConsumption = '',
    this.confirmedDeliveries = const {},
    this.totalDurationMins = 0,
    this.totalDistanceKm = 0.0,
    this.producerLat,
    this.producerLng,
  });

  RouteCalculationState copyWith({
    RouteCalculationStatus? status,
    double? calculatedCo2,
    String? errorMessage,
    String? selectedVehicle,
    String? selectedFuel,
    String? averageConsumption,
    Set<String>? confirmedDeliveries,
    int? totalDurationMins,
    double? totalDistanceKm,
    double? producerLat,
    double? producerLng,
  }) {
    return RouteCalculationState(
      status: status ?? this.status,
      calculatedCo2: calculatedCo2 ?? this.calculatedCo2,
      errorMessage: errorMessage,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedFuel: selectedFuel ?? this.selectedFuel,
      averageConsumption: averageConsumption ?? this.averageConsumption,
      confirmedDeliveries: confirmedDeliveries ?? this.confirmedDeliveries,
      totalDurationMins: totalDurationMins ?? this.totalDurationMins,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      producerLat: producerLat ?? this.producerLat,
      producerLng: producerLng ?? this.producerLng,
    );
  }

  @override
  List<Object?> get props => [
    status,
    calculatedCo2,
    errorMessage,
    selectedVehicle,
    selectedFuel,
    averageConsumption,
    confirmedDeliveries,
    totalDurationMins,
    totalDistanceKm,
    producerLat,
    producerLng,
  ];
}
