import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:ragro_mobile/shared/widgets/app_notification.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<NotificationsBloc>()..add(const NotificationsStarted()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsFailure) {
          AppNotification.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Text(
                  'Notificações',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<NotificationsBloc, NotificationsState>(
                  builder: (context, state) {
                    if (state is NotificationsInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkGreen,
                        ),
                      );
                    }

                    final notifications = _notificationsFromState(state);

                    if (state is NotificationsLoading &&
                        notifications.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkGreen,
                        ),
                      );
                    }

                    if (state is NotificationsFailure &&
                        notifications.isEmpty) {
                      return _NotificationsError(message: state.message);
                    }

                    if (notifications.isEmpty) {
                      return const _EmptyNotifications();
                    }

                    final list = _NotificationsList(
                      notifications: notifications,
                    );

                    if (state is NotificationsLoading) {
                      return Stack(
                        children: [
                          list,
                          const _LoadingOverlay(),
                        ],
                      );
                    }

                    return list;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AppNotificationEntity> _notificationsFromState(
    NotificationsState state,
  ) {
    return switch (state) {
      NotificationsLoaded(:final notifications) => notifications,
      NotificationsLoading(:final previousNotifications) =>
        previousNotifications,
      NotificationsFailure(:final previousNotifications) =>
        previousNotifications,
      _ => const <AppNotificationEntity>[],
    };
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<AppNotificationEntity> notifications;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.darkGreen,
      onRefresh: () async {
        context.read<NotificationsBloc>().add(const NotificationsRefreshed());
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationTile(notification: notification);
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final read = notification.read;

    return Material(
      color: read ? AppColors.white : const Color(0xFFEFFBF3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: read
            ? null
            : () => context.read<NotificationsBloc>().add(
                  NotificationMarkedAsRead(notification.id),
                ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: read ? const Color(0xFFE5E7EB) : AppColors.lightGreen,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: read
                      ? const Color(0xFFF1F5F9)
                      : const Color(0x1A008148),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  read
                      ? Icons.notifications_none
                      : Icons.notifications_active_outlined,
                  color: read ? AppColors.placeholder : AppColors.darkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight:
                                  read ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (!read) ...[
                          const SizedBox(width: 8),
                          const _UnreadDot(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 1.3,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              notification.createdAt,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.placeholder,
                            ),
                          ),
                        ),
                        _ReadStatusLabel(read: read),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadStatusLabel extends StatelessWidget {
  const _ReadStatusLabel({required this.read});

  final bool read;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: read ? const Color(0xFFF1F5F9) : const Color(0x1A008148),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        read ? 'Lida' : 'Não lida',
        style: TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: read ? AppColors.placeholder : AppColors.darkGreen,
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.only(top: 5),
      decoration: const BoxDecoration(
        color: AppColors.lightGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.darkGreen,
      onRefresh: () async {
        context.read<NotificationsBloc>().add(const NotificationsRefreshed());
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.placeholder,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Nenhuma notificação por enquanto',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 16,
                color: AppColors.placeholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 14,
                color: AppColors.placeholder,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<NotificationsBloc>().add(
                    const NotificationsRefreshed(),
                  ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.white.withValues(alpha: 0.65),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ),
    );
  }
}
