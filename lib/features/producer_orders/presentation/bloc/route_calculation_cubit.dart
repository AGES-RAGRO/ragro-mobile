import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_request_model.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/directions_repository.dart';
import 'route_calculation_state.dart';

@injectable
class RouteCalculationCubit extends Cubit<RouteCalculationState> {
  final Co2Repository _co2Repository;
  final DirectionsRepository _directionsRepository;

  RouteCalculationCubit(this._co2Repository, this._directionsRepository) : super(const RouteCalculationState()) {
    calculateRealRoute();
  }

  void updateFormData({String? vehicle, String? fuel, String? consumption}) {
    emit(state.copyWith(
      selectedVehicle: vehicle ?? state.selectedVehicle,
      selectedFuel: fuel ?? state.selectedFuel,
      averageConsumption: consumption ?? state.averageConsumption,
    ));
  }

  Future<void> calculateCo2(double totalDistanceKm) async {
    emit(state.copyWith(status: RouteCalculationStatus.calculating));
    
    try {
      final consumption = double.tryParse(state.averageConsumption.replaceAll(',', '.'));
      final request = Co2CalculationRequest(
        distanceKm: totalDistanceKm,
        vehicleType: _mapVehicleType(state.selectedVehicle),
        fuelType: _mapFuelType(state.selectedFuel),
        averageConsumption: consumption,
      );

      final response = await _co2Repository.calculateCo2(request);
      
      emit(state.copyWith(
        status: RouteCalculationStatus.calculated,
        calculatedCo2: response.co2Emission,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteCalculationStatus.error,
        errorMessage: 'Erro ao calcular CO2. Tente novamente.',
      ));
    }
  }

  void confirmDelivery(String deliveryId) {
    if (state.confirmedDeliveries.contains(deliveryId)) return;

    final updatedDeliveries = Set<String>.from(state.confirmedDeliveries)..add(deliveryId);
    
    emit(state.copyWith(
      confirmedDeliveries: updatedDeliveries,
    ));

    // Recalculate route without the confirmed deliveries
    calculateRealRoute();
  }

  Future<void> calculateRealRoute() async {
    // Mocked coordinates for the current location and deliveries
    const origin = '-16.6868,-49.2647'; // Producer
    
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
    final waypoints = remainingStops.length > 1 ? remainingStops.sublist(0, remainingStops.length - 1) : <String>[];

    try {
      final routeData = await _directionsRepository.getRoute(origin, destination, waypoints);
      emit(state.copyWith(
        totalDistanceKm: routeData['distanceKm'] as double,
        totalDurationMins: routeData['durationMins'] as int,
      ));

      // Se o CO2 já foi calculado, recalcula com a nova distância
      if (state.status == RouteCalculationStatus.calculated) {
        calculateCo2(routeData['distanceKm'] as double);
      }
    } catch (e) {
      // Ignora erro e mantém a distância mockada em caso de falha silenciosa
    }
  }

  String _mapVehicleType(String uiVehicle) {
    switch (uiVehicle.toLowerCase()) {
      case 'moto': return 'MOTORCYCLE';
      case 'carro': return 'CAR';
      case 'van': return 'VAN';
      case 'caminhão': return 'TRUCK';
      default: return 'CAR';
    }
  }

  String _mapFuelType(String uiFuel) {
    switch (uiFuel.toLowerCase()) {
      case 'gasolina': return 'GASOLINE';
      case 'etanol': return 'ETHANOL';
      case 'diesel': return 'DIESEL';
      case 'elétrico': return 'ELECTRIC';
      default: return 'GASOLINE';
    }
  }
}
