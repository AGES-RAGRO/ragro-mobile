// Screen: Cálculo de Rota
// User Story: US-33 / US-34 — View Today's Deliveries / View Delivery Route
// Epic: EPIC 9 — Logistics and Routing

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_bloc.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_state.dart';
import 'package:url_launcher/url_launcher.dart';

// Configure via --dart-define=MAPTILER_KEY=your_key_here
const _mapTilerKey = String.fromEnvironment(
  'MAPTILER_KEY',
  defaultValue: 'YOUR_MAPTILER_KEY',
);
const _mapStyleUrl =
    'https://api.maptiler.com/maps/streets-v2/style.json?key=$_mapTilerKey';

class RouteCalculationPage extends StatelessWidget {
  const RouteCalculationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RouteBloc>()..add(const RouteLoadStarted()),
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
  Future<void> _openNavigation(DeliveryRoute route) async {
    if (route.stops.isEmpty) return;

    final last = route.stops.last;
    final waypoints = route.stops
        .sublist(0, route.stops.length - 1)
        .map((s) => '${s.latitude},${s.longitude}')
        .join('|');

    final wazeUri = Uri.parse(
      'waze://?ll=${last.latitude},${last.longitude}&navigate=yes',
    );

    final mapsUri = Uri.parse(
      'https://maps.google.com/maps/dir/?api=1'
      '&destination=${last.latitude},${last.longitude}'
      '${waypoints.isNotEmpty ? '&waypoints=$waypoints' : ''}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(wazeUri)) {
      await launchUrl(wazeUri);
    } else {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.white,
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.black),
                    ),
                    title: const Text(
                      'Rota Calculada',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    centerTitle: true,
                    pinned: true,
                    elevation: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                          color: const Color(0x1A2E5729), height: 1),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: switch (state) {
                      RouteLoading() => const _LoadingBody(),
                      RouteError(:final message) => _ErrorBody(message),
                      RouteLoaded(:final route) when route == null =>
                        const _EmptyBody(),
                      RouteLoaded(:final route) =>
                        _RouteBody(route: route!, onNavigate: _openNavigation),
                      _ => const _LoadingBody(),
                    },
                  ),
                ],
              ),
              if (state is RouteLoaded && state.route != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _NavButton(
                    onTap: () => _openNavigation(state.route!),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteBody extends StatelessWidget {
  const _RouteBody({required this.route, required this.onNavigate});

  final DeliveryRoute route;
  final Future<void> Function(DeliveryRoute) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _RouteStatCard(
                  label: 'Duração',
                  value: route.formattedDuration,
                  icon: Icons.access_time_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RouteStatCard(
                  label: 'Distância Total',
                  value: route.formattedDistance,
                  icon: Icons.route_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.darkGreen.withValues(alpha: 0.15)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    size: 18, color: AppColors.darkGreen),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rota otimizada para menor tempo de entrega.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: AppColors.darkGreen,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              child: MaplibreMap(
                styleString: _mapStyleUrl,
                initialCameraPosition: route.stops.isNotEmpty
                    ? CameraPosition(
                        target: LatLng(
                          route.stops.first.latitude,
                          route.stops.first.longitude,
                        ),
                        zoom: 13,
                      )
                    : const CameraPosition(
                        target: LatLng(-30.0346, -51.2165),
                        zoom: 12,
                      ),
                onMapCreated: (controller) {
                  final coords = route.geometryCoordinates;
                  if (coords.isNotEmpty) {
                    final geoJson = jsonEncode({
                      'type': 'FeatureCollection',
                      'features': [
                        {
                          'type': 'Feature',
                          'geometry': {
                            'type': 'LineString',
                            'coordinates': coords,
                          },
                          'properties': {},
                        }
                      ],
                    });
                    controller
                        .addSource(
                            'route-source',
                            GeojsonSourceProperties(data: geoJson))
                        .then((_) => controller.addLineLayer(
                              'route-source',
                              'route-layer',
                              LineLayerProperties(
                                lineColor: '#1A432C',
                                lineWidth: 4.5,
                                lineCap: 'round',
                                lineJoin: 'round',
                              ),
                            ));
                  }
                },
                trackCameraPosition: false,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sequência de Entregas',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...route.stops.map((stop) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DeliveryStop(stop: stop),
              )),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.darkGreen),
            SizedBox(height: 16),
            Text(
              'Calculando rota...',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 48, color: AppColors.placeholder),
            SizedBox(height: 16),
            Text(
              'Nenhuma entrega em andamento hoje.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.placeholder),
              const SizedBox(height: 16),
              Text(
                'Não foi possível carregar a rota.\n$message',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: AppColors.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: Color(0x1A2E5729))),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(27),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation_outlined,
                  color: AppColors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Visualizar no Maps / Waze',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteStatCard extends StatelessWidget {
  const _RouteStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkGreen,
            AppColors.darkGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white60),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryStop extends StatelessWidget {
  const _DeliveryStop({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${stop.stopOrder}',
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stop.formattedAddress,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: AppColors.placeholder,
                height: 1.4,
              ),
            ),
          ),
          const Icon(Icons.location_on_outlined,
              color: AppColors.darkGreen, size: 18),
        ],
      ),
    );
  }
}
