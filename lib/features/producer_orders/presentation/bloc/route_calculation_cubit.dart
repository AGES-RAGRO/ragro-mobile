import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_request_model.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/directions_repository.dart';
import 'route_calculation_state.dart';

@injectable
class RouteCalculationCubit extends Cubit<RouteCalculationState> {
  final Co2Repository _co2Repository;
  final DirectionsRepository _directionsRepository;

  RouteCalculationCubit(this._co2Repository, this._directionsRepository)
    : super(const RouteCalculationState()) {
    _initRoute();
  }

  Future<void> _initRoute() async {
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
      } else {
        // Fallback for demo
        emit(state.copyWith(producerLat: -16.6868, producerLng: -49.2647));
      }
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(producerLat: -16.6868, producerLng: -49.2647));
    }

    if (isClosed) return;
    await calculateRealRoute();
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

  void updateFormData({String? vehicle, String? fuel, String? consumption}) {
    final nextVehicle = vehicle ?? state.selectedVehicle;
    var nextFuel = fuel ?? state.selectedFuel;

    // Se o veículo mudou e o combustível atual não é permitido para ele,
    // ajusta para o primeiro combustível válido (evita combinação inválida).
    final allowed = allowedFuelsByVehicle[nextVehicle] ?? const ['Gasolina'];
    if (!allowed.contains(nextFuel)) {
      nextFuel = allowed.first;
    }

    emit(
      state.copyWith(
        selectedVehicle: nextVehicle,
        selectedFuel: nextFuel,
        averageConsumption: consumption ?? state.averageConsumption,
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

  void confirmDelivery(String deliveryId) {
    if (state.confirmedDeliveries.contains(deliveryId)) return;

    final updatedDeliveries = Set<String>.from(state.confirmedDeliveries)
      ..add(deliveryId);

    emit(state.copyWith(confirmedDeliveries: updatedDeliveries));

    // Recalculate route without the confirmed deliveries
    calculateRealRoute();
  }

  Future<void> calculateRealRoute() async {
    // Uses real producer location from state
    final lat = state.producerLat ?? -16.6868;
    final lng = state.producerLng ?? -49.2647;
    final origin = '$lat,$lng';

    final allStops = {
      '1': '-16.7000,-49.2500',
      '2': '-16.7200,-49.2600',
      '3': '-16.7500,-49.2700',
    };

    // Filter out confirmed deliveries
    final remainingStops = allStops.entries
        .where((e) => !state.confirmedDeliveries.contains(e.key))
        .map((e) => e.value)
        .toList();

    if (remainingStops.isEmpty) {
      emit(state.copyWith(totalDurationMins: 0, totalDistanceKm: 0.0));
      return;
    }

    final destination = remainingStops.last;
    final waypoints = remainingStops.length > 1
        ? remainingStops.sublist(0, remainingStops.length - 1)
        : <String>[];

    try {
      final routeData = await _directionsRepository.getRoute(
        origin,
        destination,
        waypoints,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          totalDistanceKm: routeData['distanceKm'] as double,
          totalDurationMins: routeData['durationMins'] as int,
        ),
      );

      // Se o CO2 já foi calculado, recalcula com a nova distância
      if (state.status == RouteCalculationStatus.calculated) {
        await calculateCo2(routeData['distanceKm'] as double);
      }
    } catch (e) {
      // Não mantém números fabricados em caso de falha: zera as estatísticas
      // para não exibir distância/duração inválidas ao produtor.
      if (isClosed) return;
      emit(state.copyWith(totalDistanceKm: 0.0, totalDurationMins: 0));
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
