import 'package:equatable/equatable.dart';

enum RouteCalculationStatus { initial, calculating, calculated, error }

/// A route delivery stop, derived from an accepted/in-delivery order.
class RouteDelivery extends Equatable {
  const RouteDelivery({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.stop,
    this.eta,
  });

  /// Route stop id (a parada referencia o pedido no backend).
  final String id;

  /// Customer name.
  final String title;

  /// Human-readable address for display.
  final String subtitle;

  /// Routing point: "lat,lng" when coordinates exist, otherwise the address.
  final String stop;

  /// ETA absoluto estimado na criação da rota (com trânsito do momento).
  final DateTime? eta;

  @override
  List<Object?> get props => [id, title, subtitle, stop, eta];
}

class RouteCalculationState extends Equatable {
  /// FALLBACK local da matriz veículo -> combustíveis do backend (Co2Service /
  /// `GET /co2/options`): usado como valor inicial e mantido quando a chamada
  /// falha, para os dropdowns continuarem dependentes e o app não enviar uma
  /// combinação que o backend rejeita com HTTP 400.
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

  /// Id da rota persistida no backend (null enquanto não criada/carregada).
  final String? routeId;

  /// Baseline de CO2 do servidor (idas-e-voltas individuais, km).
  final double? baselineDistanceKm;

  /// Polyline codificada da rota completa, desenhada no mini-mapa.
  final String? overviewPolyline;

  /// Displayed deliveries, already in optimized order (unconfirmed first).
  final List<RouteDelivery> deliveries;

  /// Unconfirmed stops in optimized order, used to build the Google Maps deep-link.
  final List<String> orderedStops;

  /// Fuels allowed per vehicle (PT labels for the dropdowns). Starts with
  /// [fallbackAllowedFuelsByVehicle] and is replaced by the backend matrix
  /// when `GET /co2/options` succeeds.
  final Map<String, List<String>> allowedFuelsByVehicle;

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
