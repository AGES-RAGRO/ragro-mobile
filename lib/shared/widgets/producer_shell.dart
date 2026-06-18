import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';

class ProducerShell extends StatefulWidget {
  const ProducerShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ProducerShell> createState() => _ProducerShellState();
}

class _ProducerShellState extends State<ProducerShell> {
  late final NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = getIt<NotificationsBloc>()
      ..add(const NotificationsUnreadCountRequested());
  }

  @override
  void dispose() {
    _notificationsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationsBloc,
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
            child: SizedBox(
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
                    label: 'Estoque',
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
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      return _NavItem(
                        icon: Icons.notifications_none,
                        activeIcon: Icons.notifications,
                        label: 'Notificações',
                        isActive: widget.navigationShell.currentIndex == 3,
                        badgeCount: _unreadCountFromState(state),
                        onTap: () => _onTap(3),
                      );
                    },
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
