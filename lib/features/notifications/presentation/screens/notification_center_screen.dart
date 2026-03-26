import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/features/notifications/domain/entities/notification_entity.dart';
import 'package:style_cart/features/notifications/presentation/providers/notification_notifier.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationAppBar(state: state, notifier: notifier),
            _FilterChipsRow(state: state, notifier: notifier),
            Expanded(
              child: state.isLoading
                  ? const _LoadingList()
                  : state.notifications.isEmpty
                      ? const _EmptyState()
                      : _NotificationsList(
                          notifications: state.notifications,
                          notifier: notifier,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationAppBar extends StatelessWidget {
  final NotificationState state;
  final NotificationNotifier notifier;

  const _NotificationAppBar({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.unreadCount > 0)
                Text(
                  '${state.unreadCount} unread',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ),
          if (state.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () => _showClearAllDialog(context, notifier),
            ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, NotificationNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Clear all notifications?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete all your notifications.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final NotificationState state;
  final NotificationNotifier notifier;

  const _FilterChipsRow({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final filterOptions = [
      ('all', 'All'),
      ('order_update', 'Orders'),
      ('promotion', 'Promos'),
      ('new_arrival', 'Arrivals'),
      ('system', 'System'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filterOptions.map((filter) {
          final isActive = state.activeFilter == filter.$1;
          final count = filter.$1 == 'all'
              ? state.notifications.length
              : state.notifications
                  .where((n) => n.type.value == filter.$1)
                  .length;

          return GestureDetector(
            onTap: () => notifier.setFilter(filter.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderDefault,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.$2,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.backgroundElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 9,
                            color: isActive ? Colors.white : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final NotificationNotifier notifier;

  const _NotificationsList({
    required this.notifications,
    required this.notifier,
  });

  Map<String, List<NotificationEntity>> _groupByDate(List<NotificationEntity> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<NotificationEntity>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (final n in notifications) {
      final notifDate = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (notifDate == today) {
        groups['Today']!.add(n);
      } else if (notifDate == yesterday) {
        groups['Yesterday']!.add(n);
      } else if (notifDate.isAfter(weekAgo)) {
        groups['This Week']!.add(n);
      } else {
        groups['Earlier']!.add(n);
      }
    }

    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(notifications);
    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: keys.fold<int>(0, (sum, key) => sum + grouped[key]!.length + 1),
      itemBuilder: (context, index) {
        int currentCount = 0;
        for (final key in keys) {
          if (index == currentCount) {
            // Group header
            return _GroupHeader(title: key);
          }
          currentCount++;
          if (index < currentCount + grouped[key]!.length) {
            final notification = grouped[key]![index - currentCount];
            return _NotificationTile(
              notification: notification,
              notifier: notifier,
            );
          }
          currentCount += grouped[key]!.length;
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final NotificationNotifier notifier;

  const _NotificationTile({
    required this.notification,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => notifier.deleteNotification(notification.notificationId),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            notifier.markAsRead(notification.notificationId);
          }
          if (notification.hasRoute) {
            context.go(notification.data.route!);
          } else if (notification.type == NotificationType.orderUpdate &&
              notification.data.orderId != null) {
            context.go(
              RouteNames.orderTrackingName,
              pathParameters: {'orderId': notification.data.orderId!},
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderDefault
                  : notification.type.color.withOpacity(0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: notification.type.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: notification.type.color.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        notification.type.icon,
                        color: notification.type.color,
                        size: 22,
                      ),
                    ),
                    if (!notification.isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundCard,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: notification.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.type.displayTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: notification.type.color,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          notification.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: notification.isRead ? AppColors.textSecondary : Colors.white,
                        fontSize: 14,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.type == NotificationType.orderUpdate &&
                        notification.data.orderId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'Track Order →',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
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
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.backgroundCard,
        highlightColor: AppColors.backgroundElevated,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'All caught up!',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No notifications yet.\n'
            'We\'ll notify you about orders\n'
            'and exclusive deals.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
