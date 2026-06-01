import 'package:equatable/equatable.dart';

enum RouteCalculationStatus { initial, calculating, calculated, error }

/// A route delivery stop, derived from an accepted/in-delivery order.
class RouteDelivery extends Equatable {
  const RouteDelivery({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.stop,
  });

  /// Order id.
  final String id;

  /// Customer name.
  final String title;

  /// Human-readable address for display.
  final String subtitle;

  /// Routing point: "lat,lng" when coordinates exist, otherwise the address.
  final String stop;

  @override
  List<Object?> get props => [id, title, subtitle, stop];
}

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

  /// Displayed deliveries, already in optimized order (unconfirmed first).
  final List<RouteDelivery> deliveries;

  /// Unconfirmed stops in optimized order, used to build the Google Maps deep-link.
  final List<String> orderedStops;

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
    this.deliveries = const [],
    this.orderedStops = const [],
  });

  /// Whether there are pending (unconfirmed) deliveries to route.
  bool get hasPendingDeliveries =>
      deliveries.any((d) => !confirmedDeliveries.contains(d.id));

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
    List<RouteDelivery>? deliveries,
    List<String>? orderedStops,
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
      deliveries: deliveries ?? this.deliveries,
      orderedStops: orderedStops ?? this.orderedStops,
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
    deliveries,
    orderedStops,
  ];
}
