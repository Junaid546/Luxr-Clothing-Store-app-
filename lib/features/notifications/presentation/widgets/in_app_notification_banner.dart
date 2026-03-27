import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/features/notifications/domain/entities/notification_entity.dart';
import 'package:style_cart/features/notifications/presentation/providers/notification_notifier.dart';

class InAppNotificationBanner extends ConsumerStatefulWidget {
  final Widget child;

  const InAppNotificationBanner({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState
    extends ConsumerState<InAppNotificationBanner>
    with TickerProviderStateMixin {

  // Currently displayed notification
  NotificationEntity? _currentNotification;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Auto-dismiss timer
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // off screen top
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0, end: 1.0,
    ).animate(_fadeController);

    // Listen to notification list for new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        notificationNotifierProvider
            .select((s) => s.notifications),
        (prev, next) {
          if (next.isEmpty) return;

          // Show banner for newest notification
          // only if it's new (not in previous list)
          if (next.length > (prev?.length ?? 0)) {
            final newest = next.first;
            // Only show if it was created very recently (within last 10 seconds)
            // to avoid showing old ones on initial load if stream updates
            if (DateTime.now().difference(newest.createdAt).inSeconds < 10) {
              _showBanner(newest);
            }
          }
        },
      );
    });
  }

  void _showBanner(NotificationEntity notification) {
    if (!mounted) return;

    // Don't show if we're already showing one
    _dismissTimer?.cancel();

    setState(() => _currentNotification = notification);

    _slideController.forward(from: 0);
    _fadeController.forward(from: 0);

    // Auto-dismiss after 4 seconds
    _dismissTimer = Timer(
      const Duration(seconds: 4),
      _dismissBanner,
    );
  }

  void _dismissBanner() {
    if (!mounted) return;
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() => _currentNotification = null);
      }
    });
    _slideController.reverse();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        widget.child,

        // Overlay banner (shown on top)
        if (_currentNotification != null)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _BannerContent(
                    notification: _currentNotification!,
                    onDismiss: _dismissBanner,
                    onTap: () {
                      _dismissBanner();
                      _handleBannerTap(
                        _currentNotification!,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleBannerTap(NotificationEntity notification) {
    // Mark as read
    ref.read(notificationNotifierProvider.notifier)
        .markAsRead(notification.notificationId);

    // Navigate to relevant screen
    if (notification.hasRoute) {
      context.go(notification.data.route!);
    } else if (
      notification.type == NotificationType.orderUpdate &&
      notification.data.orderId != null
    ) {
      context.goNamed(
        RouteNames.orderTrackingName,
        pathParameters: {'orderId': notification.data.orderId!},
      );
    }
  }
}

// Banner content widget
class _BannerContent extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _BannerContent({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragUpdate: (details) {
        // Swipe up to dismiss
        if (details.delta.dy < -5) onDismiss();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Glass morphism effect
          color: const Color(0xFF1A1A2E).withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.type.color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Notification type icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: notification.type.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: notification.type.color.withOpacity(0.4),
                ),
              ),
              child: Icon(
                notification.type.icon,
                color: notification.type.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App name + time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'StyleCart',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'now',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Body
                  Text(
                    notification.body,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dismiss X button
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                color: AppColors.textMuted,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
