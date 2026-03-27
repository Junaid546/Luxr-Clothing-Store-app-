import 'package:flutter/material.dart';
import 'package:style_cart/app/theme/app_colors.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const NotificationPermissionDialog({
    required this.onAllow,
    required this.onSkip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bell animation icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Stay in the Loop!',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Enable notifications to get real-time order updates, exclusive deals, and new arrival alerts.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Benefits list
            ...[
              (Icons.local_shipping_outlined, 'Status & tracking updates'),
              (Icons.local_offer_outlined, 'Exclusive deals & promotions'),
              (Icons.new_releases_outlined, 'New collection alerts'),
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(item.$1, color: AppColors.gold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.$2,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // Allow button
            ElevatedButton(
              onPressed: onAllow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Allow Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Skip button
            TextButton(
              onPressed: onSkip,
              child: const Text(
                'Not now',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
