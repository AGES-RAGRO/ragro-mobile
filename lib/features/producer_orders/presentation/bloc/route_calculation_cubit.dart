import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_request_model.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/route_repository.dart';
import 'route_calculation_state.dart';

/// Rota de entrega PERSISTIDA no backend: criada uma vez (1 chamada Google),
/// retomada via GET /routes/active ao reabrir o app, e com progresso por parada
/// (PATCH) sem recálculo no Google — antes, cada confirmação de entrega pagava
/// uma nova chamada Directions e fechar o app perdia a sequência.
@injectable
class RouteCalculationCubit extends Cubit<RouteCalculationState> {
  final Co2Repository _co2Repository;
  final RouteRepository _routeRepository;

  /// Garante o registro de economia de CO2 só na CRIAÇÃO da rota (retomar uma
  /// rota ativa não re-registra a mesma economia).
  bool _savingsRecorded = false;

  RouteCalculationCubit(this._co2Repository, this._routeRepository)
    : super(const RouteCalculationState()) {
    _initRoute();
  }

  Future<void> _initRoute() async {
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
      // Sem GPS: ainda dá para RETOMAR uma rota ativa; criar uma nova exige
      // localização e o fluxo abaixo emite o erro adequado.
    }

    if (isClosed) return;
    await loadRoute();
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

    final allowed = allowedFuelsByVehicle[nextVehicle] ?? const ['Gasolina'];
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

  /// Marca a parada como entregue (PATCH no backend, que conclui o pedido pela
  /// máquina de estados). NENHUMA chamada ao Google acontece aqui — a resposta
  /// já traz a rota atualizada.
  Future<void> confirmDelivery(String stopId) async {
    final routeId = state.routeId;
    if (routeId == null || state.confirmedDeliveries.contains(stopId)) return;

    try {
      final route = await _routeRepository.updateStop(
        routeId: routeId,
        stopId: stopId,
        status: 'DELIVERED',
      );
      if (isClosed) return;

      _applyRoute(route);
      _refreshProducerDashboard();
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RouteCalculationStatus.error,
          errorMessage: 'Erro ao confirmar entrega. Tente novamente.',
        ),
      );
    }
  }

  /// Retoma a rota ativa ou cria uma nova a partir dos pedidos do produtor.
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

        // Economia de CO2 com números do servidor: rota otimizada (rodoviária)
        // vs. baseline de idas-e-voltas individuais (Route Matrix) — antes o
        // baseline era linha reta calculada no app.
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
          totalDistanceKm: 0.0,
          totalDurationMins: 0,
          status: RouteCalculationStatus.error,
          errorMessage:
              'Não foi possível montar a rota. Verifique se há pedidos '
              'confirmados e tente novamente.',
        ),
      );
    }
  }

  /// Projeta a rota persistida na interface que a tela consome: paradas
  /// pendentes em ordem otimizada + entregues no fim, totais e polyline.
  void _applyRoute(DeliveryRoute route) {
    final pending = route.stops.where((s) => !s.isTerminal).toList();
    final done = route.stops.where((s) => s.isTerminal).toList();

    RouteDelivery toDelivery(DeliveryRouteStop stop) => RouteDelivery(
      id: stop.id,
      title: stop.customerName.isNotEmpty ? stop.customerName : 'Cliente',
      subtitle: stop.addressText,
      stop: '${stop.latitude},${stop.longitude}',
      eta: stop.eta,
    );

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

  /// Best-effort: registra a economia de CO2 da rota recém-criada com as
  /// distâncias rodoviárias do servidor (otimizada vs. baseline individual).
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
