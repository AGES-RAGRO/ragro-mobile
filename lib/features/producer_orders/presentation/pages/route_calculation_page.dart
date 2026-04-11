// Screen: Cálculo de Rota
// User Story: US-33 / US-34 — View Today's Deliveries / View Delivery Route
// Epic: EPIC 9 — Logistics and Routing
// Routes: GET /orders/today (delivery route based on today's in-delivery orders)
// TODO: Integrate Google Maps SDK for real route visualization

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class RouteCalculationPage extends StatelessWidget {
  const RouteCalculationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                backgroundColor: AppColors.white,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back, color: AppColors.black),
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
                  child: Container(color: const Color(0x1A2E5729), height: 1),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats cards row
                      Row(
                        children: [
                          Expanded(
                            child: _RouteStatCard(
                              label: 'Duração',
                              value: '40 min',
                              icon: Icons.access_time_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RouteStatCard(
                              label: 'Distância Total',
                              value: '10.2km',
                              icon: Icons.route_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Optimization description
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FBF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkGreen.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_outlined,
                              size: 18,
                              color: AppColors.darkGreen,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Rota otimizada para menor tempo de entrega considerando o trânsito atual.',
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

                      // Map placeholder
                      // TODO: Replace with Google Maps widget when Maps SDK is integrated
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 128,
                          width: double.infinity,
                          color: const Color(0xFF1A432C),
                          child: Stack(
                            children: [
                              // Map grid lines (decorative)
                              CustomPaint(
                                size: const Size(double.infinity, 128),
                                painter: _MapGridPainter(),
                              ),
                              // Center pin
                              const Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 40,
                                  color: Colors.white38,
                                ),
                              ),
                              // Bottom label
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Mapa indisponível — integração em breve',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivery sequence header
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

                      // Delivery stops
                      // TODO: Replace with real stops from /orders/today response
                      const _DeliveryStop(
                        stopNumber: 1,
                        placeName: 'Mercado Central',
                        street: 'Rua dos Andradas, 1234',
                        cityStateZip: 'Porto Alegre – RS, 90020-005',
                      ),
                      const SizedBox(height: 10),
                      const _DeliveryStop(
                        stopNumber: 2,
                        placeName: 'Condomínio Verde',
                        street: 'Av. Ipiranga, 6681',
                        cityStateZip: 'Porto Alegre – RS, 90619-900',
                      ),
                      const SizedBox(height: 10),
                      const _DeliveryStop(
                        stopNumber: 3,
                        placeName: 'Casa da Ana',
                        street: 'Rua Comendador Coruja, 320',
                        cityStateZip: 'Porto Alegre – RS, 90570-030',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.97),
                border: const Border(top: BorderSide(color: Color(0x1A2E5729))),
              ),
              child: GestureDetector(
                onTap: () {
                  // TODO: Open Google Maps or in-app navigation when Maps SDK is integrated
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navegação por mapa disponível em breve'),
                    ),
                  );
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.navigation_outlined,
                        color: AppColors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Visualizar Melhor Rota',
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
            ),
          ),
        ],
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
          colors: [AppColors.darkGreen, AppColors.darkGreen.withOpacity(0.8)],
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
  const _DeliveryStop({
    required this.stopNumber,
    required this.placeName,
    required this.street,
    required this.cityStateZip,
  });

  final int stopNumber;
  final String placeName;
  final String street;
  final String cityStateZip;

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
          // Stop number badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$stopNumber',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  street,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                ),
                Text(
                  cityStateZip,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.darkGreen,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
