import 'package:equatable/equatable.dart';

enum RouteCalculationStatus { initial, loading, calculating, calculated, error }

/// A route delivery stop, derived from an accepted/in-delivery order.
class RouteDelivery extends Equatable {
  const RouteDelivery({
    required this.id,
    required this.orderId,
    required this.title,
    required this.subtitle,
    required this.stop,
    this.eta,
  });

  /// Route stop id.
  final String id;

  /// Order id behind the stop (used to cancel/refuse the order).
  final String orderId;

  /// Customer name.
  final String title;

  /// Human-readable address for display.
  final String subtitle;

  /// Routing point: "lat,lng" when coordinates exist, otherwise the address.
  final String stop;

  /// Absolute ETA estimated at route creation (with traffic at that time).
  final DateTime? eta;

  @override
  List<Object?> get props => [id, orderId, title, subtitle, stop, eta];
}

class RouteCalculationState extends Equatable {

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
    this.routeId,
    this.baselineDistanceKm,
    this.overviewPolyline,
    this.deliveries = const [],
    this.orderedStops = const [],
    this.allowedFuelsByVehicle = fallbackAllowedFuelsByVehicle,
  });
  /// Local fallback for the backend vehicle -> fuels matrix (`GET /co2/options`):
  /// initial value and kept on failure so dropdowns stay dependent and the app
  /// never sends a combination the backend rejects with HTTP 400.
  static const Map<String, List<String>> fallbackAllowedFuelsByVehicle = {
    'Carro': ['Gasolina', 'Etanol', 'Diesel', 'Elétrico'],
    'Moto': ['Gasolina', 'Etanol', 'Elétrico'],
    'Van': ['Gasolina', 'Diesel', 'Elétrico'],
    'Caminhão': ['Diesel', 'Elétrico'],
  };

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

  /// Persisted route id (null until created/loaded).
  final String? routeId;

  /// Server CO2 baseline (individual round-trips, km).
  final double? baselineDistanceKm;

  /// Encoded polyline of the full route, drawn on the mini-map.
  final String? overviewPolyline;

  /// Displayed deliveries, already in optimized order (unconfirmed first).
  final List<RouteDelivery> deliveries;

  /// Unconfirmed stops in optimized order, used to build the Google Maps deep-link.
  final List<String> orderedStops;

  /// Fuels allowed per vehicle (PT labels). Starts as [fallbackAllowedFuelsByVehicle];
  /// replaced by the backend matrix when `GET /co2/options` succeeds.
  final Map<String, List<String>> allowedFuelsByVehicle;

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
    String? routeId,
    double? baselineDistanceKm,
    String? overviewPolyline,
    List<RouteDelivery>? deliveries,
    List<String>? orderedStops,
    Map<String, List<String>>? allowedFuelsByVehicle,
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
      routeId: routeId ?? this.routeId,
      baselineDistanceKm: baselineDistanceKm ?? this.baselineDistanceKm,
      overviewPolyline: overviewPolyline ?? this.overviewPolyline,
      deliveries: deliveries ?? this.deliveries,
      orderedStops: orderedStops ?? this.orderedStops,
      allowedFuelsByVehicle:
          allowedFuelsByVehicle ?? this.allowedFuelsByVehicle,
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
    routeId,
    baselineDistanceKm,
    overviewPolyline,
    deliveries,
    orderedStops,
    allowedFuelsByVehicle,
  ];
}
