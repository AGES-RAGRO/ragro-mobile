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

/// Rota de entrega PERSISTIDA no backend: criada uma vez (1 chamada Google),
/// retomada via GET /routes/active ao reabrir o app, e com progresso por parada
/// (PATCH) sem recálculo no Google — antes, cada confirmação de entrega pagava
/// uma nova chamada Directions e fechar o app perdia a sequência.
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

  /// Garante o registro de economia de CO2 só na CRIAÇÃO da rota (retomar uma
  /// rota ativa não re-registra a mesma economia).
  bool _savingsRecorded = false;

  @override
  Future<void> close() async {
    // Fechar a tela NÃO encerra o compartilhamento: a rota continua ativa e o
    // foreground service segue emitindo até a última entrega ser confirmada.
    return super.close();
  }

  Future<void> _initRoute() async {
    // Best-effort: troca a matriz hardcoded de combustíveis pela do backend
    // sem bloquear o carregamento da rota.
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
      // Sem GPS: ainda dá para RETOMAR uma rota ativa; criar uma nova exige
      // localização e o fluxo abaixo emite o erro adequado.
    }

    if (isClosed) return;
    await loadRoute();
  }

  /// Best-effort: busca a matriz veículo -> combustíveis do backend
  /// (`GET /co2/options`) e a aplica nos dropdowns. Em caso de falha mantém o
  /// FALLBACK hardcoded já presente no estado
  /// ([RouteCalculationState.fallbackAllowedFuelsByVehicle]), para o fluxo
  /// continuar funcionando offline ou com o endpoint indisponível.
  Future<void> _loadCo2Options() async {
    try {
      final options = await _co2Repository.getOptions();
      if (isClosed) return;

      // A API envia enums EN (CAR/GASOLINE...); a UI trabalha com labels PT.
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

      // Ordem estável dos veículos (o mapa do backend não tem ordem definida).
      final ordered = <String, List<String>>{
        for (final vehicle
            in RouteCalculationState.fallbackAllowedFuelsByVehicle.keys)
          if (mapped.containsKey(vehicle)) vehicle: mapped[vehicle]!,
      };

      // Garante que a seleção atual continua válida nos novos dropdowns.
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
      // FALLBACK: estado já nasce com a matriz hardcoded (espelho local do
      // backend); nada a fazer.
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

  /// Marca a parada como entregue (PATCH no backend, que conclui o pedido pela
  /// máquina de estados). NENHUMA chamada ao Google acontece aqui — a resposta
  /// já traz a rota atualizada.
  ///
  /// O [code] (4 dígitos do consumidor) é OBRIGATÓRIO: o backend rejeita com 400
  /// uma conclusão sem código ou com código errado. Devolve `true` quando a
  /// entrega é confirmada e `false` no erro (para o diálogo de código manter o
  /// estado de erro e re-solicitar o código).
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

  /// Cancela (recusa) o PEDIDO associado a uma parada da rota e atualiza a tela.
  ///
  /// A parada referencia um pedido; o backend recusa o pedido (transição para
  /// CANCELLED) e o `RouteStopSyncListener` sincroniza a parada para um estado
  /// terminal (FAILED). Como NÃO há um PATCH de "cancelar parada" no app, o
  /// refresh re-busca a rota ativa (`GET /routes/active`) e a reaplica: a parada
  /// recusada deixa de aparecer como pendente. Se era a ÚLTIMA parada, a rota
  /// completa no backend e `getActiveRoute()` devolve `null` — o estado é
  /// esvaziado de forma graciosa (sem entregas pendentes), sem crash.
  ///
  /// Devolve `true` no sucesso e `false` no erro (emitindo estado de erro, como
  /// em [confirmDelivery]).
  Future<bool> cancelOrder(
    String stopId, {
    required String reason,
    String? details,
  }) async {
    final routeId = state.routeId;
    if (routeId == null) return false;

    // Resolve o id do pedido a partir da parada (a recusa age sobre o PEDIDO,
    // não sobre a parada).
    final orderId = state.deliveries
        .where((d) => d.id == stopId)
        .map((d) => d.orderId)
        .firstWhere((id) => id.isNotEmpty, orElse: () => '');
    if (orderId.isEmpty) return false;

    try {
      await _refuseProducerOrder(orderId, reason: reason, details: details);
      if (isClosed) return false;

      // O backend já sincronizou a parada (terminal); re-busca a rota ativa para
      // refletir a remoção da parada cancelada.
      final route = await _routeRepository.getActiveRoute();
      if (isClosed) return false;

      if (route == null) {
        // Era a única/última parada: a rota completou no backend. Esvazia o
        // estado de forma graciosa (tela mostra "nenhuma entrega pendente").
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

  /// Projeta a rota persistida na interface que a tela consome: paradas
  /// pendentes em ordem otimizada + entregues no fim, totais e polyline.
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

    // Rota ativa: liga o compartilhamento de posição (tempo real p/ os clientes);
    // rota concluída: para de emitir e a posição deixa de ser compartilhada.
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

  /// Inverso de [_mapVehicleType]: enum EN do backend -> label PT da UI.
  String? _vehicleLabelFromApi(String apiVehicle) {
    return switch (apiVehicle.toUpperCase()) {
      'MOTORCYCLE' => 'Moto',
      'CAR' => 'Carro',
      'VAN' => 'Van',
      'LIGHT_TRUCK' => 'Caminhão',
      _ => null,
    };
  }

  /// Inverso de [_mapFuelType]: enum EN do backend -> label PT da UI.
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
