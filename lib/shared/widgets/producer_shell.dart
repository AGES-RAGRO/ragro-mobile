import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';

class ProducerShell extends StatelessWidget {
  const ProducerShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Início',
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag,
                  label: 'Estoque',
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Perfil',
                  isActive: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    // Stock tab (1): reload the inventory on reopen so stock changes show up
    // without restarting the app. Initial load is handled by the page's loader.
    if (index == 1) {
      final bloc = getIt<InventoryBloc>();
      if (bloc.state is! InventoryInitial) {
        bloc.add(const InventoryRefreshed());
      }
    }
    // Profile tab (2): reload the dashboard on reopen so fresh data shows up
    // (e.g. after a delivery) without restarting the app. The initial load is
    // handled by the page's own loader.
    if (index == 2) {
      final bloc = getIt<ProducerManagementBloc>();
      if (bloc.state is! ProducerManagementInitial) {
        bloc.add(const ProducerManagementRefreshed());
      }
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.darkGreen : AppColors.placeholder,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isActive ? AppColors.darkGreen : AppColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
