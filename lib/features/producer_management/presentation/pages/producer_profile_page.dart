// Screen: Producer Profile & Dashboard (Perfil do Produtor)
// User Story: US-24 â€” View Producer Profile and Dashboard
// Epic: EPIC 4 â€” Producer Features
// Routes: GET /producers/me/dashboard

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    return NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(price);
  }

  String _formatPercent(double value) {
    final decimals = value.truncateToDouble() == value ? 0 : 1;
    return '${value.toStringAsFixed(decimals).replaceAll('.', ',')}%';
  }

  String _formatSignedPercent(double value) {
    final signal = value > 0 ? '+' : '';
    return '$signal${_formatPercent(value)}';
  }

  String _monthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    if (month < 1 || month > 12) return 'Atual';
    return months[month - 1];
  }

  String _periodLabel(int month, int year) {
    return '${_monthName(month)}/${year.toString().substring(2)}';
  }

  String _previousMonthName(int month) {
    final previousMonth = month == 1 ? 12 : month - 1;
    return _monthName(previousMonth);
  }

  Future<void> _openPeriodSelector(
    BuildContext context,
    ProducerManagementLoaded state,
  ) async {
    var selectedMonth = state.selectedMonth;
    var selectedYear = state.selectedYear;
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (index) => currentYear - index);

    final result = await showDialog<({int month, int year})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtrar dashboard'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedMonth,
                    decoration: const InputDecoration(labelText: 'Mês'),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(_monthName(month)),
                      );
                    }),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedMonth = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedYear,
                    decoration: const InputDecoration(labelText: 'Ano'),
                    items: years
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedYear = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    dialogContext,
                  ).pop((month: selectedMonth, year: selectedYear)),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !context.mounted) return;
    context.read<ProducerManagementBloc>().add(
      ProducerDashboardPeriodChanged(month: result.month, year: result.year),
    );
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
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProducerManagementLoaded state) {
    final dashboard = state.dashboard;
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
                            backgroundColor: AppColors.darkGreen.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage: dashboard.avatarUrl.isNotEmpty
                                ? NetworkImage(dashboard.avatarUrl)
                                : null,
                            onBackgroundImageError:
                                dashboard.avatarUrl.isNotEmpty
                                ? (_, __) {}
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
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push(
                      '/producer/profile/reviews',
                      extra: {
                        'producerId': dashboard.producerId,
                        'producerName': dashboard.producerName,
                        'producerLocation': '',
                        'averageRating': dashboard.averageRating,
                        'totalReviews': dashboard.totalReviews,
                      },
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.darkGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dashboard.averageRating.toStringAsFixed(1)} (${dashboard.totalReviews} Avaliações)',
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.darkGreen,
                        ),
                      ],
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
              child: _ScheduleSection(availability: dashboard.availability),
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
                OutlinedButton(
                  onPressed: () => _openPeriodSelector(context, state),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    side: const BorderSide(color: AppColors.darkGreen),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    minimumSize: const Size(104, 42),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _periodLabel(state.selectedMonth, state.selectedYear),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
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
            child: _SalesCard(
              value: _formatPrice(dashboard.totalSales),
              percentText: _formatSignedPercent(dashboard.salesGrowthPercent),
              previousMonth: _previousMonthName(state.selectedMonth),
              positive: dashboard.salesGrowthPercent >= 0,
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
                    icon: Icons.shopping_cart_outlined,
                    iconColor: AppColors.darkGreen,
                    label: 'Pedidos',
                    value: '${dashboard.totalOrders}',
                    change:
                        '${_formatSignedPercent(dashboard.ordersGrowthPercent)} este mÃªs',
                    positive: dashboard.ordersGrowthPercent >= 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFFF08A24),
                    label: 'Estoque',
                    value: _formatPercent(dashboard.stockPercentage),
                    change:
                        '${_formatSignedPercent(dashboard.stockChangePercent)} este mÃªs',
                    positive: dashboard.stockChangePercent >= 0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SizedBox(height: 20),
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

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.availability});

  final List<DashboardAvailabilitySlot> availability;

  // UI order: Seg(1), Ter(2), Qua(3), Qui(4), Sex(5), Sáb(6), Dom(0)
  static const _days = [
    (label: 'Seg', weekday: 1),
    (label: 'Ter', weekday: 2),
    (label: 'Qua', weekday: 3),
    (label: 'Qui', weekday: 4),
    (label: 'Sex', weekday: 5),
    (label: 'Sáb', weekday: 6),
    (label: 'Dom', weekday: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final slotByWeekday = {for (final s in availability) s.weekday: s};

    return Column(
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
          children: _days.map((d) {
            final slot = slotByWeekday[d.weekday];
            return _DaySchedule(
              day: d.label,
              active: slot != null,
              opensAt: slot?.opensAt,
              closesAt: slot?.closesAt,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DaySchedule extends StatelessWidget {
  const _DaySchedule({
    required this.day,
    this.active = true,
    this.opensAt,
    this.closesAt,
  });

  final String day;
  final bool active;
  final String? opensAt;
  final String? closesAt;

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
        if (active && opensAt != null && closesAt != null)
          Text(
            '$opensAt\n$closesAt',
            textAlign: TextAlign.center,
            style: const TextStyle(
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

class _SalesCard extends StatelessWidget {
  const _SalesCard({
    required this.value,
    required this.percentText,
    required this.previousMonth,
    required this.positive,
  });

  final String value;
  final String percentText;
  final String previousMonth;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                positive ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VENDAS TOTAIS',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      percentText,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'em relação à $previousMonth',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String change;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 26),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: AppColors.placeholder,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: positive ? AppColors.lightGreen : AppColors.red,
            ),
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
    final maxVal = data.fold<double>(0, (m, v) => v > m ? v : m);
    final activeDay = data.indexOf(maxVal);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Visão Semanal',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'RELATÓRIO',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                            : AppColors.darkGreen.withValues(alpha: 0.1),
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
