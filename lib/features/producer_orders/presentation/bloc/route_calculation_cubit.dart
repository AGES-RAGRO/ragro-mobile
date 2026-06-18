import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_request_model.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/route_repository.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';
import 'route_calculation_state.dart';

@injectable
class RouteCalculationCubit extends Cubit<RouteCalculationState> {
  final Co2Repository _co2Repository;
  final ProducerOrdersRepository _ordersRepository;
  final RouteRepository _routeRepository;

  /// Source of truth for all routable deliveries; the displayed list is derived
  /// from this plus already-confirmed deliveries.
  List<RouteDelivery> _allDeliveries = const [];

  /// Ensures CO2 savings are recorded only once per route session.
  bool _savingsRecorded = false;

  RouteCalculationCubit(
    this._co2Repository,
    this._ordersRepository,
    this._routeRepository,
  ) : super(const RouteCalculationState()) {
    _initRoute();
  }

  Future<void> _initRoute() async {
    // Pre-fill the default consumption based on the initial vehicle+fuel selection.
    if (state.averageConsumption.trim().isEmpty) {
      emit(
        state.copyWith(
          averageConsumption:
              defaultConsumption(state.selectedVehicle, state.selectedFuel) ?? '',
        ),
      );
    }

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (isClosed) return;

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (isClosed) return;
        emit(
          state.copyWith(
            producerLat: position.latitude,
            producerLng: position.longitude,
          ),
        );
      }
      // GPS denied/unavailable: origin is anchored to the first delivery in
      // loadDeliveries, avoiding a hardcoded city.
    } catch (e) {
      // Proceed without GPS; loadDeliveries resolves the origin from deliveries.
    }

    if (isClosed) return;
    await loadDeliveries();
  }

  /// Fuels allowed per vehicle, mirroring the backend matrix (Co2Service /
  /// `GET /co2/options`). Keeps the dropdowns dependent so the app never sends
  /// a combination the backend rejects with HTTP 400.
  static const Map<String, List<String>> allowedFuelsByVehicle = {
    'Carro': ['Gasolina', 'Etanol', 'Diesel', 'Elétrico'],
    'Moto': ['Gasolina', 'Etanol', 'Elétrico'],
    'Van': ['Gasolina', 'Diesel', 'Elétrico'],
    'Caminhão': ['Diesel', 'Elétrico'],
  };

  /// Default consumption (km/L) per vehicle+fuel combination.
  /// null means electric (no consumption applicable).
  static const Map<String, Map<String, String?>> defaultConsumptionByVehicleAndFuel = {
    'Moto': {'Gasolina': '30', 'Etanol': '22', 'Elétrico': null},
    'Carro': {'Gasolina': '12', 'Etanol': '8,5', 'Diesel': '14', 'Elétrico': null},
    'Van': {'Gasolina': '8', 'Diesel': '8', 'Elétrico': null},
    'Caminhão': {'Diesel': '6', 'Elétrico': null},
  };

  static String? defaultConsumption(String vehicle, String fuel) =>
      defaultConsumptionByVehicleAndFuel[vehicle]?[fuel];

  void updateFormData({String? vehicle, String? fuel, String? consumption}) {
    final nextVehicle = vehicle ?? state.selectedVehicle;
    var nextFuel = fuel ?? state.selectedFuel;

    // If the vehicle changed and the current fuel is no longer allowed, fall
    // back to the first valid fuel to avoid an invalid combination.
    final allowed = allowedFuelsByVehicle[nextVehicle] ?? const ['Gasolina'];
    if (!allowed.contains(nextFuel)) {
      nextFuel = allowed.first;
    }

    // When vehicle or fuel selection changes, reset to the preset consumption.
    // When the user manually types a value, keep it as-is.
    final String nextConsumption;
    if (consumption != null) {
      nextConsumption = consumption;
    } else if (vehicle != null || fuel != null) {
      nextConsumption = defaultConsumption(nextVehicle, nextFuel) ?? '';
    } else {
      nextConsumption = state.averageConsumption;
    }

    emit(
      state.copyWith(
        selectedVehicle: nextVehicle,
        selectedFuel: nextFuel,
        averageConsumption: nextConsumption,
      ),
    );
  }

  Future<void> calculateCo2(double totalDistanceKm) async {
    if (isClosed) return;
    emit(state.copyWith(status: RouteCalculationStatus.calculating));

    try {
      final consumption = double.tryParse(
        state.averageConsumption.replaceAll(',', '.'),
      );
      final request = Co2CalculationRequest(
        distanceKm: totalDistanceKm,
        vehicleType: _mapVehicleType(state.selectedVehicle),
        fuelType: _mapFuelType(state.selectedFuel),
        averageConsumption: consumption,
      );

      final response = await _co2Repository.calculateCo2(request);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: RouteCalculationStatus.calculated,
          calculatedCo2: response.co2Emission,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: 'Erro ao calcular CO2. Tente novamente.',
        ),
      );
    }
  }

  Future<void> confirmDelivery(String deliveryId) async {
    if (state.confirmedDeliveries.contains(deliveryId)) return;

    try {
      // Persist to backend: move the order to DELIVERED (PATCH /orders/{id}/status).
      await _ordersRepository.updateStatus(
        deliveryId,
        ProducerOrderStatus.delivered,
      );
      if (isClosed) return;

      final updatedDeliveries = Set<String>.from(state.confirmedDeliveries)
        ..add(deliveryId);
      emit(state.copyWith(confirmedDeliveries: updatedDeliveries));

      // Delivery completed: the dashboard (delivered only) must reload.
      _refreshProducerDashboard();

      // Recalculate the route without the confirmed deliveries.
      await _recalculateRoute();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: 'Erro ao confirmar entrega. Tente novamente.',
        ),
      );
    }
  }

  Future<bool> confirmDeliveryWithCode(String deliveryId, String code) async {
    if (state.confirmedDeliveries.contains(deliveryId)) return true;

    try {
      await _ordersRepository.confirmDeliveryWithCode(deliveryId, code);
      if (isClosed) return false;

      final updatedDeliveries = Set<String>.from(state.confirmedDeliveries)
        ..add(deliveryId);
      emit(state.copyWith(confirmedDeliveries: updatedDeliveries));

      _refreshProducerDashboard();
      await _recalculateRoute();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetches the producer's accepted (CONFIRMED) and in-delivery (IN_DELIVERY)
  /// orders, builds the stops, and computes the best route.
  Future<void> loadDeliveries() async {
    try {
      final orders = await _ordersRepository.getOrders();
      if (isClosed) return;

      _allDeliveries = orders
          .where(
            (o) =>
                o.status == ProducerOrderStatus.accepted ||
                o.status == ProducerOrderStatus.inDelivery,
          )
          .map(_toDelivery)
          .where((d) => d.stop.isNotEmpty)
          .toList();

      // No GPS: anchor origin/preview to the first delivery with coordinates
      // instead of a hardcoded city. Runs only when GPS did not set a position.
      if (state.producerLat == null || state.producerLng == null) {
        for (final d in _allDeliveries) {
          final coords = _parseLatLng(d.stop);
          if (coords != null) {
            emit(state.copyWith(producerLat: coords.$1, producerLng: coords.$2));
            break;
          }
        }
      }

      await _recalculateRoute();
    } catch (e) {
      if (isClosed) return;
      // No routable deliveries: reset stats and keep the list empty.
      _allDeliveries = const [];
      emit(
        state.copyWith(
          deliveries: const [],
          orderedStops: const [],
          totalDistanceKm: 0.0,
          totalDurationMins: 0,
        ),
      );
    }
  }

  RouteDelivery _toDelivery(ProducerOrder order) {
    return RouteDelivery(
      id: order.id,
      title: order.consumerName.isNotEmpty ? order.consumerName : 'Cliente',
      subtitle: order.fullDeliveryAddress,
      stop: order.routeStop,
    );
  }

  /// Parses "lat,lng" into a double pair; null if not a numeric coordinate.
  (double, double)? _parseLatLng(String stop) {
    final parts = stop.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  /// Reloads the producer dashboard (singleton bloc) after a delivery so the
  /// "delivered" metrics update without reopening the app.
  void _refreshProducerDashboard() {
    final dashboard = getIt<ProducerManagementBloc>();
    if (dashboard.state is! ProducerManagementInitial) {
      dashboard.add(const ProducerManagementRefreshed());
    }
  }

  /// Records the route's CO2 savings: baseline = sum of origin→each-stop
  /// distances (round-trip, computed by the backend) vs. the optimized route.
  /// Best-effort: does not block the route flow.
  void _recordCo2Savings(List<RouteDelivery> deliveries, double optimizedKm) {
    final fuel = _mapFuelType(state.selectedFuel);
    if (fuel == 'ELECTRIC') return; // CO2 savings = 0

    final originLat = state.producerLat;
    final originLng = state.producerLng;
    if (originLat == null || originLng == null) return;

    final distances = <double>[];
    for (final d in deliveries) {
      final coords = _parseLatLng(d.stop);
      if (coords == null) continue;
      final meters = Geolocator.distanceBetween(
        originLat,
        originLng,
        coords.$1,
        coords.$2,
      );
      final km = meters / 1000.0;
      if (km > 0) distances.add(km); // backend requires distance > 0
    }
    if (distances.isEmpty) return;

    final consumption = double.tryParse(
      state.averageConsumption.replaceAll(',', '.'),
    );

    unawaited(
      _co2Repository
          .recordSavings(
            Co2SavingRequest(
              distanceOptimized: optimizedKm,
              separateDeliveryDistances: distances,
              vehicleType: _mapVehicleType(state.selectedVehicle),
              fuelType: fuel,
              averageConsumption: consumption,
            ),
          )
          .catchError((_) {}),
    );
  }

  Future<void> _recalculateRoute() async {
    final pending = _allDeliveries
        .where((d) => !state.confirmedDeliveries.contains(d.id))
        .toList();
    final confirmed = _allDeliveries
        .where((d) => state.confirmedDeliveries.contains(d.id))
        .toList();

    if (pending.isEmpty) {
      emit(
        state.copyWith(
          deliveries: confirmed,
          orderedStops: const [],
          totalDistanceKm: 0.0,
          totalDurationMins: 0,
        ),
      );
      return;
    }

    final lat = state.producerLat;
    final lng = state.producerLng;
    // Origin: GPS/first delivery when coordinates exist; otherwise the first
    // stop (the backend accepts a textual address).
    final origin = (lat != null && lng != null) ? '$lat,$lng' : pending.first.stop;

    final destination = pending.last;
    final waypointDeliveries = pending.length > 1
        ? pending.sublist(0, pending.length - 1)
        : <RouteDelivery>[];

    try {
      final route = await _routeRepository.optimize(
        origin: origin,
        destination: destination.stop,
        waypoints: waypointDeliveries.map((d) => d.stop).toList(),
      );
      if (isClosed) return;

      // Reorder the waypoints according to the backend's optimized order.
      final orderedWaypoints = <RouteDelivery>[];
      if (route.waypointOrder.length == waypointDeliveries.length) {
        for (final idx in route.waypointOrder) {
          if (idx >= 0 && idx < waypointDeliveries.length) {
            orderedWaypoints.add(waypointDeliveries[idx]);
          }
        }
      }
      if (orderedWaypoints.length != waypointDeliveries.length) {
        orderedWaypoints
          ..clear()
          ..addAll(waypointDeliveries);
      }

      final orderedActive = [...orderedWaypoints, destination];

      emit(
        state.copyWith(
          deliveries: [...orderedActive, ...confirmed],
          orderedStops: orderedActive.map((d) => d.stop).toList(),
          totalDistanceKm: route.distanceKm,
          totalDurationMins: route.durationMins,
        ),
      );

      // Record the optimized route's CO2 savings (once per session).
      if (!_savingsRecorded && route.distanceKm > 0) {
        _savingsRecorded = true;
        _recordCo2Savings(pending, route.distanceKm);
      }

      // If CO2 was already calculated, recompute it with the new distance.
      if (state.status == RouteCalculationStatus.calculated) {
        await calculateCo2(route.distanceKm);
      }
    } catch (e) {
      if (isClosed) return;
      // Calculation failed: keep the deliveries (original order), reset metrics,
      // and surface the error visibly instead of silently showing 0/0.
      emit(
        state.copyWith(
          deliveries: [...pending, ...confirmed],
          orderedStops: pending.map((d) => d.stop).toList(),
          totalDistanceKm: 0.0,
          totalDurationMins: 0,
          status: RouteCalculationStatus.error,
          errorMessage: 'Não foi possível calcular a rota. Tente novamente.',
        ),
      );
    }
  }

  String _mapVehicleType(String uiVehicle) {
    switch (uiVehicle.toLowerCase()) {
      case 'moto':
        return 'MOTORCYCLE';
      case 'carro':
        return 'CAR';
      case 'van':
        return 'VAN';
      case 'caminhão':
        return 'LIGHT_TRUCK';
      default:
        return 'CAR';
    }
  }

  String _mapFuelType(String uiFuel) {
    switch (uiFuel.toLowerCase()) {
      case 'gasolina':
        return 'GASOLINE';
      case 'etanol':
        return 'ETHANOL';
      case 'diesel':
        return 'DIESEL';
      case 'elétrico':
        return 'ELECTRIC';
      default:
        return 'GASOLINE';
    }
  }
}
