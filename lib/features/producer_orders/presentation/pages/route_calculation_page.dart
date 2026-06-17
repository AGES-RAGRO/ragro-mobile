import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_cubit.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_state.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteCalculationPage extends StatelessWidget {
  const RouteCalculationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RouteCalculationCubit>(),
      child: const _RouteCalculationView(),
    );
  }
}

class _RouteCalculationView extends StatefulWidget {
  const _RouteCalculationView();

  @override
  State<_RouteCalculationView> createState() => _RouteCalculationViewState();
}

class _RouteCalculationViewState extends State<_RouteCalculationView> {
  Future<void> _openGoogleMaps() async {
    final state = context.read<RouteCalculationCubit>().state;
    final stops = state.orderedStops;

    if (stops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma entrega pendente para abrir no mapa.'),
        ),
      );
      return;
    }

    final lat = state.producerLat ?? -16.6868;
    final lng = state.producerLng ?? -49.2647;
    final destination = stops.last;
    final waypoints = stops.length > 1
        ? stops.sublist(0, stops.length - 1)
        : const <String>[];

    // Navigation deep-link (no API key needed). Stops already come in the
    // backend's optimized order; `dir_action=navigate` opens directly into
    // turn-by-turn driving navigation.
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': '$lat,$lng',
      'destination': destination,
      if (waypoints.isNotEmpty) 'waypoints': waypoints.join('|'),
      'travelmode': 'driving',
      'dir_action': 'navigate',
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o Google Maps.'),
          ),
        );
      }
    }
  }

  void _showCo2BottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<RouteCalculationCubit>(),
          child: const _Co2BottomSheetContent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RouteCalculationCubit, RouteCalculationState>(
      listenWhen: (prev, curr) =>
          curr.status == RouteCalculationStatus.error &&
          prev.status != RouteCalculationStatus.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Erro ao calcular CO₂. Tente novamente.',
            ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.white,
                  leading: GestureDetector(
                    onTap: () => context.pop(
                      context
                          .read<RouteCalculationCubit>()
                          .state
                          .confirmedDeliveries
                          .toList(),
                    ),
                    child: const Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                  title: const Text(
                    'Rota Calculada',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  centerTitle: true,
                  pinned: true,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(color: const Color(0x1A2E5729), height: 1),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<
                          RouteCalculationCubit,
                          RouteCalculationState
                        >(
                          builder: (context, state) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _RouteStatCard(
                                    label: 'Duração',
                                    value: '${state.totalDurationMins} min',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _RouteStatCard(
                                    label: 'Distância',
                                    value:
                                        '${state.totalDistanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        BlocBuilder<
                          RouteCalculationCubit,
                          RouteCalculationState
                        >(
                          builder: (context, state) {
                            if (state.status ==
                                RouteCalculationStatus.calculated) {
                              return _Co2ResultCard(
                                co2: state.calculatedCo2 ?? 0,
                                vehicle: state.selectedVehicle,
                                fuel: state.selectedFuel,
                                consumption: state.averageConsumption,
                                onRecalculate: () =>
                                    _showCo2BottomSheet(context),
                              );
                            }

                            return _Co2CalculateCard(
                              onTap: () => _showCo2BottomSheet(context),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'A rota abaixo foi otimizada para\neconomizar tempo, combustível e emissões de CO2.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        BlocBuilder<
                          RouteCalculationCubit,
                          RouteCalculationState
                        >(
                          builder: (context, state) {
                            final lat = state.producerLat ?? -16.6868;
                            final lng = state.producerLng ?? -49.2647;
                            final loc = LatLng(lat, lng);

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 160,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      key: ValueKey(loc),
                                      initialCameraPosition: CameraPosition(
                                        target: loc,
                                        zoom: 13,
                                      ),
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      scrollGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      mapToolbarEnabled: false,
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId('producer'),
                                          position: loc,
                                          icon:
                                              BitmapDescriptor.defaultMarkerWithHue(
                                                BitmapDescriptor.hueGreen,
                                              ),
                                        ),
                                      },
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: _openGoogleMaps,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkGreen,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Abrir com Google Maps',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.open_in_new,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Sequência de Entregas',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        BlocBuilder<
                          RouteCalculationCubit,
                          RouteCalculationState
                        >(
                          builder: (context, state) {
                            if (state.deliveries.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Nenhuma entrega pendente no momento.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < state.deliveries.length;
                                  i++
                                ) ...[
                                  _DeliveryItem(
                                    id: state.deliveries[i].id,
                                    number: i + 1,
                                    title: state.deliveries[i].title,
                                    subtitle: state.deliveries[i].subtitle,
                                  ),
                                  if (i != state.deliveries.length - 1)
                                    const SizedBox(height: 16),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                color: Colors.white,
                child: GestureDetector(
                  onTap: () => context.pop(
                    context
                        .read<RouteCalculationCubit>()
                        .state
                        .confirmedDeliveries
                        .toList(),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        'Finalizar Entrega',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteStatCard extends StatelessWidget {
  const _RouteStatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _Co2CalculateCard extends StatelessWidget {
  const _Co2CalculateCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColors.darkGreen),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cálculo de CO₂',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  'Calcule o CO₂ estimado',
                  style: TextStyle(fontSize: 12, color: AppColors.darkGreen),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.darkGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Calcular CO₂',
              style: TextStyle(color: AppColors.darkGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Co2ResultCard extends StatelessWidget {
  const _Co2ResultCard({
    required this.co2,
    required this.vehicle,
    required this.fuel,
    required this.consumption,
    required this.onRecalculate,
  });

  final double co2;
  final String vehicle;
  final String fuel;
  final String consumption;
  final VoidCallback onRecalculate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColors.darkGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${co2.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  '$vehicle • $fuel • $consumption km/L',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onRecalculate,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.darkGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Recalcular CO₂',
              style: TextStyle(color: AppColors.darkGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryItem extends StatelessWidget {
  const _DeliveryItem({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteCalculationCubit, RouteCalculationState>(
      builder: (context, state) {
        final isConfirmed = state.confirmedDeliveries.contains(id);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              number.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.location_on_outlined, color: AppColors.darkGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: isConfirmed
                  ? null
                  : () => context.read<RouteCalculationCubit>().confirmDelivery(
                      id,
                    ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isConfirmed ? AppColors.darkGreen : Colors.white,
                  border: Border.all(color: AppColors.darkGreen),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isConfirmed ? 'Entregue' : 'Confirmar\nEntrega',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isConfirmed ? Colors.white : AppColors.darkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Co2BottomSheetContent extends StatefulWidget {
  const _Co2BottomSheetContent();

  @override
  State<_Co2BottomSheetContent> createState() => _Co2BottomSheetContentState();
}

class _Co2BottomSheetContentState extends State<_Co2BottomSheetContent> {
  final _consumptionController = TextEditingController();
  String? _consumptionError;

  @override
  void initState() {
    super.initState();
    final state = context.read<RouteCalculationCubit>().state;
    _consumptionController.text = state.averageConsumption;
  }

  @override
  void dispose() {
    _consumptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocBuilder<RouteCalculationCubit, RouteCalculationState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Calcular CO₂ da rota',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              const Text(
                'Veículo',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: state.selectedVehicle,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: RouteCalculationCubit.allowedFuelsByVehicle.keys.map((
                  e,
                ) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  context.read<RouteCalculationCubit>().updateFormData(
                    vehicle: val,
                  );
                  // Sync the field with the new vehicle's default consumption
                  // when no value has been entered yet.
                  final preset =
                      RouteCalculationCubit.defaultConsumptionByVehicle[val];
                  if (preset != null &&
                      _consumptionController.text.trim().isEmpty) {
                    _consumptionController.text = preset;
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Combustível',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: state.selectedFuel,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    (RouteCalculationCubit.allowedFuelsByVehicle[state
                                .selectedVehicle] ??
                            const ['Gasolina'])
                        .map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        })
                        .toList(),
                onChanged: (val) => context
                    .read<RouteCalculationCubit>()
                    .updateFormData(fuel: val),
              ),
              const SizedBox(height: 16),
              const Text(
                'Consumo médio (km/L)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _consumptionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Digite o consumo médio',
                  errorText: _consumptionError,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  if (_consumptionError != null) {
                    setState(() => _consumptionError = null);
                  }
                  context.read<RouteCalculationCubit>().updateFormData(
                    consumption: val,
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Voltar',
                        style: TextStyle(color: AppColors.darkGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          state.status == RouteCalculationStatus.calculating
                          ? null
                          : () {
                              // Backend requires consumption (> 0) for
                              // non-electric vehicles; validate before sending.
                              final needsConsumption =
                                  state.selectedFuel != 'Elétrico';
                              final consumption = double.tryParse(
                                state.averageConsumption.replaceAll(',', '.'),
                              );
                              if (needsConsumption &&
                                  (consumption == null || consumption <= 0)) {
                                setState(
                                  () => _consumptionError =
                                      'Informe o consumo médio (km/L).',
                                );
                                return;
                              }
                              context
                                  .read<RouteCalculationCubit>()
                                  .calculateCo2(state.totalDistanceKm);
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: state.status == RouteCalculationStatus.calculating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirmar',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
