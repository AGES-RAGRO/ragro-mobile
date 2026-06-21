import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';

/// Top-right notification bell with an unread badge. Reads the single app-level
/// [NotificationsBloc] (same source of truth as before), and pushes the
/// role-appropriate notifications route so the back button pops to the origin.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.color});

  /// Icon tint; defaults to the dark green used across the app.
  final Color? color;

  void _open(BuildContext context) {
    final type = getIt<AuthLocalDataSource>().getUserType();
    final isProducer = type == 'producer' || type == 'farmer';
    context.push(
      isProducer ? '/producer/notifications' : '/customer/notifications',
    );
  }

  int _unreadCount(NotificationsState state) => switch (state) {
    NotificationsInitial(:final unreadCount) => unreadCount,
    NotificationsLoading(:final unreadCount) => unreadCount,
    NotificationsLoaded(:final unreadCount) => unreadCount,
    NotificationsFailure(:final unreadCount) => unreadCount,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final badgeCount = _unreadCount(state);
        final visibleCount = badgeCount > 99 ? '99+' : badgeCount.toString();

        return GestureDetector(
          onTap: () => _open(context),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 26,
                  color: color ?? AppColors.darkGreen,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
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
          ),
        );
      },
    );
  }
}
