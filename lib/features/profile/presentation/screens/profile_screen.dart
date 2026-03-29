import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/notifications/data/providers/notification_providers.dart';
import 'package:style_cart/features/profile/data/models/profile_settings_model.dart';
import 'package:style_cart/features/profile/presentation/providers/profile_providers.dart';
import 'package:style_cart/features/wishlist/presentation/providers/wishlist_notifier.dart';

const _testingAdminUid = 'k0xv31OodpdwHtwnJACc51VCuan1';
const _profileAccent = AppColors.primary;
const _profileSurface = AppColors.backgroundCard;
const _profilePanel = AppColors.backgroundElevated;
const _profileHighlight = AppColors.gold;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated || _isUploadingPhoto) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() => _isUploadingPhoto = true);

    final result = await ref
        .read(profileRepositoryProvider)
        .uploadProfilePhoto(
          userId: authState.user.uid,
          localPath: pickedFile.path,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isUploadingPhoto = false);

    result.fold((failure) => _showSnackBar(failure.message, isError: true), (
      _,
    ) async {
      await ref.read(authNotifierProvider.notifier).refreshCurrentUser();
      if (!mounted) {
        return;
      }
      _showSnackBar('Profile photo updated.');
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : _profileAccent,
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _profileSurface,
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileAccent,
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final settingsAsync = ref.watch(profileSettingsProvider);
    final settings = settingsAsync.valueOrNull ?? const ProfileSettingsModel();
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final wishlistItems = ref.watch(wishlistNotifierProvider).items;
    final hasUnread =
        unreadCountAsync.valueOrNull != null && unreadCountAsync.value! > 0;
    final canUseAdminPanel = user.isAdmin || user.uid == _testingAdminUid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              user: user,
              settings: settings,
              isUploadingPhoto: _isUploadingPhoto,
              onPhotoTap: _pickAndUploadPhoto,
            ),
          ),
          SliverToBoxAdapter(
            child: _StatsStrip(
              totalOrders: user.totalOrders,
              wishlistCount: wishlistItems.length,
              addressCount: settings.addresses.length,
            ),
          ),
          SliverToBoxAdapter(child: _HighlightsSection(settings: settings)),
          SliverToBoxAdapter(
            child: _MenuSection(
              title: 'Account',
              items: [
                if (canUseAdminPanel)
                  _MenuItemData(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Admin Panel (Testing)',
                    subtitle: 'Open product, order, and dashboard tools.',
                    onTap: () => context.push(RouteNames.adminDashboard),
                  ),
                _MenuItemData(
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                  subtitle: 'Track active, delivered, and past purchases.',
                  onTap: () => context.push(RouteNames.myOrders),
                ),
                _MenuItemData(
                  icon: Icons.location_on_outlined,
                  title: 'Address Book',
                  subtitle: settings.addresses.isEmpty
                      ? 'Add your first saved delivery address.'
                      : '${settings.addresses.length} saved address${settings.addresses.length == 1 ? '' : 'es'}.',
                  onTap: () => context.push(RouteNames.profileAddresses),
                ),
                _MenuItemData(
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  subtitle: settings.paymentMethods.isEmpty
                      ? 'Save Google Play, PayPal, or MasterCard.'
                      : '${settings.paymentMethods.length} saved payment method${settings.paymentMethods.length == 1 ? '' : 's'}.',
                  onTap: () => context.push(RouteNames.profilePaymentMethods),
                ),
                _MenuItemData(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  subtitle: hasUnread
                      ? 'You have unread updates waiting for you.'
                      : 'Review your latest alerts and order updates.',
                  hasNotification: hasUnread,
                  onTap: () => context.push(RouteNames.notifications),
                ),
                _MenuItemData(
                  icon: Icons.tune_outlined,
                  title: 'Notification Preferences',
                  subtitle: 'Choose the updates you want from Luxr.',
                  onTap: () => context.push(RouteNames.notificationPreferences),
                ),
                _MenuItemData(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Luxr Rewards',
                  subtitle: 'Rewards, status perks, and exclusive drops.',
                  onTap: () => _showSnackBar(
                    'Luxr Rewards will unlock more benefits as you shop.',
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _MenuSection(
              title: 'Support',
              items: [
                _MenuItemData(
                  icon: Icons.help_center_outlined,
                  title: 'Help & Support',
                  subtitle: 'FAQs, support contacts, and account guidance.',
                  onTap: () => context.push(RouteNames.profileHelpSupport),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OutlinedButton.icon(
                onPressed: _showSignOutDialog,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: Colors.white12),
                  backgroundColor: _profileSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150 + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.settings,
    required this.isUploadingPhoto,
    required this.onPhotoTap,
  });

  final UserEntity user;
  final ProfileSettingsModel settings;
  final bool isUploadingPhoto;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF421416),
            Color(0xFF241012),
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${user.eliteStatus} TIER',
                      style: const TextStyle(
                        color: _profileHighlight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 3),
                    ),
                    child: ClipOval(
                      child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, _) => const ColoredBox(
                                color: Color(0x22000000),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, _, __) =>
                                  const _AvatarFallback(),
                            )
                          : const _AvatarFallback(),
                    ),
                  ),
                  GestureDetector(
                    onTap: isUploadingPhoto ? null : onPhotoTap,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: isUploadingPhoto
                          ? const Padding(
                              padding: EdgeInsets.all(9),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.black,
                              size: 18,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _HeaderFact(
                        title: settings.defaultAddress?.label ?? 'No address',
                        subtitle:
                            settings.defaultAddress?.shortAddress ??
                            'Add a delivery address',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeaderFact(
                        title:
                            settings.defaultPaymentMethod?.title ?? 'No method',
                        subtitle:
                            settings.defaultPaymentMethod?.subtitle ??
                            'Save your preferred payment option',
                        icon: Icons.credit_card_outlined,
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

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: _profilePanel,
      child: Icon(Icons.person, color: Colors.white70, size: 52),
    );
  }
}

class _HeaderFact extends StatelessWidget {
  const _HeaderFact({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _profileHighlight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.totalOrders,
    required this.wishlistCount,
    required this.addressCount,
  });

  final int totalOrders;
  final int wishlistCount;
  final int addressCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: _profileSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatCell(value: '$totalOrders', label: 'Orders'),
          const _VerticalDivider(),
          _StatCell(value: '$wishlistCount', label: 'Wishlist'),
          const _VerticalDivider(),
          _StatCell(value: '$addressCount', label: 'Addresses'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _profileHighlight,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: Colors.white10);
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.settings});

  final ProfileSettingsModel settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _HighlightCard(
            icon: Icons.location_city_outlined,
            title: settings.defaultAddress != null
                ? 'Default address ready'
                : 'Add your first address',
            subtitle:
                settings.defaultAddress?.formatted ??
                'Save home, office, or gifting locations to speed up checkout.',
          ),
          const SizedBox(height: 12),
          _HighlightCard(
            icon: Icons.account_balance_wallet_outlined,
            title: settings.defaultPaymentMethod != null
                ? 'Preferred payment saved'
                : 'Save a payment method',
            subtitle:
                settings.defaultPaymentMethod?.subtitle ??
                'Keep Google Play, PayPal, or MasterCard details handy.',
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _profileAccent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _profileHighlight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _ProfileActionTile(item: item)),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({required this.item});

  final _MenuItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _profileSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: item.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _profileAccent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: _profileHighlight),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.subtitle,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.hasNotification)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasNotification = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasNotification;
}
