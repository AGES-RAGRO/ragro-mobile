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
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:ragro_mobile/shared/widgets/app_notification.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  late final NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = getIt<NotificationsBloc>()
      ..add(const NotificationsUnreadCountRequested());
    final cartBloc = getIt<CartBloc>();
    if (cartBloc.state is CartInitial) {
      cartBloc.add(const CartStarted());
    }
    final homeBloc = getIt<HomeBloc>();
    if (homeBloc.state is HomeInitial) {
      homeBloc.add(const HomeStarted());
    }
  }

  @override
  void dispose() {
    _notificationsBloc.close();
    super.dispose();
  }

  Cart? _cartFromState(CartState state) => switch (state) {
    CartLoaded(:final cart) => cart,
    CartUpdating(:final cart) => cart,
    CartUpdateFailure(:final cart) => cart,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationsBloc,
      child: BlocListener<CartBloc, CartState>(
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
                        BlocBuilder<NotificationsBloc, NotificationsState>(
                          builder: (context, state) {
                            return _NavItem(
                              icon: Icons.notifications_none,
                              activeIcon: Icons.notifications,
                              label: 'Notificações',
                              isActive:
                                  widget.navigationShell.currentIndex == 4,
                              badgeCount: _unreadCountFromState(state),
                              onTap: () => _onTap(4),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  int _unreadCountFromState(NotificationsState state) {
    return switch (state) {
      NotificationsInitial(:final unreadCount) => unreadCount,
      NotificationsLoading(:final unreadCount) => unreadCount,
      NotificationsLoaded(:final unreadCount) => unreadCount,
      NotificationsFailure(:final unreadCount) => unreadCount,
    };
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NavIconWithBadge(
              icon: isActive ? activeIcon : icon,
              color: isActive ? AppColors.darkGreen : AppColors.placeholder,
              badgeCount: badgeCount,
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

class _NavIconWithBadge extends StatelessWidget {
  const _NavIconWithBadge({
    required this.icon,
    required this.color,
    required this.badgeCount,
  });

  final IconData icon;
  final Color color;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final visibleCount = badgeCount > 99 ? '99+' : badgeCount.toString();

    return SizedBox(
      width: 32,
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          if (badgeCount > 0)
            Positioned(
              top: -3,
              right: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                child: Text(
                  visibleCount,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    height: 1,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
