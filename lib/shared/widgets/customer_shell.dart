import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:ragro_mobile/features/cart/presentation/widgets/cart_summary_bar.dart';
import 'package:ragro_mobile/shared/widgets/app_notification.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  @override
  void initState() {
    super.initState();
    final bloc = getIt<CartBloc>();
    if (bloc.state is CartInitial) {
      bloc.add(const CartStarted());
    }
  }

  Cart? _cartFromState(CartState state) => switch (state) {
    CartLoaded(:final cart) => cart,
    CartUpdating(:final cart) => cart,
    CartUpdateFailure(:final cart) => cart,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      bloc: getIt<CartBloc>(),
      listenWhen: (_, current) =>
          current is CartUpdateFailure || current is CartFailure,
      listener: (context, state) {
        final message = switch (state) {
          CartUpdateFailure(:final message) => message,
          CartFailure(:final message) => message,
          _ => null,
        };
        if (message != null) AppNotification.showError(context, message);
      },
      child: Scaffold(
        body: widget.navigationShell,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<CartBloc, CartState>(
                  bloc: getIt<CartBloc>(),
                  builder: (context, state) {
                    final cart = _cartFromState(state);
                    if (cart == null || cart.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return CartSummaryBar(
                      itemCount: cart.itemCount,
                      totalAmount: cart.totalAmount,
                    );
                  },
                ),
                SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Início',
                        isActive: widget.navigationShell.currentIndex == 0,
                        onTap: () => _onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.shopping_bag_outlined,
                        activeIcon: Icons.shopping_bag,
                        label: 'Pedidos',
                        isActive: widget.navigationShell.currentIndex == 1,
                        onTap: () => _onTap(1),
                      ),
                      _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Perfil',
                        isActive: widget.navigationShell.currentIndex == 2,
                        onTap: () => _onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.search,
                        activeIcon: Icons.search,
                        label: 'Pesquisa',
                        isActive: widget.navigationShell.currentIndex == 3,
                        onTap: () => _onTap(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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
