// Screen: Producer Profile & Dashboard (Perfil do Produtor)
// User Story: US-24 — View Producer Profile and Dashboard
// Epic: EPIC 4 — Producer Features
// Routes: GET /producers/me/dashboard

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';

class ProducerProfilePage extends StatelessWidget {
  const ProducerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProducerManagementBloc>()
            ..add(const ProducerManagementStarted()),
      child: const _ProducerProfileView(),
    );
  }
}

class _ProducerProfileView extends StatelessWidget {
  const _ProducerProfileView();

  Future<void> _openEditProfile(BuildContext context) async {
    await context.push('/producer/profile/edit');
    if (!context.mounted) return;
    context.read<ProducerManagementBloc>().add(
      const ProducerManagementRefreshed(),
    );
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocBuilder<ProducerManagementBloc, ProducerManagementState>(
          builder: (context, state) {
            if (state is ProducerManagementLoading ||
                state is ProducerManagementInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkGreen),
              );
            }
            if (state is ProducerManagementFailure) {
              return Center(child: Text(state.message));
            }
            if (state is! ProducerManagementLoaded) {
              return const SizedBox.shrink();
            }
            return _buildContent(context, state.dashboard);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProducerDashboard dashboard) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.darkGreen),
                  onPressed: () => context.push('/producer/profile/settings'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cover photo + overlapping avatar
          SizedBox(
            height: 210,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: dashboard.coverUrl.isNotEmpty
                      ? Image.network(
                          dashboard.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const ColoredBox(color: Color(0xFFE0E0E0)),
                        )
                      : const ColoredBox(color: Color(0xFFE0E0E0)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.white,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: AppColors.darkGreen.withOpacity(
                              0.1,
                            ),
                            backgroundImage: dashboard.avatarUrl.isNotEmpty
                                ? NetworkImage(dashboard.avatarUrl)
                                : null,
                            child: dashboard.avatarUrl.isEmpty
                                ? Text(
                                    dashboard.producerName.isNotEmpty
                                        ? dashboard.producerName[0]
                                        : 'P',
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 40,
                                      color: AppColors.darkGreen,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.darkGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Name + edit button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    dashboard.producerName,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dashboard.producerTitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openEditProfile(context),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar Perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkGreen,
                      side: const BorderSide(color: AppColors.darkGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Weekly schedule
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horário de atendimento',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _DaySchedule(day: 'Seg'),
                      _DaySchedule(day: 'Ter'),
                      _DaySchedule(day: 'Qua'),
                      _DaySchedule(day: 'Qui'),
                      _DaySchedule(day: 'Sex'),
                      _DaySchedule(day: 'Sáb', active: false),
                      _DaySchedule(day: 'Dom', active: false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Dashboard title + month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkGreen),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dashboard.currentMonth,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.darkGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Total Sales card (dark green)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VENDAS TOTAIS',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white54,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatPrice(dashboard.totalSales),
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              dashboard.salesGrowthPercent >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${dashboard.salesGrowthPercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Two stat cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pedidos',
                    value: '${dashboard.totalOrders}',
                    change:
                        '+${dashboard.ordersGrowthPercent.toStringAsFixed(0)}%',
                    positive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Estoque',
                    value: '${dashboard.stockPercentage.toStringAsFixed(0)}%',
                    change:
                        '${dashboard.stockChangePercent.toStringAsFixed(0)}%',
                    positive: dashboard.stockChangePercent >= 0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Visão Semanal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Visão Semanal',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WeeklyChart(data: dashboard.weeklyChartData),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DaySchedule extends StatelessWidget {
  const _DaySchedule({required this.day, this.active = true});
  final String day;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.darkGreen : AppColors.placeholder,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: active ? AppColors.darkGreen : AppColors.placeholder,
          ),
        ),
        if (active)
          const Text(
            '14:00\n18:30',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              color: AppColors.placeholder,
              height: 1.3,
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
  });

  final String label;
  final String value;
  final String change;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.placeholder,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                positive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: positive ? AppColors.lightGreen : AppColors.red,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: positive ? AppColors.lightGreen : AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});
  final List<double> data;

  static const _days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold(0.0, (m, v) => v > m ? v : m);
    final activeDay = data.indexOf(maxVal);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(data.length, (i) {
                final ratio = maxVal > 0 ? data[i] / maxVal : 0.0;
                final isActive = i == activeDay;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 100 * ratio,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.darkGreen
                            : AppColors.darkGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_days.length, (i) {
              final isActive = i == activeDay;
              return SizedBox(
                width: 28,
                child: Text(
                  _days[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                    color: isActive
                        ? AppColors.darkGreen
                        : AppColors.placeholder,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
