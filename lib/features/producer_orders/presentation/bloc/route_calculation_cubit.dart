import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_request_model.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/route_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/services/route_tracking_publisher.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/refuse_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_state.dart';

/// Delivery route PERSISTED on the backend: created once (1 Google call),
/// resumed via GET /routes/active on reopen, with per-stop progress (PATCH) and
/// no Google recompute.
@injectable
class RouteCalculationCubit extends Cubit<RouteCalculationState> {

  RouteCalculationCubit(
    this._co2Repository,
    this._routeRepository,
    this._trackingPublisher,
    this._refuseProducerOrder,
  ) : super(const RouteCalculationState()) {
    _initRoute();
  }
  final Co2Repository _co2Repository;
  final RouteRepository _routeRepository;
  final RouteTrackingPublisher _trackingPublisher;
  final RefuseProducerOrder _refuseProducerOrder;

  /// Records CO2 savings only on route CREATION (resuming doesn't re-record).
  bool _savingsRecorded = false;

  @override
  Future<void> close() async {
    // Closing the screen does NOT stop sharing: the route stays active and the
    // foreground service keeps emitting until the last delivery is confirmed.
    return super.close();
  }

  Future<void> _initRoute() async {
    // Best-effort: swap the hardcoded fuel matrix for the backend's without
    // blocking route loading.
    unawaited(_loadCo2Options());

    if (state.averageConsumption.trim().isEmpty) {
      emit(
        state.copyWith(
          averageConsumption:
              defaultConsumptionByVehicle[state.selectedVehicle] ?? '10',
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
    } on Exception {
      // No GPS: can still RESUME an active route; creating a new one needs
      // location and the flow below emits the proper error.
    }

    if (isClosed) return;
    await loadRoute();
  }

  /// Best-effort: fetches the vehicle -> fuels matrix (`GET /co2/options`) into
  /// the dropdowns. On failure keeps the hardcoded fallback
  /// ([RouteCalculationState.fallbackAllowedFuelsByVehicle]) so the flow still
  /// works offline or when the endpoint is down.
  Future<void> _loadCo2Options() async {
    try {
      final options = await _co2Repository.getOptions();
      if (isClosed) return;

      // API sends EN enums (CAR/GASOLINE...); UI uses PT labels.
      final mapped = <String, List<String>>{};
      for (final entry in options.entries) {
        final vehicle = _vehicleLabelFromApi(entry.key);
        if (vehicle == null) continue;
        final fuels = entry.value
            .map(_fuelLabelFromApi)
            .whereType<String>()
            .toList();
        if (fuels.isNotEmpty) mapped[vehicle] = fuels;
      }
      if (mapped.isEmpty) return;

      // Stable vehicle order (backend map is unordered).
      final ordered = <String, List<String>>{
        for (final vehicle
            in RouteCalculationState.fallbackAllowedFuelsByVehicle.keys)
          if (mapped.containsKey(vehicle)) vehicle: mapped[vehicle]!,
      };

      // Keep the current selection valid in the new dropdowns.
      var selectedVehicle = state.selectedVehicle;
      if (!ordered.containsKey(selectedVehicle)) {
        selectedVehicle = ordered.keys.first;
      }
      var selectedFuel = state.selectedFuel;
      final allowed = ordered[selectedVehicle]!;
      if (!allowed.contains(selectedFuel)) selectedFuel = allowed.first;

      emit(
        state.copyWith(
          allowedFuelsByVehicle: ordered,
          selectedVehicle: selectedVehicle,
          selectedFuel: selectedFuel,
        ),
      );
    } on Exception {
      // State already starts with the hardcoded fallback matrix; nothing to do.
    }
  }

  /// Default consumption (km/L) per vehicle, used when the producer leaves it
  /// blank to avoid the backend's "consumption required" error and still
  /// estimate CO2. The producer can override it.
  static const Map<String, String> defaultConsumptionByVehicle = {
    'Carro': '12',
    'Moto': '35',
    'Van': '9',
    'Caminhão': '5',
  };

  void updateFormData({String? vehicle, String? fuel, String? consumption}) {
    final nextVehicle = vehicle ?? state.selectedVehicle;
    var nextFuel = fuel ?? state.selectedFuel;

    final allowed =
        state.allowedFuelsByVehicle[nextVehicle] ?? const ['Gasolina'];
    if (!allowed.contains(nextFuel)) {
      nextFuel = allowed.first;
    }

    final nextConsumption =
        consumption ??
        (vehicle != null && state.averageConsumption.trim().isEmpty
            ? (defaultConsumptionByVehicle[nextVehicle] ??
                  state.averageConsumption)
            : state.averageConsumption);

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
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: 'Erro ao calcular CO2. Tente novamente.',
        ),
      );
    }
  }

  /// Marks the stop delivered (backend PATCH completes the order via its state
  /// machine). No Google call here — the response carries the updated route.
  ///
  /// [code] (customer's 4 digits) is REQUIRED: the backend rejects a missing or
  /// wrong code with 400. Returns `true` on success, `false` on error (so the
  /// code dialog keeps its error state and re-prompts).
  Future<bool> confirmDelivery(String stopId, String code) async {
    final routeId = state.routeId;
    if (routeId == null) return false;
    if (state.confirmedDeliveries.contains(stopId)) return true;

    try {
      final route = await _routeRepository.updateStop(
        routeId: routeId,
        stopId: stopId,
        status: 'DELIVERED',
        code: code,
      );
      if (isClosed) return false;

      _applyRoute(route);
      _refreshProducerDashboard();
      return true;
    } on ApiException catch (e) {
      if (isClosed) return false;
      // Surface the backend message (e.g. código incorreto / obrigatório).
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: e.message,
        ),
      );
      return false;
    } on Exception {
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: 'Erro ao confirmar entrega. Tente novamente.',
        ),
      );
      return false;
    }
  }

  /// Refuses the ORDER behind a route stop and refreshes the screen.
  ///
  /// The backend refuses the order (-> CANCELLED) and `RouteStopSyncListener`
  /// moves the stop to terminal (FAILED). There's no "cancel stop" PATCH, so we
  /// re-fetch the active route (`GET /routes/active`) and reapply it. If it was
  /// the LAST stop, the route completes and `getActiveRoute()` returns `null`;
  /// state is cleared gracefully (no crash).
  ///
  /// Returns `true` on success, `false` on error (emits error state, like
  /// [confirmDelivery]).
  Future<bool> cancelOrder(
    String stopId, {
    required String reason,
    String? details,
  }) async {
    final routeId = state.routeId;
    if (routeId == null) return false;

    // Resolve the order id from the stop (refusal acts on the ORDER, not the
    // stop).
    final orderId = state.deliveries
        .where((d) => d.id == stopId)
        .map((d) => d.orderId)
        .firstWhere((id) => id.isNotEmpty, orElse: () => '');
    if (orderId.isEmpty) return false;

    try {
      await _refuseProducerOrder(orderId, reason: reason, details: details);
      if (isClosed) return false;

      // Backend already synced the stop (terminal); re-fetch the active route
      // to reflect the cancelled stop's removal.
      final route = await _routeRepository.getActiveRoute();
      if (isClosed) return false;

      if (route == null) {
        // Was the only/last stop: route completed. Clear state gracefully
        // (screen shows "no pending deliveries").
        unawaited(_trackingPublisher.stop());
        emit(
          state.copyWith(
            deliveries: const [],
            orderedStops: const [],
            confirmedDeliveries: const {},
            totalDistanceKm: 0,
            totalDurationMins: 0,
          ),
        );
      } else {
        _applyRoute(route);
      }

      _refreshProducerDashboard();
      return true;
    } on ApiException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: e.message,
        ),
      );
      return false;
    } on Exception {
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: 'Erro ao cancelar o pedido. Tente novamente.',
        ),
      );
      return false;
    }
  }

  /// Resumes the active route or creates a new one from the producer's orders.
  Future<void> loadRoute() async {
    try {
      var route = await _routeRepository.getActiveRoute();
      if (isClosed) return;

      if (route == null) {
        final lat = state.producerLat;
        final lng = state.producerLng;
        if (lat == null || lng == null) {
          emit(
            state.copyWith(
              status: RouteCalculationStatus.error,
              errorMessage:
                  'Ative a localização para montar a rota de entregas.',
            ),
          );
          return;
        }
        route = await _routeRepository.createRoute(
          originLatitude: lat,
          originLongitude: lng,
        );
        if (isClosed) return;

        // CO2 savings from server numbers: optimized route vs individual
        // round-trips baseline (Route Matrix).
        if (!_savingsRecorded) {
          _savingsRecorded = true;
          _recordCo2Savings(route);
        }
      }

      _applyRoute(route);
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          deliveries: const [],
          orderedStops: const [],
          totalDistanceKm: 0,
          totalDurationMins: 0,
          status: RouteCalculationStatus.error,
          errorMessage:
              'Não foi possível montar a rota. Verifique se há pedidos '
              'confirmados e tente novamente.',
        ),
      );
    }
  }

  /// Projects the persisted route into the shape the screen consumes: pending
  /// stops in optimized order + delivered last, totals and polyline.
  void _applyRoute(DeliveryRoute route) {
    final pending = route.stops.where((s) => !s.isTerminal).toList();
    final done = route.stops.where((s) => s.isTerminal).toList();

    RouteDelivery toDelivery(DeliveryRouteStop stop) => RouteDelivery(
      id: stop.id,
      orderId: stop.orderId,
      title: stop.customerName.isNotEmpty ? stop.customerName : 'Cliente',
      subtitle: stop.addressText,
      stop: '${stop.latitude},${stop.longitude}',
      eta: stop.eta,
    );

    // Active route: turn on position sharing (real-time for customers);
    // completed route: stop emitting.
    if (route.status == 'ACTIVE') {
      unawaited(_trackingPublisher.start(route.id));
    } else {
      unawaited(_trackingPublisher.stop());
    }

    emit(
      state.copyWith(
        routeId: route.id,
        deliveries: [...pending.map(toDelivery), ...done.map(toDelivery)],
        orderedStops: pending.map((s) => '${s.latitude},${s.longitude}').toList(),
        confirmedDeliveries: done.map((s) => s.id).toSet(),
        totalDistanceKm: route.totalDistanceKm,
        totalDurationMins: route.totalDurationSeconds ~/ 60,
        baselineDistanceKm: route.baselineDistanceKm,
        overviewPolyline: route.overviewPolyline,
        producerLat: state.producerLat ?? route.originLatitude,
        producerLng: state.producerLng ?? route.originLongitude,
      ),
    );
  }

  /// Reloads the producer dashboard (singleton bloc) after a delivery so the
  /// "delivered" metrics update without reopening the app.
  void _refreshProducerDashboard() {
    final dashboard = getIt<ProducerManagementBloc>();
    if (dashboard.state is! ProducerManagementInitial) {
      dashboard.add(const ProducerManagementRefreshed());
    }
  }

  /// Best-effort: records the new route's CO2 savings using server road
  /// distances (optimized vs individual baseline).
  void _recordCo2Savings(DeliveryRoute route) {
    final fuel = _mapFuelType(state.selectedFuel);
    if (fuel == 'ELECTRIC') return; // CO2 savings = 0

    final baseline = route.baselineDistanceKm;
    if (route.totalDistanceKm <= 0 || baseline == null || baseline <= 0) {
      return;
    }

    final consumption = double.tryParse(
      state.averageConsumption.replaceAll(',', '.'),
    );

    unawaited(
      _co2Repository
          .recordSavings(
            Co2SavingRequest(
              distanceOptimized: route.totalDistanceKm,
              distanceNonOptimized: baseline,
              vehicleType: _mapVehicleType(state.selectedVehicle),
              fuelType: fuel,
              averageConsumption: consumption,
            ),
          )
          .catchError((_) {}),
    );
  }

  /// Inverse of [_mapVehicleType]: backend EN enum -> UI PT label.
  String? _vehicleLabelFromApi(String apiVehicle) {
    return switch (apiVehicle.toUpperCase()) {
      'MOTORCYCLE' => 'Moto',
      'CAR' => 'Carro',
      'VAN' => 'Van',
      'LIGHT_TRUCK' => 'Caminhão',
      _ => null,
    };
  }

  /// Inverse of [_mapFuelType]: backend EN enum -> UI PT label.
  String? _fuelLabelFromApi(String apiFuel) {
    return switch (apiFuel.toUpperCase()) {
      'GASOLINE' => 'Gasolina',
      'ETHANOL' => 'Etanol',
      'DIESEL' => 'Diesel',
      'ELECTRIC' => 'Elétrico',
      _ => null,
    };
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
