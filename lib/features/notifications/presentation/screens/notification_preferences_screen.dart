import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  Map<String, bool> _localPrefs = {
    'orderUpdates': true,
    'promotions': true,
    'newArrivals': true,
  };
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = ref.watch(currentUserProvider);
      if (user != null) {
        _localPrefs = Map<String, bool>.from(user.notificationPrefs);
        _initialized = true;
      }
    }
  }

  Future<void> _updatePref(String key, bool value) async {
    // Optimistic update
    final previousValue = _localPrefs[key] ?? true;
    setState(() => _localPrefs[key] = value);

    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null) return;

    try {
      await ref
          .read(firestoreProvider)
          .collection(FirestoreConstants.users)
          .doc(userId)
          .update({'notificationPrefs.$key': value});
    } catch (e) {
      // Revert on error
      setState(() => _localPrefs[key] = previousValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save preference'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'PUSH NOTIFICATIONS', textTheme: textTheme),
            const SizedBox(height: 12),
            _PreferenceToggle(
              title: 'Order Updates',
              subtitle: 'Shipped, delivered, tracking info',
              icon: Icons.local_shipping_outlined,
              iconColor: AppColors.primary,
              value: _localPrefs['orderUpdates'] ?? true,
              onChanged: (v) => _updatePref('orderUpdates', v),
            ),
            _PreferenceToggle(
              title: 'Promotions & Deals',
              subtitle: 'Sales, discount codes, flash deals',
              icon: Icons.local_offer_outlined,
              iconColor: AppColors.gold,
              value: _localPrefs['promotions'] ?? true,
              onChanged: (v) => _updatePref('promotions', v),
            ),
            _PreferenceToggle(
              title: 'New Arrivals',
              subtitle: 'Latest collections and drops',
              icon: Icons.new_releases_outlined,
              iconColor: AppColors.successTeal,
              value: _localPrefs['newArrivals'] ?? true,
              onChanged: (v) => _updatePref('newArrivals', v),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'SYSTEM', textTheme: textTheme),
            const SizedBox(height: 12),
            const _PreferenceToggle(
              title: 'Security Alerts',
              subtitle: 'Login from new device, password changes',
              icon: Icons.security_outlined,
              iconColor: AppColors.warning,
              value: true,
              onChanged: null,
              isLocked: true,
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'ABOUT NOTIFICATIONS', textTheme: textTheme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderDefault,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can also manage notification permissions in your device settings.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => AppSettings.openAppSettings(),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open Device Settings'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.borderDefault,
                ),
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const _SectionTitle({required this.title, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textTheme.labelMedium?.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLocked;

  const _PreferenceToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    this.onChanged,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderDefault,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18)
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.backgroundElevated,
            ),
        ],
      ),
    );
  }
}
