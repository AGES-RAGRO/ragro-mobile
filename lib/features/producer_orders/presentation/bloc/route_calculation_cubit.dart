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

  /// Todas as entregas roteáveis carregadas (fonte da verdade); a lista exibida
  /// no state é derivada desta + das entregas já confirmadas.
  List<RouteDelivery> _allDeliveries = const [];

  /// Garante que a economia de CO2 seja gravada uma única vez por sessão de rota.
  bool _savingsRecorded = false;

  RouteCalculationCubit(
    this._co2Repository,
    this._ordersRepository,
    this._routeRepository,
  ) : super(const RouteCalculationState()) {
    _initRoute();
  }

  Future<void> _initRoute() async {
    // Pré-preenche um consumo médio padrão (editável) para o cálculo de CO2.
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
      // GPS negado/indisponível: a origem é ancorada na 1ª entrega em
      // loadDeliveries — evita exibir uma cidade fixa (ex.: Goiânia).
    } catch (e) {
      // Ignora: segue sem GPS; loadDeliveries resolve a origem pelas entregas.
    }

    if (isClosed) return;
    await loadDeliveries();
  }

  /// Combustíveis permitidos por veículo, espelhando a matriz do backend
  /// (Co2Service / `GET /co2/options`). Mantém os dropdowns dependentes para
  /// o app não enviar combinações que o backend rejeita com HTTP 400
  /// ("Tipo de combustível não permitido para este veículo.").
  static const Map<String, List<String>> allowedFuelsByVehicle = {
    'Carro': ['Gasolina', 'Etanol', 'Diesel', 'Elétrico'],
    'Moto': ['Gasolina', 'Etanol', 'Elétrico'],
    'Van': ['Gasolina', 'Diesel', 'Elétrico'],
    'Caminhão': ['Diesel', 'Elétrico'],
  };

  /// Consumo médio padrão (km/L) por veículo, usado quando o produtor não
  /// informa — evita o erro do backend ("Consumo médio é obrigatório") e gera
  /// uma estimativa de CO2. O produtor pode ajustar manualmente.
  static const Map<String, String> defaultConsumptionByVehicle = {
    'Carro': '12',
    'Moto': '35',
    'Van': '9',
    'Caminhão': '5',
  };

  void updateFormData({String? vehicle, String? fuel, String? consumption}) {
    final nextVehicle = vehicle ?? state.selectedVehicle;
    var nextFuel = fuel ?? state.selectedFuel;

    // Se o veículo mudou e o combustível atual não é permitido para ele,
    // ajusta para o primeiro combustível válido (evita combinação inválida).
    final allowed = allowedFuelsByVehicle[nextVehicle] ?? const ['Gasolina'];
    if (!allowed.contains(nextFuel)) {
      nextFuel = allowed.first;
    }

    // Ao trocar de veículo sem consumo informado, usa o padrão do novo veículo.
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
      // Persiste no backend: move o pedido para DELIVERED (PATCH /orders/{id}/status).
      await _ordersRepository.updateStatus(
        deliveryId,
        ProducerOrderStatus.delivered,
      );
      if (isClosed) return;

      final updatedDeliveries = Set<String>.from(state.confirmedDeliveries)
        ..add(deliveryId);
      emit(state.copyWith(confirmedDeliveries: updatedDeliveries));

      // Entrega concluída → o dashboard (só entregues) precisa recarregar.
      _refreshProducerDashboard();

      // Recalcula a rota sem as entregas já confirmadas.
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

  /// Busca os pedidos aceitos (CONFIRMED) e em entrega (IN_DELIVERY) do
  /// produtor, monta as paradas e calcula a melhor rota.
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

      // Sem GPS: ancora origem/preview na 1ª entrega com coordenadas (em vez
      // de uma cidade fixa). Só roda quando o GPS não definiu a posição.
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
      // Sem entregas roteáveis: zera estatísticas e mantém lista vazia.
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

  /// Converte "lat,lng" em par de doubles; null se não for coordenada numérica.
  (double, double)? _parseLatLng(String stop) {
    final parts = stop.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  /// Recarrega o dashboard do produtor (bloc singleton) após uma entrega, para
  /// as métricas de "entregues" refletirem sem precisar reabrir o app.
  void _refreshProducerDashboard() {
    final dashboard = getIt<ProducerManagementBloc>();
    if (dashboard.state is! ProducerManagementInitial) {
      dashboard.add(const ProducerManagementRefreshed());
    }
  }

  /// Grava a economia de CO2 da rota: baseline = somatório das distâncias
  /// origem→cada parada (ida/volta, calculado pelo backend) vs. a rota
  /// otimizada. Best-effort: não bloqueia o fluxo da rota.
  void _recordCo2Savings(List<RouteDelivery> deliveries, double optimizedKm) {
    final fuel = _mapFuelType(state.selectedFuel);
    if (fuel == 'ELECTRIC') return; // economia de CO2 = 0

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
      if (km > 0) distances.add(km); // backend exige distância > 0
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
    // Origem: GPS/1ª entrega quando houver coordenadas; senão a 1ª parada
    // (o backend aceita endereço textual).
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

      // Reordena os waypoints conforme a ordem otimizada do backend.
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

      // Grava a economia de CO2 da rota otimizada (uma vez por sessão).
      if (!_savingsRecorded && route.distanceKm > 0) {
        _savingsRecorded = true;
        _recordCo2Savings(pending, route.distanceKm);
      }

      // Se o CO2 já foi calculado, recalcula com a nova distância.
      if (state.status == RouteCalculationStatus.calculated) {
        await calculateCo2(route.distanceKm);
      }
    } catch (e) {
      if (isClosed) return;
      // Falha no cálculo: mantém as entregas (ordem original), zera as métricas
      // e sinaliza o erro de forma visível (em vez de exibir 0/0 silencioso).
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
