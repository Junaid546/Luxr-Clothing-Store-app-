import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, user),
            _buildStatsRow(user, ref),
            _buildMenuSection(
              context,
              title: 'PERSONAL MANAGEMENT',
              items: [
                _MenuItemData(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'Admin Panel (Testing)',
                  onTap: () => context.push(RouteNames.adminDashboard),
                ),
                _MenuItemData(
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Orders',
                  onTap: () => context.push(RouteNames.myOrders),
                ),
                _MenuItemData(
                  icon: Icons.location_on_outlined,
                  label: 'Addresses',
                  onTap: () {
                    // TODO: Implement addresses
                  },
                ),
                _MenuItemData(
                  icon: Icons.payment_outlined,
                  label: 'Payment Methods',
                  onTap: () {
                    // TODO: Implement payment methods
                  },
                ),
                _MenuItemData(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  hasNotification: true,
                  onTap: () {
                    // TODO: Implement notifications
                  },
                ),
                _MenuItemData(
                  icon: Icons.star_outline,
                  label: 'StyleCart Rewards',
                  onTap: () {
                    // TODO: Implement rewards
                  },
                ),
              ],
            ),
            _buildMenuSection(
              context,
              title: 'SUPPORT',
              items: [
                _MenuItemData(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                  onTap: () {
                    // TODO: Implement help center
                  },
                ),
              ],
            ),
            _buildSignOutButton(context, ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3D1010), // deep wine
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(RouteNames.shop),
                  ),
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement settings
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: user.photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: user.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.backgroundCard,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundCard,
                              child: const Icon(Icons.person, size: 50, color: AppColors.textMuted),
                            ),
                          )
                        : Container(
                            color: AppColors.backgroundCard,
                            child: const Icon(Icons.person, size: 50, color: AppColors.textMuted),
                          ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(
                '${user.eliteStatus} ELITE STATUS',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserEntity user, WidgetRef ref) {
    final wishlistItems = ref.watch(wishlistNotifierProvider).items;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '${user.totalOrders}', label: 'ORDERS'),
          _buildDivider(),
          _StatItem(value: '${wishlistItems.length}', label: 'WISHLIST'),
          _buildDivider(),
          const _StatItem(value: '0', label: 'REVIEWS'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.borderDefault,
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _MenuItem(data: item)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(context, ref),
        icon: const Icon(Icons.logout, color: AppColors.primary),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasNotification;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasNotification = false,
  });
}

class _MenuItem extends StatelessWidget {
  final _MenuItemData data;

  const _MenuItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(data.icon, color: AppColors.gold, size: 20),
        ),
        title: Text(
          data.label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.hasNotification)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
        onTap: data.onTap,
      ),
    );
  }
}
