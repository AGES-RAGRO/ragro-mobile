import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:ragro_mobile/shared/widgets/app_notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const NotificationsStarted());
  }

  @override
  Widget build(BuildContext context) {
    return const _NotificationsView();
  }
}

enum _NotificationFilter { all, unread }

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  _NotificationFilter _filter = _NotificationFilter.all;

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
            children: [
              const _NotificationsHeader(),
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
                    final unreadCount = _unreadCountFromState(state);

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

                    final filteredNotifications = _filterNotifications(
                      notifications,
                    );

                    return Column(
                      children: [
                        _NotificationsActions(
                          unreadCount: unreadCount,
                          selectedFilter: _filter,
                          onFilterChanged: (filter) {
                            setState(() => _filter = filter);
                          },
                        ),
                        Expanded(
                          child: _NotificationsContent(
                            notifications: filteredNotifications,
                            filter: _filter,
                            isRefreshing: state is NotificationsLoading,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AppNotificationEntity> _filterNotifications(
    List<AppNotificationEntity> notifications,
  ) {
    return switch (_filter) {
      _NotificationFilter.all => notifications,
      _NotificationFilter.unread =>
        notifications.where((notification) => !notification.read).toList(),
    };
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

  int _unreadCountFromState(NotificationsState state) {
    return switch (state) {
      NotificationsInitial(:final unreadCount) => unreadCount,
      NotificationsLoading(:final unreadCount) => unreadCount,
      NotificationsLoaded(:final unreadCount) => unreadCount,
      NotificationsFailure(:final unreadCount) => unreadCount,
    };
  }
}

Future<void> _refreshNotifications(BuildContext context) {
  final bloc = context.read<NotificationsBloc>();
  final completed = bloc.stream.firstWhere(
    (state) => state is NotificationsLoaded || state is NotificationsFailure,
  );

  bloc.add(const NotificationsRefreshed());
  return completed.then<void>((_) {});
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.darkGreen,
                size: 24,
              ),
            ),
          ),
          const Text(
            'Notificações',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsActions extends StatelessWidget {
  const _NotificationsActions({
    required this.unreadCount,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final int unreadCount;
  final _NotificationFilter selectedFilter;
  final ValueChanged<_NotificationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 24,
            child: unreadCount > 0
                ? TextButton(
                    onPressed: () {
                      context.read<NotificationsBloc>().add(
                        const NotificationsAllMarkedAsRead(),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.darkGreen,
                      textStyle: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    child: const Text('Marcar todas como lidas'),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  label: 'Todas',
                  selected: selectedFilter == _NotificationFilter.all,
                  onTap: () => onFilterChanged(_NotificationFilter.all),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _FilterButton(
                  label: 'Não lidas',
                  selected: selectedFilter == _NotificationFilter.unread,
                  onTap: () => onFilterChanged(_NotificationFilter.unread),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Material(
        color: selected ? AppColors.darkGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.darkGreen),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selected ? AppColors.white : AppColors.darkGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent({
    required this.notifications,
    required this.filter,
    required this.isRefreshing,
  });

  final List<AppNotificationEntity> notifications;
  final _NotificationFilter filter;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return _EmptyNotifications(filter: filter);
    }

    final list = _NotificationsList(notifications: notifications);
    if (!isRefreshing) return list;

    return Stack(children: [list, const _LoadingOverlay()]);
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<AppNotificationEntity> notifications;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.darkGreen,
      onRefresh: () => _refreshNotifications(context),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
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
    final timeLabel = _formatTime(notification.createdAt);

    return Material(
      color: read ? AppColors.white : const Color(0xFFF2FBF6),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          if (!read) {
            context.read<NotificationsBloc>().add(
              NotificationMarkedAsRead(notification.id),
            );
          }
          final base =
              GoRouterState.of(context).matchedLocation.startsWith('/producer')
              ? '/producer'
              : '/customer';
          context.push('$base/notifications/detail', extra: notification);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: read ? const Color(0xFFD5E8DD) : const Color(0xFFBFE3CD),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: read ? FontWeight.w500 : FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF9EB3C8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!read)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 3, right: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.darkGreen,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 8),
                    const SizedBox(height: 10),
                    Text(
                      timeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w400,
                        fontSize: 9,
                        color: Color(0xFF9EB3C8),
                      ),
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

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final isToday =
        now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        yesterday.year == localDate.year &&
        yesterday.month == localDate.month &&
        yesterday.day == localDate.day;

    if (isToday) {
      return DateFormat('HH:mm').format(localDate);
    }
    if (isYesterday) {
      return DateFormat("'Ontem,' HH:mm").format(localDate);
    }
    if (now.year == localDate.year) {
      return DateFormat('dd/MM').format(localDate);
    }
    return DateFormat('dd/MM/yyyy').format(localDate);
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.filter});

  final _NotificationFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      _NotificationFilter.all => 'Sem notificações no momento',
      _NotificationFilter.unread => 'Nenhuma notificação não lida',
    };

    return RefreshIndicator(
      color: AppColors.darkGreen,
      onRefresh: () => _refreshNotifications(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          const Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.placeholder,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              message,
              style: const TextStyle(
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
