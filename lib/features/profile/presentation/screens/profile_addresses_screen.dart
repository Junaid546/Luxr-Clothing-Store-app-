import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/profile/data/models/profile_address_model.dart';
import 'package:style_cart/features/profile/presentation/providers/profile_providers.dart';

const _profileAccent = AppColors.primary;
const _profileSurface = AppColors.backgroundCard;
const _profileHighlight = AppColors.gold;

class ProfileAddressesScreen extends ConsumerStatefulWidget {
  const ProfileAddressesScreen({super.key});

  @override
  ConsumerState<ProfileAddressesScreen> createState() =>
      _ProfileAddressesScreenState();
}

class _ProfileAddressesScreenState
    extends ConsumerState<ProfileAddressesScreen> {
  bool _isSaving = false;

  Future<void> _persistAddresses(
    List<ProfileAddressModel> addresses, {
    required String successMessage,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      return;
    }

    setState(() => _isSaving = true);

    final result = await ref
        .read(profileRepositoryProvider)
        .saveAddresses(userId: authState.user.uid, addresses: addresses);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    result.fold(
      (failure) => _showSnackBar(failure.message, isError: true),
      (_) => _showSnackBar(successMessage),
    );
  }

  Future<void> _deleteAddress(ProfileAddressModel address) async {
    final settings = await ref.read(profileSettingsProvider.future);
    final remaining = settings.addresses
        .where((item) => item.addressId != address.addressId)
        .toList();

    await _persistAddresses(
      remaining,
      successMessage: '${address.label} address removed.',
    );
  }

  Future<void> _setDefaultAddress(ProfileAddressModel address) async {
    final settings = await ref.read(profileSettingsProvider.future);
    final updated = settings.addresses
        .map(
          (item) =>
              item.copyWith(isDefault: item.addressId == address.addressId),
        )
        .toList();

    await _persistAddresses(
      updated,
      successMessage: '${address.label} is now your default address.',
    );
  }

  Future<void> _confirmDelete(ProfileAddressModel address) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _profileSurface,
            title: const Text(
              'Delete address',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Remove ${address.label} from your saved addresses?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      await _deleteAddress(address);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : _profileAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(profileSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Address Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _profileAccent,
        foregroundColor: Colors.white,
        onPressed: _isSaving
            ? null
            : () => context.push(RouteNames.profileEditAddress),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Address'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D1010), AppColors.backgroundDark],
          ),
        ),
        child: settingsAsync.when(
          data: (settings) {
            if (settings.addresses.isEmpty) {
              return _EmptyProfileState(
                icon: Icons.location_on_outlined,
                title: 'No saved addresses yet',
                subtitle:
                    'Add a delivery address once and reuse it during checkout.',
                buttonLabel: 'Create your first address',
                onTap: () => context.push(RouteNames.profileEditAddress),
              );
            }

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
                    _FeatureBanner(
                      title: 'Delivery details, organized',
                      subtitle:
                          'Keep home, office, and gifting addresses ready to use.',
                    ),
                    const SizedBox(height: 16),
                    ...settings.addresses.map(
                      (address) => _AddressCard(
                        address: address,
                        onEdit: () => context.push(
                          RouteNames.profileEditAddress,
                          extra: address,
                        ),
                        onDelete: () => _confirmDelete(address),
                        onSetDefault: address.isDefault
                            ? null
                            : () => _setDefaultAddress(address),
                      ),
                    ),
                  ],
                ),
                if (_isSaving)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _profileHighlight,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: _profileHighlight),
          ),
          error: (error, _) => _EmptyProfileState(
            icon: Icons.error_outline,
            title: 'Could not load addresses',
            subtitle: error.toString(),
            buttonLabel: 'Try again',
            onTap: () => ref.invalidate(profileSettingsProvider),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  final ProfileAddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: address.isDefault ? _profileHighlight : Colors.white10,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _profileAccent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  address.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            address.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address.formatted,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 6),
          Text(address.phone, style: const TextStyle(color: _profileHighlight)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white12),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSetDefault,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _profileAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    disabledBackgroundColor: Colors.white10,
                  ),
                  child: Text(address.isDefault ? 'Saved' : 'Set Default'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: onDelete,
                style: IconButton.styleFrom(backgroundColor: Colors.white10),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A181B), Color(0xFF231012)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  const _EmptyProfileState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _profileHighlight, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _profileAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
